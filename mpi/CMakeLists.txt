cmake_minimum_required(VERSION 3.10)
project(mpidemo LANGUAGES NONE)

include(CheckLanguage)
check_language(Fortran)
if(CMAKE_Fortran_COMPILER)
enable_language(Fortran)

find_package(MPI)

if(NOT MPI_FOUND)
  return()
endif()

message(STATUS "MPI command would start with:")
message(STATUS "${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${MPIEXEC_MAX_NUMPROCS}
  ${MPIEXEC_PREFLAGS}")

endif(CMAKE_Fortran_COMPILER)