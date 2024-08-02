cmake_minimum_required(VERSION 3.20)

project(MPItest LANGUAGES C Fortran)

enable_testing()

include(CheckSourceCompiles)

if(NOT DEFINED MPI_ROOT AND DEFINED ENV{MPI_ROOT})
  set(MPI_ROOT $ENV{MPI_ROOT})
endif()
if(MPI_ROOT)
  message(STATUS "Using MPI_ROOT=${MPI_ROOT}")
else()
  message(STATUS "MPI_ROOT not set, using default MPI search paths")
endif()

set(MPI_DETERMINE_LIBRARY_VERSION true)

find_package(MPI COMPONENTS C Fortran REQUIRED)

message(STATUS "${MPI_Fortran_LIBRARY_VERSION_STRING}")
message(STATUS "MPI libs: ${MPI_Fortran_LIBRARIES}")
message(STATUS "MPI include: ${MPI_Fortran_INCLUDE_DIRS}")
message(STATUS "MPI compile flags: ${MPI_Fortran_COMPILER_FLAGS}")
message(STATUS "MPI link flags: ${MPI_Fortran_LINK_FLAGS}")

if(MPI_Fortran_HAVE_F08_MODULE)
  return()
endif()

set(CMAKE_REQUIRED_LIBRARIES MPI::MPI_Fortran)

# sometimes factory FindMPI.cmake doesn't define this
message(CHECK_START "Checking for Fortran MPI-3 binding")
check_source_compiles(Fortran
[=[
program test
use mpi_f08, only : mpi_comm_rank, mpi_real, mpi_comm_world, mpi_init, mpi_finalize
implicit none
call mpi_init
call mpi_finalize
end program
]=]
MPI_Fortran_HAVE_F08_MODULE
)

if(MPI_Fortran_HAVE_F08_MODULE)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
  message(WARNING "MPI-3 Fortran module mpi_f08 not found, builds may fail.")
endif()

add_executable(test_mpi3 mpi3.f90)
target_link_libraries(test_mpi3 PRIVATE MPI::MPI_Fortran)

add_test(NAME test_mpi3 COMMAND test_mpi3)

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.29)
  set_property(TARGET test_mpi3 PROPERTY TEST_LAUNCHER ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${MPIEXEC_MAX_NUMPROCS})
else()
  set_property(TARGET test_mpi3 PROPERTY CROSSCOMPILING_EMULATOR ${MPIEXEC_EXECUTABLE} ${MPIEXEC_NUMPROC_FLAG} ${MPIEXEC_MAX_NUMPROCS})
endif()
