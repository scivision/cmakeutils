find_package(MPI COMPONENTS Fortran)

message(STATUS "MPI command would start with:")
message(STATUS "${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${MPIEXEC_MAX_NUMPROCS}
  ${MPIEXEC_PREFLAGS}")
