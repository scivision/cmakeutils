cmake_minimum_required(VERSION 3.3)
project(demoMatlab LANGUAGES NONE)
enable_testing()

set(timeout 60)  # Matlab_MAIN_PROGRAM takes a long time to startup with lots of toolboxes

find_package(Matlab COMPONENTS MAIN_PROGRAM ENG_LIBRARY MX_LIBRARY)
if(NOT Matlab_FOUND)
  return()
endif()

if(Matlab_MAIN_PROGRAM_FOUND)
  add_test(NAME BasicMatlab
    COMMAND ${Matlab_MAIN_PROGRAM} -batch "r=runtests(); exit(any([r.Failed]))"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
  set_tests_properties(BasicMatlab PROPERTIES TIMEOUT ${timeout})
endif()

include(matlab_include.cmake)

include(CheckLanguage)

check_language(CXX)
if(CMAKE_CXX_COMPILER)
  enable_language(CXX)
  include(matlab_cpp.cmake)
  matlab_cpp(${timeout} ${libenv})
endif(CMAKE_CXX_COMPILER)

check_language(Fortran)
if(CMAKE_Fortran_COMPILER)
  enable_language(Fortran)
  include(matlab_fortran.cmake)
  matlab_fortran(${timeout} ${libenv})
endif(CMAKE_Fortran_COMPILER)