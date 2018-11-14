[![Build Status](https://travis-ci.com/scivision/cmake-utils.svg?branch=master)](https://travis-ci.com/scivision/cmake-utils)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1488084.svg)](https://doi.org/10.5281/zenodo.1488084)

# CMake Utils

CMake is the most powerful and easy to use build system for a wide variety of languages including modern object-oriented Fortran 2018.
It's important to use a recent CMake version to be effective and clean with CMake script.

For those who need to download or upload files in any form, having SSL support is also important, as the vast majority of sites use HTTPS.
[cmake_setup.sh](./cmake_setup.sh) compiles with SSL.

## Install CMake

* MacOS: `brew install cmake`
* [Windows](https://cmake.org/download/)

### Linux

Linux systems including Cygwin and Windows Subsystem for Linux require:

* CentOS, Cygwin: `make gcc-c++ ncurses-devel openssl-devel`
* Debian, Ubuntu: `make g++ libncurses-dev libssl-dev`

and then run 
[cmake_setup.sh](./cmake_setup.sh) 
to install the most recent CMake **without sudo**

## Examples

* Download with [SSL](./ssl)
* Download and extract [ZIP](./zip)


## CMake modules

To avoid duplication, we have several scientific computing CMake modules in 
[scivision/fortran-libs](https://github.com/scivision/fortran-libs/tree/master/cmake/Modules) 
repo.
