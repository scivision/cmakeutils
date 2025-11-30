# USAGE:
# cmake -Dprefix=~/mpi -P build_openmpi.cmake
cmake_minimum_required(VERSION 3.20)

if(prefix)
  list(APPEND args -DCMAKE_INSTALL_PREFIX:PATH=${prefix})
endif()

if(mpi_url)
  list(APPEND args -Dmpi_url=${mpi_url})
elseif(version)
  list(APPEND args -Dversion=${version})
endif()

if(NOT bindir)
  set(bindir /tmp/build_mpi)
endif()

execute_process(COMMAND ${CMAKE_COMMAND}
  ${args}
  -B${bindir}
  -S${CMAKE_CURRENT_LIST_DIR}/mpi
COMMAND_ERROR_IS_FATAL ANY
)

message(STATUS "MPI build in ${bindir}")


execute_process(COMMAND ${CMAKE_COMMAND} --build ${bindir}
COMMAND_ERROR_IS_FATAL ANY
)

message(STATUS "MPI install complete.")
