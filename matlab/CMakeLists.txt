cmake_minimum_required(VERSION 3.14)
project(demoMatlab LANGUAGES CXX Fortran)
enable_testing()

set(timeout 60)
# Matlab_MAIN_PROGRAM takes a long time to startup with lots of toolboxes

find_package(Matlab COMPONENTS MAIN_PROGRAM ENG_LIBRARY MX_LIBRARY)
if(NOT Matlab_FOUND)
  message(STATUS "SKIP: Matlab")
  return()
endif()

# this line can take a minute or more, so let's regex the MATLAB_ROOT_DIR
# matlab_get_version_from_matlab_run(${Matlab_MAIN_PROGRAM} matlab_versions)
string(REGEX MATCH "R([0-9][0-9][0-9][0-9][a-z])" Matlab_RELEASE ${Matlab_ROOT_DIR})
matlab_get_version_from_release_name(${Matlab_RELEASE} Matlab_VERSION)

if(Matlab_VERSION AND Matlab_VERSION VERSION_LESS 9.6)
  message(STATUS "Matlab >= R2019a required for -batch mode")
else()
  add_test(NAME BasicMatlab
  COMMAND ${Matlab_MAIN_PROGRAM} -batch "r=runtests(); exit(any([r.Failed]))"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
  set_tests_properties(BasicMatlab PROPERTIES TIMEOUT ${timeout})
endif()

include(matlab_include.cmake)
include(matlab_cpp.cmake)
include(matlab_fortran.cmake)
