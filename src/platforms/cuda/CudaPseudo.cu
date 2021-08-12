#include <complex>
#include "CudaPseudo.h"

CudaPseudo::CudaPseudo(
    std::array<int,3> nx, std::array<double,3> dx,
    double *dv, double volume, double ds,
    int NN, int NNf,
    int N_BLOCKS, int N_THREADS,
    int process_idx)
{
    int device;
    int devices_count;
    struct cudaDeviceProp prop;

    const int NRANK{3};
    const int BATCH{2};

    this->MM         = nx[0]*nx[1]*nx[2];
    this->MM_COMPLEX = nx[0]*nx[1]*(nx[2]/2+1);
    this->NN = NN;
    this->NNf= NNf;

    this->volume = volume;

    this->N_BLOCKS = N_BLOCKS;
    this->N_THREADS = N_THREADS;


    printf( "MM: %d, NN: %d, NNf: %d, Volume: %f\n", MM, NN, NNf, volume);
    printf( "N_BLOCKS: %d, N_THREADS: %d\n", N_BLOCKS, N_THREADS);

    cudaGetDeviceCount(&devices_count);
    cudaSetDevice(process_idx%devices_count);

    printf( "DeviceCount: %d\n", devices_count );
    printf( "ProcessIdx, DeviceID: %d, %d\n", process_idx, process_idx%devices_count);

    cudaError_t err = cudaGetDevice(&device);
    if (err != cudaSuccess)
    {
        printf("%s\n", cudaGetErrorString(err));
        exit (1);
    }
    cudaGetDeviceProperties(&prop, device);
    if (err != cudaSuccess)
    {
        printf("%s\n", cudaGetErrorString(err));
        exit (1);
    }

    printf( "\n--- Current CUDA Device Query ---\n");
    printf( "Device %d : \t\t\t\t%s\n", device, prop.name );
    printf( "Compute capability version : \t\t%d.%d\n", prop.major, prop.minor );
    printf( "Multiprocessor : \t\t\t%d\n", prop.multiProcessorCount );

    printf( "Global memory : \t\t\t%ld MBytes\n", prop.totalGlobalMem/(1024*1024) );
    printf( "Constant memory : \t\t\t%ld Bytes\n", prop.totalConstMem );
    printf( "Shared memory per block : \t\t%ld Bytes\n", prop.sharedMemPerBlock );
    printf( "Registers available per block : \t%d\n", prop.regsPerBlock );

    printf( "Warp size : \t\t\t\t%d\n", prop.warpSize );
    printf( "Maximum threads per block : \t\t%d\n", prop.maxThreadsPerBlock );
    printf( "Max size of a thread block (x,y,z) : \t(%d, %d, %d)\n", prop.maxThreadsDim[0], prop.maxThreadsDim[1], prop.maxThreadsDim[2] );
    printf( "Max size of a grid size    (x,y,z) : \t(%d, %d, %d)\n", prop.maxGridSize[0], prop.maxGridSize[1], prop.maxGridSize[2] );

    if(prop.deviceOverlap)
    {
        printf( "Device overlap : \t\t\t Yes \n");
    }
    else
    {
        printf( "Device overlap : \t\t\t No \n");
    }

    if (N_THREADS > prop.maxThreadsPerBlock)
    {
        printf("'threads_per_block' cannot be greater than 'Maximum threads per block'\n");
        exit (1);
    }

    if (N_BLOCKS > prop.maxGridSize[0])
    {
        printf("The number of blocks cannot be greater than 'Max size of a grid size (x)'\n");
        exit (1);
    }
    printf( "\n" );

    int n_grid[NRANK] = {nx[0], nx[1], nx[2]};

    cudaMalloc((void**)&temp_d,  sizeof(double)*MM);

    cudaMalloc((void**)&qstep1_d, sizeof(double)*2*MM);
    cudaMalloc((void**)&qstep2_d, sizeof(double)*2*MM);
    cudaMalloc((void**)&kqin_d,   sizeof(ftsComplex)*2*MM_COMPLEX);

    cudaMalloc((void**)&q1_d, sizeof(double)*MM*(NN+1));
    cudaMalloc((void**)&q2_d, sizeof(double)*MM*(NN+1));

    cudaMalloc((void**)&expdwa_d,      sizeof(double)*MM);
    cudaMalloc((void**)&expdwb_d,      sizeof(double)*MM);
    cudaMalloc((void**)&expdwa_half_d, sizeof(double)*MM);
    cudaMalloc((void**)&expdwb_half_d, sizeof(double)*MM);

    cudaMalloc((void**)&phia_d, sizeof(double)*MM);
    cudaMalloc((void**)&phib_d, sizeof(double)*MM);

    cudaMalloc((void**)&expf_d,      sizeof(double)*MM_COMPLEX);
    cudaMalloc((void**)&expf_half_d, sizeof(double)*MM_COMPLEX);
    cudaMalloc((void**)&dv_d,        sizeof(double)*MM);

    this->temp_arr = new double[MM];
    this->expf = new double[MM_COMPLEX];
    this->expf_half = new double[MM_COMPLEX];
    init_gaussian_factor(nx, dx, ds);
    cudaMemcpy(expf_d,   expf,          sizeof(double)*MM_COMPLEX,cudaMemcpyHostToDevice);
    cudaMemcpy(expf_half_d,  expf_half, sizeof(double)*MM_COMPLEX,cudaMemcpyHostToDevice);
    
    cudaMemcpy(dv_d,   dv,              sizeof(double)*MM,cudaMemcpyHostToDevice);

    /* Create a 3D FFT plan. */
    cufftPlanMany(&plan_for, NRANK, n_grid, NULL, 1, 0, NULL, 1, 0, CUFFT_D2Z, BATCH);
    cufftPlanMany(&plan_bak, NRANK, n_grid, NULL, 1, 0, NULL, 1, 0, CUFFT_Z2D, BATCH);
}
CudaPseudo::~CudaPseudo()
{
    cufftDestroy(plan_for);
    cufftDestroy(plan_bak);

    cudaFree(qstep1_d);
    cudaFree(qstep2_d);
    cudaFree(kqin_d);

    cudaFree(temp_d);
    cudaFree(q1_d);
    cudaFree(q2_d);

    cudaFree(expdwa_d);
    cudaFree(expdwb_d);
    cudaFree(expdwa_half_d);
    cudaFree(expdwb_half_d);
    cudaFree(phia_d);
    cudaFree(phib_d);

    cudaFree(expf_d);
    cudaFree(expf_half_d);
    cudaFree(dv_d);
    
    delete[] temp_arr;
    delete[] expf;
    delete[] expf_half;
}
//----------------- init_gaussian_factor -------------------
void CudaPseudo::init_gaussian_factor(std::array<int,3> nx, std::array<double,3> dx, double ds)
{
    int itemp, jtemp, ktemp, idx;
    double xfactor[3];
    const double PI{3.14159265358979323846};

    // calculate the exponential factor
    for(int d=0; d<3; d++)
    {
        xfactor[d] = -pow(2*PI/(nx[d]*dx[d]),2)*ds/6.0;
    }

    for(int i=0; i<nx[0]; i++)
    {
        if( i > nx[0]/2)
            itemp = nx[0]-i;
        else
            itemp = i;
        for(int j=0; j<nx[1]; j++)
        {
            if( j > nx[1]/2)
                jtemp = nx[1]-j;
            else
                jtemp = j;
            for(int k=0; k<nx[2]/2+1; k++)
            {
                ktemp = k;
                idx = i* nx[1]*(nx[2]/2+1) + j*(nx[2]/2+1) + k;
                expf[idx] = exp(pow(itemp,2)*xfactor[0]+pow(jtemp,2)*xfactor[1]+pow(ktemp,2)*xfactor[2]);
                expf_half[idx] = exp((pow(itemp,2)*xfactor[0]+pow(jtemp,2)*xfactor[1]+pow(ktemp,2)*xfactor[2])/2);
            }
        }
    }
}
void CudaPseudo::find_phi(double *phia,  double *phib,
                          double *q1_init, double *q2_init,
                          double *wa, double *wb, double ds, double &QQ)
{

    double expdwa[MM];
    double expdwb[MM];
    double expdwa_half[MM];
    double expdwb_half[MM];

    for(int i=0; i<MM; i++)
    {
        expdwa     [i] = exp(-wa[i]*ds*0.5);
        expdwb     [i] = exp(-wb[i]*ds*0.5);
        expdwa_half[i] = exp(-wa[i]*ds*0.25);
        expdwb_half[i] = exp(-wb[i]*ds*0.25);
    }

    /* Copy array from host memory to device memory */
    cudaMemcpy(expdwa_d, expdwa, sizeof(double)*MM,cudaMemcpyHostToDevice);
    cudaMemcpy(expdwb_d, expdwb, sizeof(double)*MM,cudaMemcpyHostToDevice);
    cudaMemcpy(expdwa_half_d, expdwa_half, sizeof(double)*MM,cudaMemcpyHostToDevice);
    cudaMemcpy(expdwb_half_d, expdwb_half, sizeof(double)*MM,cudaMemcpyHostToDevice);

    cudaMemcpy(&q1_d[0], q1_init, sizeof(double)*MM,
               cudaMemcpyHostToDevice);
    cudaMemcpy(&q2_d[0], q2_init, sizeof(double)*MM,
               cudaMemcpyHostToDevice);

    for(int n=0; n<NN; n++)
    {
        if(n<NNf && n<NN-NNf)
        {
            onestep(
                &q1_d[MM*n], &q1_d[MM*(n+1)],
                &q2_d[MM*n], &q2_d[MM*(n+1)],
                expdwa_d, expdwa_half_d,
                expdwb_d, expdwb_half_d);
        }
        else if(n<NNf && n>=NN-NNf)
        {
            onestep(
                &q1_d[MM*n], &q1_d[MM*(n+1)],
                &q2_d[MM*n], &q2_d[MM*(n+1)],
                expdwa_d, expdwa_half_d,
                expdwa_d, expdwa_half_d);
        }
        else if(n>=NNf && n<NN-NNf)
        {
            onestep(
                &q1_d[MM*n], &q1_d[MM*(n+1)],
                &q2_d[MM*n], &q2_d[MM*(n+1)],
                expdwb_d, expdwb_half_d,
                expdwb_d, expdwb_half_d);
        }
        else
        {
            onestep(
                &q1_d[MM*n], &q1_d[MM*(n+1)],
                &q2_d[MM*n], &q2_d[MM*(n+1)],
                expdwb_d, expdwb_half_d,
                expdwa_d, expdwa_half_d);
        }
    }

    // Calculate Segment Density
    // dvment concentration. only half contribution from the end
    multiReal<<<N_BLOCKS, N_THREADS>>>(phib_d, &q1_d[MM*NN], &q2_d[0], 0.5, MM);
    //printf("NN, %5.3f\n", 1.0/3.0);
    // the B block dvment
    for(int n=NN-1; n>NNf; n--)
    {
        //printf("%d, %5.3f\n", n, 2.0*((n % 2) +1)/3.0);
        multiAddReal<<<N_BLOCKS, N_THREADS>>>(phib_d, &q1_d[MM*n], &q2_d[MM*(NN-n)], 1.0, MM);
    }

    // the junction is half A and half B
    multiReal<<<N_BLOCKS, N_THREADS>>>(phia_d, &q1_d[MM*NNf], &q2_d[MM*(NN-NNf)], 0.5, MM);
    linComb<<<N_BLOCKS, N_THREADS>>>(phib_d, 1.0, phib_d, 1.0, phia_d, MM);

    //printf("%d, %5.3f\n", NNf, 1.0/3.0);
    //calculates the total partition function
    multiReal<<<N_BLOCKS, N_THREADS>>>(temp_d, phia_d, dv_d, 2.0, MM);
    cudaMemcpy(temp_arr, temp_d, sizeof(double)*MM,cudaMemcpyDeviceToHost);
    QQ = 0.0;
    for(int i=0; i<MM; i++)
    {
        QQ = QQ + temp_arr[i];
    }

    // the A block dvment
    for(int n=NNf-1; n>0; n--)
    {
        //printf("%d, %5.3f\n", n, 2.0*((n % 2) +1)/3.0);
        multiAddReal<<<N_BLOCKS, N_THREADS>>>(phia_d, &q1_d[MM*n], &q2_d[MM*(NN-n)], 1.0, MM);
    }
    // only half contribution from the end
    //printf("0, %5.3f\n", 1.0/3.0);
    multiAddReal<<<N_BLOCKS, N_THREADS>>>(phia_d, &q1_d[0], &q2_d[MM*NN], 0.5, MM);

    // normalize the concentration
    linComb<<<N_BLOCKS, N_THREADS>>>(phia_d, (volume)/QQ/NN, phia_d, 0.0, phia_d, MM);
    linComb<<<N_BLOCKS, N_THREADS>>>(phib_d, (volume)/QQ/NN, phib_d, 0.0, phib_d, MM);

    cudaMemcpy(phia, phia_d, sizeof(double)*MM,cudaMemcpyDeviceToHost);
    cudaMemcpy(phib, phib_d, sizeof(double)*MM,cudaMemcpyDeviceToHost);
}

/* Advance two partial partition functions simultaneously using Richardson extrapolation.
* Note that cufft doesn't fully utilize GPU cores unless n_grid is sufficiently large.
* To increase GPU usage, we introduce kernel overlapping. */
void CudaPseudo::onestep(double *qin1_d, double *qout1_d,
                         double *qin2_d, double *qout2_d,
                         double *expdw1_d, double *expdw1_half_d,
                         double *expdw2_d, double *expdw2_half_d)
{
    //-------------- step 1 ---------- 
    // Evaluate e^(-w*ds/2) in real space
    multiReal<<<N_BLOCKS, N_THREADS>>>(&qstep1_d[0],  qin1_d, expdw1_d, 1.0, MM);
    multiReal<<<N_BLOCKS, N_THREADS>>>(&qstep1_d[MM], qin2_d, expdw2_d, 1.0, MM);

    // Execute a Forward 3D FFT
    cufftExecD2Z(plan_for, qstep1_d, kqin_d);

    // Multiply e^(-k^2 ds/6) in fourier space
    multiFactor<<<N_BLOCKS, N_THREADS>>>(&kqin_d[0],          expf_d, MM_COMPLEX);
    multiFactor<<<N_BLOCKS, N_THREADS>>>(&kqin_d[MM_COMPLEX], expf_d, MM_COMPLEX);

    // Execute a backward 3D FFT
    cufftExecZ2D(plan_bak, kqin_d, qstep1_d);

    // Evaluate e^(-w*ds/2) in real space
    multiReal<<<N_BLOCKS, N_THREADS>>>(&qstep1_d[0],  &qstep1_d[0],   expdw1_d, 1.0/((double)MM), MM);
    multiReal<<<N_BLOCKS, N_THREADS>>>(&qstep1_d[MM], &qstep1_d[MM],  expdw2_d, 1.0/((double)MM), MM);

    //-------------- step 2 ----------
    // Evaluate e^(-w*ds/4) in real space
    multiReal<<<N_BLOCKS, N_THREADS>>>(&qstep2_d[0],  qin1_d, expdw1_half_d, 1.0, MM);
    multiReal<<<N_BLOCKS, N_THREADS>>>(&qstep2_d[MM], qin2_d, expdw2_half_d, 1.0, MM);

    // Execute a Forward 3D FFT
    cufftExecD2Z(plan_for, qstep2_d, kqin_d);

    // Multiply e^(-k^2 ds/12) in fourier space
    multiFactor<<<N_BLOCKS, N_THREADS>>>(&kqin_d[0],          expf_half_d, MM_COMPLEX);
    multiFactor<<<N_BLOCKS, N_THREADS>>>(&kqin_d[MM_COMPLEX], expf_half_d, MM_COMPLEX);

    // Execute a backward 3D FFT
    cufftExecZ2D(plan_bak, kqin_d, qstep2_d);

    // Evaluate e^(-w*ds/2) in real space
    multiReal<<<N_BLOCKS, N_THREADS>>>(&qstep2_d[0],  &qstep2_d[0],  expdw1_d, 1.0/((double)MM), MM);
    multiReal<<<N_BLOCKS, N_THREADS>>>(&qstep2_d[MM], &qstep2_d[MM], expdw2_d, 1.0/((double)MM), MM);
    // Execute a Forward 3D FFT
    cufftExecD2Z(plan_for, qstep2_d, kqin_d);

    // Multiply e^(-k^2 ds/12) in fourier space
    multiFactor<<<N_BLOCKS, N_THREADS>>>(&kqin_d[0],          expf_half_d, MM_COMPLEX);
    multiFactor<<<N_BLOCKS, N_THREADS>>>(&kqin_d[MM_COMPLEX], expf_half_d, MM_COMPLEX);

    // Execute a backward 3D FFT
    cufftExecZ2D(plan_bak, kqin_d, qstep2_d);

    // Evaluate e^(-w*ds/4) in real space.
    multiReal<<<N_BLOCKS, N_THREADS>>>(&qstep2_d[0],  &qstep2_d[0],  expdw1_half_d, 1.0/((double)MM), MM);
    multiReal<<<N_BLOCKS, N_THREADS>>>(&qstep2_d[MM], &qstep2_d[MM], expdw2_half_d, 1.0/((double)MM), MM);
    //-------------- step 3 ----------
    linComb<<<N_BLOCKS, N_THREADS>>>(qout1_d, 4.0/3.0, &qstep2_d[0],  -1.0/3.0, &qstep1_d[0],  MM);
    linComb<<<N_BLOCKS, N_THREADS>>>(qout2_d, 4.0/3.0, &qstep2_d[MM], -1.0/3.0, &qstep1_d[MM], MM);
}

/* Get partial partition functions
* This is made for debugging and testing.
* Do NOT this at main progarams.
* */
void CudaPseudo::get_partition(double *q1_out,  double *q2_out, int n)
{
    cudaMemcpy(q1_out, &q1_d[n*MM], sizeof(double)*MM,cudaMemcpyDeviceToHost);
    cudaMemcpy(q2_out, &q2_d[n*MM], sizeof(double)*MM,cudaMemcpyDeviceToHost);
}
