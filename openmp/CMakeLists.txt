cmake_minimum_required(VERSION 3.14)
project(openmp_demo LANGUAGES C)
enable_testing()

find_package(OpenMP COMPONENTS C)
if(NOT OpenMP_FOUND)
  message(STATUS "SKIP: OpenMP")
  return()
endif()

add_executable(omp_c openmp_hello.c)
target_link_libraries(omp_c PRIVATE OpenMP::OpenMP_C)
add_test(NAME OpenMP COMMAND omp_c)
