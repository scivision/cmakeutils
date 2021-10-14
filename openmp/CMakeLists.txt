find_package(OpenMP COMPONENTS C)
if(NOT OpenMP_FOUND)
  message(STATUS "SKIP: OpenMP")
  return()
endif()

add_executable(omp_c openmp_hello.c)
target_link_libraries(omp_c OpenMP::OpenMP_C)
add_test(NAME OpenMP COMMAND omp_c)
