#include <cstdlib>
#include <iostream>
#include <algorithm>
#include <cmath>
#include "SimulationBox.h"
#include "MklFFT3D.h"
#include "CpuPseudoGaussian.h"

int main()
{
    setenv("MKL_NUM_THREADS","1", 0); //  # always "1"
    setenv("OMP_STACKSIZE", "1G", 0);
    setenv("OMP_MAX_ACTIVE_LEVELS", "2", 0);  //# "0", "1" or "2"
    
    const int II{5};
    const int JJ{4};
    const int KK{3};
    const int MM{II*JJ*KK};
    const int NN{4};

    double phia[MM], phib[MM];
    double q1_init[MM] {0.0}, q2_init[MM] {0.0};
    double q1_last[MM], q2_last[MM];

    std::array<double,MM> diff_sq;

    double QQ, error;
    double Lx, Ly, Lz, f;

//-------------- initialize ------------
    std::cout<< "Initializing" << std::endl;

    f = 0.5;
    Lx = 4.0;
    Ly = 3.0;
    Lz = 2.0;

    PolymerChain pc(f, NN, 0.0, "Gaussian");    
    SimulationBox sb({II,JJ,KK}, {Lx,Ly,Lz});    

    // initialize pseudo spectral parameters
    double wa[MM] = {0.183471406e+0,0.623968915e+0,0.731257661e+0,0.997228140e+0,0.961913696e+0,
                     0.792673860e-1,0.429684069e+0,0.290531312e+0,0.453270921e+0,0.199228629e+0,
                     0.754931905e-1,0.226924328e+0,0.936407886e+0,0.979392715e+0,0.464957186e+0,
                     0.742653949e+0,0.368019859e+0,0.885231224e+0,0.406191773e+0,0.653096157e+0,
                     0.567929080e-1,0.568028857e+0,0.144986181e+0,0.466158777e+0,0.573327733e+0,
                     0.136324723e+0,0.819010407e+0,0.271218167e+0,0.626224101e+0,0.398109186e-1,
                     0.860031651e+0,0.338153865e+0,0.688078522e+0,0.564682952e+0,0.222924187e+0,
                     0.306816449e+0,0.316316038e+0,0.640568415e+0,0.702342408e+0,0.632135481e+0,
                     0.649402777e+0,0.647100865e+0,0.370402133e+0,0.691313864e+0,0.447870566e+0,
                     0.757298851e+0,0.586173682e+0,0.766745717e-1,0.504185402e+0,0.812016428e+0,
                     0.217988206e+0,0.273487202e+0,0.937672578e+0,0.570540523e+0,0.409071185e+0,
                     0.391548274e-1,0.663478965e+0,0.260755447e+0,0.503943226e+0,0.979481790e+0
                    };

    //idx = 0*JJ*KK + 0*KK + KK-1;
    //std::cout<< "wa[0][0][KK-1]: " << wa[idx] << std::endl;
    //idx = 0*JJ*KK + 1*KK + 0;
    //std::cout<< "wa[0][1][0]: " << wa[idx] << std::endl;

    double wb[MM] = {0.113822903e-1,0.330673934e+0,0.270138412e+0,0.669606774e+0,0.885344778e-1,
                     0.604752856e+0,0.890062293e+0,0.328557615e+0,0.965824739e+0,0.865399960e+0,
                     0.698893686e+0,0.857947305e+0,0.594897904e+0,0.248187208e+0,0.155686710e+0,
                     0.116803898e+0,0.711146609e+0,0.107610460e+0,0.143034307e+0,0.123131521e+0,
                     0.230387237e+0,0.516274641e+0,0.562366089e-1,0.491449746e+0,0.746656140e+0,
                     0.296108614e+0,0.424987667e+0,0.651538750e+0,0.116745920e+0,0.567790110e+0,
                     0.954487190e+0,0.802476927e-1,0.440223916e+0,0.843025420e+0,0.612864528e+0,
                     0.571893767e+0,0.759625605e+0,0.872255004e+0,0.935065364e+0,0.635565347e+0,
                     0.373711972e-2,0.860683468e+0,0.186492706e+0,0.267880995e+0,0.579305501e+0,
                     0.693549226e+0,0.613843845e+0,0.259811620e-1,0.848915465e+0,0.766111508e+0,
                     0.872008750e+0,0.116289041e+0,0.917713893e+0,0.710076955e+0,0.442712526e+0,
                     0.516722213e+0,0.253395805e+0,0.472950065e-1,0.152934959e+0,0.292486174e+0
                    };

    //for(int i=0; i<MM; i++)
    //{
    //wa[i] = 0.0;
    //wb[i] = 0.0;
    //}

    CpuPseudoGaussian pseudo(&sb, &pc, new MklFFT3D(sb.get_nx()));

    // q1 is q and q2 is qdagger in the note
    // free end initial condition (q1 starts from A end, q2 starts from B end)
    // free end initial condition (q1 starts from A end, q2 starts from B end)
    for(int i=0; i<MM; i++)
    {
        q1_init[i] = 1.0;
        q2_init[i] = 1.0;
    }

    //---------------- run --------------------
    std::cout<< "Running MKL Pseudo " << std::endl;
    pseudo.find_phi(phia, phib,q1_init,q2_init,wa,wb,QQ);

    //--------------- check --------------------
    std::cout<< "Checking"<< std::endl;
    std::cout<< "If error is less than 1.0e-7, it is ok!" << std::endl;
    pseudo.get_partition(q1_last, q2_last, NN);

    std::cout.precision(7);
    //std::cout<< "q1_last :" << std::endl;
    //for(int i=0; i<MM; i++)
    //    std::cout<< q1_last[i] << ", ";
    //std::cout<< std::endl;

    double q1_last_ref[MM] =
    {
        0.6965456581, 0.636655225, 0.6514580668,
        0.5794545502, 0.6413949021, 0.5962758192,
        0.558548356, 0.6601148449, 0.5569728913,
        0.5964779091, 0.6290102494, 0.5775121486,
        0.5846974973, 0.6469315711, 0.6639138583,
        0.654692146, 0.5950073499, 0.6825497426,
        0.6917256734, 0.7245422629, 0.7022905036,
        0.6208944319, 0.7362918657, 0.6476201437,
        0.556910252, 0.651577934, 0.6122978018,
        0.5876833681, 0.6942208366, 0.616292124,
        0.5481693969, 0.7025850486, 0.6337584332,
        0.5391286738, 0.6224088075, 0.6143140535,
        0.5345032761, 0.5294697169, 0.520947629,
        0.5829711247, 0.6610041438, 0.5287456124,
        0.6601460967, 0.6659161313, 0.6197818348,
        0.5853524162, 0.5952154452, 0.6984995997,
        0.5638891268, 0.5313406813, 0.5343779299,
        0.6463252753, 0.5258684278, 0.5531855677,
        0.6586589231, 0.6413400744, 0.6505003159,
        0.7070963334, 0.6864069274, 0.6566075495,
    };
    for(int i=0; i<MM; i++)
        diff_sq[i] = pow(q1_last[i] - q1_last_ref[i],2);
    error = sqrt(*std::max_element(diff_sq.begin(),diff_sq.end()));
    std::cout<< "Partial Partition error: "<< error << std::endl;
    if (std::isnan(error) || error > 1e-7)
        return -1;

    double q2_last_ref[MM] =
    {
        0.6810083246, 0.6042219428, 0.6088941863,
        0.5499790828, 0.5523265158, 0.6646200703,
        0.6104139336, 0.6635820753, 0.6213703022,
        0.6796826878, 0.7098425232, 0.6458523321,
        0.5548159682, 0.5798284317, 0.6281662988,
        0.5963987107, 0.6430736681, 0.6104627897,
        0.6593499107, 0.6631208324, 0.7252402836,
        0.6170169159, 0.7195208023, 0.6585338261,
        0.5794674771, 0.6725039984, 0.5752551656,
        0.6436001186, 0.642522178, 0.6871550254,
        0.5640114031, 0.670609007, 0.6181336276,
        0.5703167502, 0.6774451221, 0.6424661223,
        0.5786673846, 0.5496132976, 0.5417027025,
        0.5841556773, 0.5807653122, 0.5541754977,
        0.6424438503, 0.6198358109, 0.6386821682,
        0.5771929061, 0.5987387839, 0.6900534285,
        0.6009603513, 0.5254176256, 0.6024316286,
        0.628337461, 0.5247686088, 0.5741865074,
        0.6621998454, 0.7046183294, 0.598915981,
        0.6727811693, 0.6382628733, 0.5693589452,
    };
    for(int i=0; i<MM; i++)
        diff_sq[i] = pow(q2_last[i] - q2_last_ref[i],2);
    error = sqrt(*std::max_element(diff_sq.begin(),diff_sq.end()));
    std::cout<< "Complementary Partial Partition error: "<< error << std::endl;
    if (std::isnan(error) || error > 1e-7)
        return -1;
        
    double phia_ref[MM] =
    {
        0.5756682772, 0.4907693646, 0.4929215785,
        0.4285495384, 0.4485241316, 0.5415179101,
        0.4721954361, 0.5414789207, 0.4780566168,
        0.5347742365, 0.5690190057, 0.5062251635,
        0.4344691944, 0.4632728414, 0.5203322167,
        0.4867970811, 0.5136125019, 0.4955962665,
        0.5451656095, 0.5427844852, 0.6039258559,
        0.4896837933, 0.6058012546, 0.5270202724,
        0.4549896083, 0.5581025362, 0.4569688042,
        0.5146078707, 0.5295426558, 0.5607452147,
        0.4284411841, 0.5584599491, 0.4897354879,
        0.4412935033, 0.5451907287, 0.5168324559,
        0.4590688112, 0.4289971762, 0.4182401334,
        0.4651297448, 0.4848154606, 0.4296692569,
        0.5298085479, 0.5040272922, 0.5128324626,
        0.452969296, 0.4739701644, 0.5869633329,
        0.4739224835, 0.408162465, 0.4778525932,
        0.5251137097, 0.4022878568, 0.4526763114,
        0.5391015021, 0.5775454583, 0.4854159658,
        0.5646456355, 0.5268519966, 0.4568607917,
    };
    for(int i=0; i<MM; i++)
        diff_sq[i] = pow(phia[i] - phia_ref[i],2);
    error = sqrt(*std::max_element(diff_sq.begin(),diff_sq.end()));
    std::cout<< "Segment Concentration A error: "<< error << std::endl;
    if (std::isnan(error) || error > 1e-7)
        return -1;
    
    double phib_ref[MM] =
    {
        0.5848544585, 0.508489761, 0.5241955346,
        0.4451322812, 0.5071443158, 0.4911079757,
        0.4416811435, 0.5434021974, 0.4420503732,
        0.4846776037, 0.5183013133, 0.4637692837,
        0.4494961178, 0.507312145, 0.5364240841,
        0.5228719171, 0.4708956331, 0.5452408371,
        0.565472036, 0.5845457287, 0.5860825396,
        0.4937634126, 0.6153237081, 0.5224226282,
        0.4429585009, 0.543793551, 0.4859600497,
        0.4778220444, 0.5652469751, 0.5102330395,
        0.418083857, 0.5765879686, 0.504648947,
        0.4231151427, 0.5102461621, 0.49780598,
        0.4329733075, 0.4162387429, 0.4077063205,
        0.4651514372, 0.5363397681, 0.4146043284,
        0.5399827372, 0.5322107973, 0.4968313562,
        0.4587441194, 0.4716514621, 0.5916059197,
        0.4497456639, 0.4116926438, 0.4322357342,
        0.5391672185, 0.4020952935, 0.4427455021,
        0.5352874883, 0.5316571999, 0.5197440786,
        0.5872076975, 0.5595593854, 0.513662551,
    };
    for(int i=0; i<MM; i++)
        diff_sq[i] = pow(phib[i] - phib_ref[i],2);
    error = sqrt(*std::max_element(diff_sq.begin(),diff_sq.end()));
    std::cout<< "Segment Concentration B error: "<< error << std::endl;
    if (std::isnan(error) || error > 1e-7)
        return -1;
    return 0;
}
