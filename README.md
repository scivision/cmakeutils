# CMake Utils

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1488084.svg)](https://doi.org/10.5281/zenodo.1488084)

![Actions Status](https://github.com/scivision/cmakeutils/workflows/ci/badge.svg)

CMake is a powerful and easy to use build system for a wide variety of languages including:

* C / C++
* modern object-oriented Fortran 2008 / 2018
* Python
* [Matlab / GNU Octave](https://github.com/scivision/matlab-cmake-mex)

It's important to use a recent CMake version to be effective and clean with CMake script.
This can be done via the Python package described below, or from CMake >= 2.8.12 by:

```sh
cmake -P scripts/install_cmake.cmake
```

Ninja is recommended in general for use with CMake instead of Make:

```sh
cmake -P scripts/install_ninja.cmake
```

## convert CMake hierarchy .dot to SVG or PNG

CMake plots
[dependency graphs](https://www.scivision.dev/cmake-dependency-graph)
for programs like:

```sh
cmake -B build --graphviz=gfx/block.dot
```

Then convert to PNG or SVG like:

```sh
python graph.py ~/myprog/gfx
```

Convert the resulting index.html with the SVGs to PDF like:

```sh
cmake -Dhtml=~/myprog/gfx/index.html -P html2pdf.cmake
```

## Build CMake

To compile CMake from source, for example on BSD or ARM 32-bit using existing CMake:

```sh
cmake -S build_cmake -B build
```

Requirements:

* SSL library
* C++ compiler
* GNU Make or Ninja

## Examples

* Download with [git](./fetchgit) using [FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html)
* Download and extract [ZIP](./zip)
* measure [system](./system) parameters with CMake. Note Cygwin reports really small RAM and zero virtual memory.
