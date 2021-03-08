cmake_minimum_required(VERSION 3.14...3.20)
project(demoMatlab LANGUAGES CXX Fortran)

include(CTest)

set(timeout 60)
# Matlab_MAIN_PROGRAM takes a long time to startup with lots of toolboxes

find_package(Matlab COMPONENTS MAIN_PROGRAM ENG_LIBRARY MX_LIBRARY)
if(NOT Matlab_FOUND)
  message(STATUS "SKIP: Matlab")
  return()
endif()


add_test(NAME BasicMatlab
COMMAND ${Matlab_MAIN_PROGRAM} -batch "r=runtests('${CMAKE_CURRENT_SOURCE_DIR}'); assertSuccess(r)")
set_tests_properties(BasicMatlab PROPERTIES TIMEOUT ${timeout})


include(matlab_include.cmake)
include(matlab_cpp.cmake)
include(matlab_fortran.cmake)
