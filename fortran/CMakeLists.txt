cmake_minimum_required(VERSION 3.13.20190116)
project(minimumFortran Fortran)

include(CheckFortranSourceCompiles)
check_fortran_source_compiles("end" OKC SRC_EXT F90)

include(CheckFortranSourceRuns)
check_fortran_source_runs("end" OKR)

