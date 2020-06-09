cmake_minimum_required(VERSION 3.14)
project(OpenCL-example LANGUAGES C CXX)
enable_testing()

find_package(OpenCL)
if(NOT OpenCL_FOUND)
  message(STATUS "SKIP: OpenCL")
  return()
endif()

set(CMAKE_REQUIRED_INCLUDES ${OpenCL_INCLUDE_DIRS})
set(CMAKE_REQUIRED_LIBRARIES ${OpenCL_LIBRARIES})
include(CheckCXXSourceCompiles)
if(APPLE)
  check_cxx_source_compiles("#include <OpenCL/cl.hpp>
  int main(void){ return 0; }" opencl_ok)
else()
  check_cxx_source_compiles("#include <CL/cl.hpp>
  int main(void){ return 0; }" opencl_ok)
endif()

if(NOT opencl_ok)
  message(STATUS "SKIP: OpenCL")
endif()

add_executable(opencl_hello hello2.cxx)
target_link_libraries(opencl_hello OpenCL::OpenCL)
target_compile_features(opencl_hello PRIVATE cxx_std_11)
add_test(NAME opencl:basic COMMAND opencl_hello)
set_tests_properties(opencl:basic PROPERTIES TIMEOUT 15)