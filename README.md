# CMake Utils

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1488084.svg)](https://doi.org/10.5281/zenodo.1488084)

[![Actions Status](https://github.com/scivision/cmake-utils/workflows/ci_python/badge.svg)](https://github.com/scivision/cmake-utils/actions)

[![PyPi versions](https://img.shields.io/pypi/pyversions/cmakeutils.svg)](https://pypi.python.org/pypi/cmakeutils)
[![PyPi Download stats](http://pepy.tech/badge/cmakeutils)](http://pepy.tech/project/cmakeutils)

CMake is a powerful and easy to use build system for a wide variety of languages including:

* C / C++
* modern object-oriented Fortran 2008 / 2018
* Python
* Matlab / GNU Octave

It's important to use a recent CMake version to be effective and clean with CMake script.

## Install CMake

The Python script
[cmake_setup.py](./cmake_setup.py)
takes only a minute to install binary and includes `cmake-gui`.
It works for Linux, MacOS, native Windows and Windows Subsystem for Linux.

```sh
python cmake_setup.py
```

Note: new projects should consider
[Meson](http://www.mesonbuild.com)
instead of or in addition to CMake.
Meson can use CMake projects as subprojects (external projects).

## Build CMake

If you need to or desire to build CMake from source, this can be using an older version of CMake, or without CMake using the "bootstrap" method.
The bootstrap method is only for Unix-like systems, while the CMake-based build can also be used on Windows.

```sh
python cmake_compile.py
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

## CMake modules

To avoid duplication, we have several scientific computing CMake modules in
[scivision/fortran-libs](https://github.com/scivision/fortran-libs/tree/master/cmake/Modules)
repo.
