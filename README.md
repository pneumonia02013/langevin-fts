# Deep Langevin FTS
Langevin Field-Theoretic Simulation (L-FTS) with Deep Learning

# Features
* Diblock Copolymer Melt
* 3D Periodic Boundaries  
* 1D, 2D Periodic Boundaries (for test purpose)
* Pseudospectral Implmentation using MKL, FFTW and CUDA
* Accelerating L-FTS using Deep Learning

# Dependencies
#### 1. C++ Compiler
  Any C++ compiler that supports C++11 standard or higher, but I recommend to use Intel compiler. They are free and faster than GCC. Install Intel oneAPI Base & HPC Toolkit.

#### 2. FFT Library
  The modified diffusion equations are solved by pseudospectral method, and that requires a fast Fourirer transform (FFT) library. You can choose from following FFT libraries.

+ **(optional) MKL**   
  Math kernel library (MKL) is bundled with Intel Compilers.  

+ **(optional) FFTW**   
  https://www.fftw.org/
  
+ **CUDA**  
  https://developer.nvidia.com/cuda-toolkit  
  
#### 3. (optional) OpenMP
  Two partial partition functions are calculated simultaneously using open multi-processing (OpenMP) in the CPU implemenation.  

#### 4. CMake 3.17+

#### 5. SWIG
  A tool that connects libraries written in C++ with Python    
  http://www.swig.org/

#### 6. Anaconda 3.x
  Anaconda is a distribution of the Python pogramming languages for scientific computing.  
  https://www.anaconda.com/

#### 7. PyTorch
  An open source machine learning framwork  
  https://pytorch.org/get-started/locally/
* * *
I tested this program under following environments.  
+ C++ Compilers
  + Intel oneAPI Base & Toolkit 2021.3.0   
  + The GNU Compiler Collection 7.5 
+ CUDA Toolkit 11.2
+ OpenMP bundled with Intel Compilers 2021.3.0

# Compile
  `git clone https://github.com/yongdd/Langevin_FTS_Public.git`  
  `cd Langevin_FTS_Public`  
  `mkdir build`  
  `cd build`  
  `cmake ../`  
  `make`  
* * *
  You can specify your building flags with following command.   
  `cmake ../  -DCMAKE_CXX_COMPILER=[Your CXX Compiler, e.g. "icpc", "g++"] \`   
  `-DCMAKE_INCLUDE_PATH=[Your FFTW Path]/include \`  
  `-DCMAKE_FRAMEWORK_PATH=[Your FFTW Path]/lib \`  
  `-DUSE_OPENMP=yes`
* * *
  Then copy `_langevinfts.so` and `langevinfts.py` to your folder.  
  In python, import the package by adding  `from langevinfts import *`.
# User Guide

# Developer Guide
  A few things you need to knows.  

+ **Object Oriented Programming (OOP)**  
    Basic concepts of OOP such as class, inheritance and dynamic binding.  
    In addtion, some design patterns. (class ParamParser, CudaCommon, AbstractFactory)
+ **CUDA Programming** (./platforms/cuda)  
    This is a introductory book written by NVIDIA members  
  https://developer.nvidia.com/cuda-example  
    Optimizing Parallel Reduction in CUDA  
  https://developer.download.nvidia.com/assets/cuda/files/reduction.pdf
+ **(optional) Parser** (class ParamParser)   
    I implemented a parser using regular expression (RE) and deterministic finite automaton (DFA) to read input parameters from a file. If you want to modify or improve syntax for parameter file, restart with standard approach using 'bison' and 'flex'.
  
# References
