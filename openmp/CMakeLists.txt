cmake_minimum_required(VERSION 3.9)
project(openmp_demo C)

# environment variable MKLROOT must be defined for MKL to be found, with any build system.

find_package(OpenMP COMPONENTS C REQUIRED)

add_executable(omp_c openmp_hello.c)
target_link_libraries(omp_c PRIVATE OpenMP::OpenMP_C)
