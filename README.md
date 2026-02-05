# CMake Utils

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1488084.svg)](https://doi.org/10.5281/zenodo.1488084)
[![ci](https://github.com/scivision/cmakeutils/actions/workflows/ci.yml/badge.svg)](https://github.com/scivision/cmakeutils/actions/workflows/ci.yml)

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

## Clean CMake build directories under root directory

CMake build directories might take 100s of MBs each for large projects.
To clean (optionally recursively) all CMake build directories under a root directory use:

```sh
uv run cmake_clean_build_dirs.py <root_dir> [--recursive] [--dryrun]
```

## convert CMake hierarchy .dot to SVG or PNG

CMake plots
[dependency graphs](https://www.scivision.dev/cmake-dependency-graph)
with a small [CMake script](https://www.scivision.dev/cmake-dependency-graph/):

```sh
cmake -B build --graphviz=graphviz/block.dot
```

Then convert to PNG or SVG like:

```sh
python cmake_dependency_graph.py ~/myprog/graphviz
```

Convert the resulting index.html with the SVGs to PDF like:

```sh
cmake -Dhtml=~/myprog/graphviz/index.html -P html2pdf.cmake
```

## CMake regular expressions

CMake [regular expressions](https://cmake.org/cmake/help/latest/command/string.html#regex-specification)
have a distinct syntax tied to the origins of CMake syntax in the late 1990s.
The CMake regex syntax is not the same as Python, Perl, etc.
We give a few examples under [regex](./regex).

## Using CMake to build Autotools projects

Examples of project using CMake ExternalProject are under [scripts/mpi](./scripts/mpi).
This project can be invoked to build OpenMPI or MPICH (each are Autotools projects):

```sh
cmake -S scripts/mpi -B build --install-prefix=$HOME/openmpi

cmake --build build
```

or by convenience scripts
[build_openmpi.cmake](./scripts/build_openmpi.cmake)
or
[build_mpich.cmake](./scripts/build_mpich.cmake).

## Build CMake itself

To compile CMake from source:

```sh
cmake -S scripts/build_cmake -B build

cmake --build build
```

Requirements:

* SSL library
* C++ compiler
* GNU Make or Ninja

## Examples

* Download with [git](./fetchgit) using [FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html)
* Download and extract [ZIP](./zip)
* measure [system](./system) parameters with CMake. Note Cygwin reports really small RAM and zero virtual memory.
