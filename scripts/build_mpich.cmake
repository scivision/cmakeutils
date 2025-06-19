# USAGE:
# cmake -Dprefix=~/mpi -P build_mpich.cmake
cmake_minimum_required(VERSION 3.20)

set(args -Dmpich:BOOL=true)

if(prefix)
  list(APPEND args -Dprefix=${prefix})
endif()

if(mpi_url)
  list(APPEND args -Dmpi_url=${mpi_url})
elseif(version)
  list(APPEND args -Dversion=${version})
endif()

if(bindir)
  list(APPEND args -Dbindir=${bindir})
endif()

execute_process(COMMAND
  ${CMAKE_COMMAND} -Dargs=${args}
  -P ${CMAKE_CURRENT_LIST_DIR}/build_openmpi.cmake
)

# NOTE: to pass-through arguments, don't quote them
