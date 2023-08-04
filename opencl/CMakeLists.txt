cmake_minimum_required(VERSION 3.14...3.23)

project(OpenCL-example LANGUAGES C CXX)

enable_testing()

set(CMAKE_CXX_STANDARD 11)

find_package(OpenCL)
if(NOT OpenCL_FOUND)
  message(STATUS "SKIP: OpenCL")
  return()
endif()

set(CMAKE_REQUIRED_INCLUDES)
set(CMAKE_REQUIRED_LIBRARIES OpenCL::OpenCL)
include(CheckIncludeFileCXX)
if(APPLE)
  check_include_file_cxx(OpenCL/cl.hpp opencl_ok)
else()
  check_include_file_cxx(CL/cl.hpp opencl_ok)
endif()

if(NOT opencl_ok)
  message(STATUS "SKIP: OpenCL")
  return()
endif()

add_executable(opencl_hello hello2.cxx)
target_link_libraries(opencl_hello OpenCL::OpenCL)

add_test(NAME opencl:basic COMMAND opencl_hello)
