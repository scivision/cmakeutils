cmake_minimum_required(VERSION 3.10)
project(mpidemo Fortran)


if(NOT hasParent)
  find_package(MPI REQUIRED COMPONENTS Fortran)
else()
  find_package(MPI COMPONENTS Fortran)
endif()

if(NOT MPI_Fortran_FOUND)
  return()
endif()

message("MPI command would start with:")
message("${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${MPIEXEC_MAX_NUMPROCS}
  ${MPIEXEC_PREFLAGS}")
