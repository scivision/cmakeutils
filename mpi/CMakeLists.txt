cmake_minimum_required(VERSION 3.10)
project(mpidemo Fortran)


find_package(MPI COMPONENTS Fortran)

if(NOT MPI_Fortran_FOUND)
  message(WARNING "MPI not found, skipping MPI tests.")
  return()
endif()

message("MPI command would start with:")
message("${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${MPIEXEC_MAX_NUMPROCS}
  ${MPIEXEC_PREFLAGS}")
