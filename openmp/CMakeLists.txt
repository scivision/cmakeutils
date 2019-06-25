cmake_minimum_required(VERSION 3.9)
project(openmp_demo LANGUAGES NONE)
enable_testing()

include(CheckLanguage)
check_language(C)
if(CMAKE_C_COMPILER)
  enable_language(C)

  find_package(OpenMP COMPONENTS C)
  if(NOT OpenMP_FOUND)
    return()
  endif()

  add_executable(omp_c openmp_hello.c)
  target_link_libraries(omp_c PRIVATE OpenMP::OpenMP_C)
  add_test(NAME OpenMP COMMAND omp_c)
endif()