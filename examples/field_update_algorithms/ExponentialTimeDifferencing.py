import sys
import os
import time
import pathlib
import numpy as np
from langevinfts import *

def find_saddle_point():
    # assign large initial value for the energy and error
    energy_total = 1e20
    error_level = 1e20

    # reset Anderson mixing module
    am.reset_count()

    # saddle point iteration begins here
    for saddle_iter in range(0,saddle_max_iter):
        
        # for the given fields find the polymer statistics
        QQ = pseudo.find_phi(phi_a, phi_b, 
                q1_init,q2_init,
                w_plus + w_minus,
                w_plus - w_minus)
        phi_plus = phi_a + phi_b
        
        # calculate output fields
        g_plus = 1.0*(phi_plus-1.0)
        w_plus_out = w_plus + g_plus 
        sb.zero_mean(w_plus_out);

        # error_level measures the "relative distance" between the input and output fields
        old_error_level = error_level
        error_level = np.sqrt(sb.inner_product(phi_plus-1.0,phi_plus-1.0)/sb.get_volume())

        # print iteration # and error levels
        if(verbose_level == 2 or
         verbose_level == 1 and
         (error_level < saddle_tolerance or saddle_iter == saddle_max_iter-1 )):
             
            # calculate the total energy
            energy_old = energy_total
            energy_total  = -np.log(QQ/sb.get_volume())
            energy_total += sb.inner_product(w_minus,w_minus)/pc.get_chi_n()/sb.get_volume()
            energy_total -= sb.integral(w_plus)/sb.get_volume()

            # check the mass conservation
            mass_error = sb.integral(phi_plus)/sb.get_volume() - 1.0
            print("%8d %12.3E %15.7E %13.9f %13.9f" %
                (saddle_iter, mass_error, QQ, energy_total, error_level))
            return saddle_iter, QQ
        # conditions to end the iteration
        if(error_level < saddle_tolerance):
            break;
            
        # calculte new fields using simple and Anderson mixing
        # (Caution! we are now passing entire w, w_out and w_diff not just w[0], w_out[0] and w_diff[0])
        am.caculate_new_fields(w_plus, w_plus_out, g_plus, old_error_level, error_level);

# -------------- simulation parameters ------------
# Cuda environment variables 
#os.environ["CUDA_VISIBLE_DEVICES"]= "1"
# OpenMP environment variables 
os.environ["KMP_STACKSIZE"] = "1G"
os.environ["MKL_NUM_THREADS"] = "1"  # always 1
os.environ["OMP_MAX_ACTIVE_LEVELS"] = "1"  # 0, 1 or 2

#pp = ParamParser.get_instance()
#pp.read_param_file(sys.argv[1], False);
#pp.get("platform")
data_path = "data_ETD1"
pathlib.Path(data_path).mkdir(parents=True, exist_ok=True)

verbose_level = 1  # 1 : print at each langevin step.
                   # 2 : print at each saddle point iteration.

# Simulation Box
nx = [48, 48, 48]
lx = [9, 9, 9] /np.sqrt(6)

# Polymer Chain
NN = 100
f = 0.34
chi_n = 10.0
polymer_model = "Discrete" # choose among [Gaussian, Discrete]

# Anderson Mixing 
saddle_tolerance = 1e-4
saddle_max_iter = 200
am_n_comp = 1  # W+
am_max_hist= 20
am_start_error = 1e-1
am_mix_min = 0.1
am_mix_init = 0.1

# Langevin Dynamics
langevin_dt = 1.0     # langevin step interval, delta tau*N
langevin_nbar = 1000  # invariant polymerization index
langevin_max_iter = 1200;

# -------------- initialize ------------
# choose platform among [CUDA, CPU_MKL, CPU_FFTW]
factory = PlatformSelector.create_factory("CUDA")

# create instances and assign to the variables of base classs
# for the dynamic binding
pc = factory.create_polymer_chain(f, NN, chi_n)
sb = factory.create_simulation_box(nx, lx)
pseudo = factory.create_pseudo(sb, pc, polymer_model)
am = factory.create_anderson_mixing(sb, am_n_comp,
    am_max_hist, am_start_error, am_mix_min, am_mix_init)

# standard deviation of normal noise for single segment
langevin_sigma = np.sqrt(2*langevin_dt*sb.get_MM()/ 
    (sb.get_volume()*np.sqrt(langevin_nbar)))
    
# random seed for MT19937
np.random.seed(5489); 

# arrays for exponential time differencing
space_kx, space_ky, space_kz = np.meshgrid(
    2*np.pi/sb.get_lx(1)*np.concatenate([np.arange(sb.get_nx(1)//2), sb.get_nx(1)//2-np.arange(sb.get_nx(1)//2)]),
    2*np.pi/sb.get_lx(0)*np.concatenate([np.arange(sb.get_nx(0)//2), sb.get_nx(0)//2-np.arange(sb.get_nx(0)//2)]),
    2*np.pi/sb.get_lx(2)*np.arange(sb.get_nx(2)//2+1))

mag2_k = (space_kx**2 + space_ky**2 + space_kz**2)/6.0
mag2_k[0,0,0] = 1.0e-5 # to prevent 'division by zero' error
g_k = 2*(mag2_k+np.exp(-mag2_k)-1.0)/mag2_k**2
g_k[0,0,0] = 1.0

exp_kernel_minus =         (1.0 - np.exp(-(2/pc.get_chi_n())*langevin_dt))/(2/pc.get_chi_n())
exp_kernel_noise = np.sqrt((1.0 - np.exp(-(4/pc.get_chi_n())*langevin_dt))/(4/pc.get_chi_n()*langevin_dt))

# -------------- print simulation parameters ------------
print("---------- Simulation Parameters ----------");
print("Box Dimension: %d"  % (sb.get_dimension()) )
print("Precision: 8")
print("chi_n: %f, f: %f, NN: %d" % (pc.get_chi_n(), pc.get_f(), pc.get_NN()) )
print("Nx: %d, %d, %d" % (sb.get_nx(0), sb.get_nx(1), sb.get_nx(2)) )
print("Lx: %f, %f, %f" % (sb.get_lx(0), sb.get_lx(1), sb.get_lx(2)) )
print("dx: %f, %f, %f" % (sb.get_dx(0), sb.get_dx(1), sb.get_dx(2)) )
print("Volume: %f" % (sb.get_volume()) )

print("Invariant Polymerization Index: %d" % (langevin_nbar) )
print("Langevin Sigma: %f" % (langevin_sigma) )
print("Random Number Generator: ", np.random.RandomState().get_state()[0])

#-------------- allocate array ------------
q1_init = np.zeros(sb.get_MM(), dtype=np.float64)
q2_init = np.zeros(sb.get_MM(), dtype=np.float64)
phi_a   = np.zeros(sb.get_MM(), dtype=np.float64)
phi_b   = np.zeros(sb.get_MM(), dtype=np.float64)

print("wminus and wplus are initialized to random")
w_plus = np.random.normal(0, langevin_sigma, sb.get_MM())
w_minus = np.random.normal(0, langevin_sigma, sb.get_MM())

# keep the level of field value
sb.zero_mean(w_plus);
sb.zero_mean(w_minus);

# free end initial condition. q1 is q and q2 is qdagger.
# q1 starts from A end and q2 starts from B end.
q1_init[:] = 1.0;
q2_init[:] = 1.0;

find_saddle_point()
#------------------ run ----------------------
print("---------- Run ----------")
time_start = time.time()

lnQ_list = []
print("iteration, mass error, total_partition, energy_total, error_level")
for langevin_step in range(0, langevin_max_iter):
    
    print("langevin step: ", langevin_step)
    # update w_minus
    normal_noise = np.random.normal(0.0, langevin_sigma, sb.get_MM())
    g_minus = phi_a-phi_b + 2*w_minus/pc.get_chi_n()
    w_minus += -exp_kernel_minus*g_minus + exp_kernel_noise*normal_noise
    sb.zero_mean(w_minus)
    _, QQ, = find_saddle_point()
    lnQ_list.append(-np.log(QQ/sb.get_volume()))

    if( langevin_step % 1000 == 0 ):
        np.savez(data_path + "/fields_%06d.npz" % (langevin_step),
        nx=nx, lx=lx, N=NN, f=pc.get_f(), chi_n=pc.get_chi_n(),
        polymer_model=polymer_model, n_bar=langevin_nbar,
        random_seed=np.random.RandomState().get_state()[0],
        w_minus=w_minus, w_plus=w_plus)

print(langevin_dt, np.mean(lnQ_list[200:]))
np.savez("data_ETD1_lnQ.npz", lnQ_list)

# estimate execution time
time_duration = time.time() - time_start; 
print( "total time: %f, time per step: %f" %
    (time_duration, time_duration/langevin_max_iter) )
