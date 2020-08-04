# CMake Utils

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1488084.svg)](https://doi.org/10.5281/zenodo.1488084)
[![Language grade: Python](https://img.shields.io/lgtm/grade/python/g/scivision/cmakeutils.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/scivision/cmakeutils/context:python)
[![PyPi versions](https://img.shields.io/pypi/pyversions/cmakeutils.svg)](https://pypi.python.org/pypi/cmakeutils)
[![PyPi Download stats](http://pepy.tech/badge/cmakeutils)](http://pepy.tech/project/cmakeutils)

![Actions Status](https://github.com/scivision/cmakeutils/workflows/ci_linux/badge.svg)
![Actions Status](https://github.com/scivision/cmakeutils/workflows/ci_mac/badge.svg)
![Actions Status](https://github.com/scivision/cmakeutils/workflows/ci_windows/badge.svg)

CMake is a powerful and easy to use build system for a wide variety of languages including:

* C / C++
* modern object-oriented Fortran 2008 / 2018
* Python
* Matlab / GNU Octave

It's important to use a recent CMake version to be effective and clean with CMake script.

```sh
pip install cmakeutils
```

or

```sh
git clone https://github.com/scivision/cmakeutils
pip install -e cmakeutils
```

## Install CMake binary

```sh
cmake_setup
```

takes only a minute to install binary and includes `cmake-gui`.
It works for Linux, MacOS, native Windows and Windows Subsystem for Linux.

Ninja is strongly recommended in general for use with CMake on Windows, Mac and Linux:

```sh
ninja_setup
```

## Build CMake

CMake can be builts from source using either:

* older version of CMake,
* without CMake using the "bootstrap" method

The bootstrap method is only for Unix-like systems, while the CMake-based build can also be used on Windows.
Any platform for which Kitware doesn't distribute binaries use this script, including IBM Power and ARM.

```sh
cmake_compile
```

This downloads the latest CMake release source and builds from scratch.

Requirements:

* SSL library
* C++ compiler
* GNU Make or Ninja

## Examples

* Download with [git](./fetchgit) using [FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html)
* Download and extract [ZIP](./zip)
* measure [system](./system) parameters with CMake. Note Cygwin reports really small RAM and zero virtual memory.

### GNU Octave

[Octave from CMake](./octave) via our
[FindOctave.cmake](./cmake/Modules/FindOctave.cmake)
works well from CMake for unit tests, liboctave, etc. for Octave &ge; 3.8.
We didn't try older versions of Octave.

### Matlab

One-time setup: if you've never used `mex` before, you must setup the C++ compiler.
It doesn't hurt to do this again if you're not sure.
From Matlab:

```matlab
mex -setup -client engine C++
```

Will ask you to select a compiler, or simply return:

> ENGINE configured to use 'g++' for C++ language compilation.
