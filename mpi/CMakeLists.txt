find_package(MPI COMPONENTS Fortran)

if(MPI_FOUND)
message(STATUS "MPI command would start with:")
message(STATUS "${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${MPIEXEC_MAX_NUMPROCS}
  ${MPIEXEC_PREFLAGS}")
endif(MPI_FOUND)
