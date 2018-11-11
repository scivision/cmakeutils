# CMake Utils

CMake is the most powerful and easy to use build system for a wide variety of languages including modern object-oriented Fortran 2018.
It's important to use a recent CMake version to be effective and clean with CMake script.

## Install CMake

* MacOS: `brew install cmake`
* [Windows](https://cmake.org/download/)

### Linux

Linux systems including Cygwin and Windows Subsystem for Linux require:

* CentOS, Cygwin: `make gcc-c++ ncurses-devel`
* Debian, Ubuntu: `make g++ libncurses-dev`

and then run 
[cmake_setup.sh](./cmake_setup.sh) 
to install the most recent CMake **without sudo**


## CMake modules

To avoid duplication, we have several scientific computing CMake modules in 
[scivision/fortran-libs](https://github.com/scivision/fortran-libs/tree/master/cmake/Modules) 
repo.
