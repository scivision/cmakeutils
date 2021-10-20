# CMake Utils

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1488084.svg)](https://doi.org/10.5281/zenodo.1488084)
[![Language grade: Python](https://img.shields.io/lgtm/grade/python/g/scivision/cmakeutils.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/scivision/cmakeutils/context:python)
[![PyPi versions](https://img.shields.io/pypi/pyversions/cmakeutils.svg)](https://pypi.python.org/pypi/cmakeutils)
[![PyPi Download stats](http://pepy.tech/badge/cmakeutils)](http://pepy.tech/project/cmakeutils)

![Actions Status](https://github.com/scivision/cmakeutils/workflows/ci/badge.svg)

CMake is a powerful and easy to use build system for a wide variety of languages including:

* C / C++
* modern object-oriented Fortran 2008 / 2018
* Python
* pMatlab / GNU Octave](https://github.com/scivision/matlab-cmake-mex)

It's important to use a recent CMake version to be effective and clean with CMake script.
This can be done via the Python package described below, or from CMake >= 2.8.12 by:

```sh
cmake -P install_cmake.cmake
```

if you need to compile CMake from source, for example on BSD or ARM 32-bit using existing CMake >= 3.13:

```sh
cmake -P build_cmake.cmake
```

## Install

```sh
pip install cmakeutils
```

or

```sh
git clone https://github.com/scivision/cmakeutils
pip install -e cmakeutils
```

## convert CMake hierarchy .dot to SVG or PNG

CMake plots
[dependency graphs](https://www.scivision.dev/fortran-dependency-graph)
for programs like:

```sh
cmake -B build --graphviz=gfx/block.dot
```

Then convert to PNG or SVG like:

```sh
python -m cmakeutils.graph ~/myprog/gfx
```

## Install CMake binary

```sh
python -m cmakeutils.cmake_setup
```

takes only a minute to install binary and includes `cmake-gui`.
It works for Linux, MacOS, native Windows and Windows Subsystem for Linux.

Ninja is recommended in general for use with CMake on Windows, Mac and Linux:

```sh
python -m cmakeutils.ninja_setup
```

## Build CMake

CMake can be builts from source using either:

* older version of CMake,
* without CMake using the "bootstrap" method

The bootstrap method is only for Unix-like systems, while the CMake-based build can also be used on Windows.
Any platform for which Kitware doesn't distribute binaries use this script, including IBM Power and ARM.

```sh
python -m cmakeutils.cmake_compile
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
