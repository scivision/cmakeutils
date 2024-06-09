cmake_minimum_required(VERSION 3.14)

project(OpenCL-example LANGUAGES C CXX)

enable_testing()

find_package(OpenCL)
if(OpenCL_FOUND)
  find_path(cl_hpp NAMES CL/cl.hpp HINTS ${OpenCL_INCLUDE_DIRS})
  if(NOT cl_hpp)
    set(OpenCL_FOUND FALSE)
  endif()
endif()

if(NOT OpenCL_FOUND)
  message(STATUS "SKIP: OpenCL")
  return()
endif()

add_executable(opencl_hello hello2.cxx)
target_link_libraries(opencl_hello OpenCL::OpenCL)
target_compile_features(opencl_hello PUBLIC cxx_std_11)

add_test(NAME opencl:basic COMMAND opencl_hello)
