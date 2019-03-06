cmake_minimum_required(VERSION 3.3)
project(lapack_demo C)

# This is INWORK, for now targeting Intel MKL only from GCC, Clang or ICPC.

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/Modules)

find_package(LAPACK COMPONENTS IntelPar)

if(NOT LAPACK_FOUND)
  return()
endif()

add_executable(svd_c example_gesvd.c)
target_link_libraries(svd_c PRIVATE ${LAPACK_LIBRARIES})
target_include_directories(svd_c PRIVATE ${LAPACK_INCLUDE_DIRS})
