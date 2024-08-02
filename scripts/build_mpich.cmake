# USAGE:
# cmake -Dprefix=~/mpi -P build_mpich.cmake
cmake_minimum_required(VERSION 3.20)

execute_process(COMMAND
  ${CMAKE_COMMAND} -Dargs=-Dmpich:BOOL=true
  -P ${CMAKE_CURRENT_LIST_DIR}/build_openmpi.cmake
)

# NOTE: to pass-through arguments, don't quote them
