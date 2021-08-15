/*-------------------------------------------------------------
* This is a derived FftwPseudo class
*------------------------------------------------------------*/

#ifndef FFTW_PSEUDO_H_
#define FFTW_PSEUDO_H_

#include "Pseudo.h"

class FftwPseudo : public Pseudo
{

public:
    FftwPseudo(SimulationBox *sb, PolymerChain *pc);
    ~FftwPseudo();

    void find_phi(
        double *phia,  double *phib,
        double *q1_init, double *q2_init,
        double *wa, double *wb, double &QQ) override;
};
#endif
