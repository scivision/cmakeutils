cmake_minimum_required(VERSION 3.7)
project(minimumFortran NONE)

include(CheckLanguage)
check_language(Fortran)
if(CMAKE_Fortran_COMPILER)

  enable_language(Fortran)

  include(CheckFortranSourceCompiles)
  check_fortran_source_compiles("end" OK_Compile SRC_EXT F90)

  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.14)
    include(CheckFortranSourceRuns)
    check_fortran_source_runs("end" OK_Run)
  endif()

endif()