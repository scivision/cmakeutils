cmake_minimum_required(VERSION 3.9)
project(openmp_demo C)

# This is INWORK, for now targeting Intel MKL only from GCC, Clang, PGI or ICPC.

# environment variable MKLROOT must be defined for MKL to be found, with any build system.

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/Modules)

find_package(OpenMP COMPONENTS C REQUIRED)

add_executable(omp_c openmp_hello.c)
target_link_libraries(omp_c PRIVATE OpenMP::OpenMP_C)
