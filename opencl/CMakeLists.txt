cmake_minimum_required(VERSION 3.14)
project(OpenCL-example LANGUAGES C CXX)
enable_testing()

find_package(OpenCL)
if(NOT OpenCL_FOUND)
  message(STATUS "SKIP: OpenCL")
  return()
endif()

add_executable(opencl_hello hello2.cxx)
target_link_libraries(opencl_hello OpenCL::OpenCL)
add_test(NAME opencl:basic COMMAND opencl_hello)
set_tests_properties(opencl:basic PROPERTIES TIMEOUT 15)