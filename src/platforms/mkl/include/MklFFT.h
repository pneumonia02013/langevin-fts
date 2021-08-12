/* this module defines parameters and subroutines to conduct fast
* Fourier transform (FFT) using math kernel library(MKL). */

#ifndef MKL_FFT_H_
#define MKL_FFT_H_

#include <array>
#include <complex>
#include "mkl_service.h"
#include "mkl_dfti.h"

class MklFFT
{
private:

    double fft_normal_factor; //nomalization factor FFT
    int MM; // the number of total grids
    
    // pointers for forward and backward transform
    DFTI_DESCRIPTOR_HANDLE hand_forward = NULL;
    DFTI_DESCRIPTOR_HANDLE hand_backward = NULL;
public:

    MklFFT(std::array<int,3> nx);
    ~MklFFT();

    void forward (double *rdata, std::complex<double> *cdata);
    void backward(std::complex<double> *cdata, double *rdata);
};
#endif
