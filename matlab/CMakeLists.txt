cmake_minimum_required(VERSION 3.3)
project(demoMatlab LANGUAGES NONE)
enable_testing()

set(MATLAB_TIMEOUT 60)  # Matlab takes a long time to startup with lots of toolboxes

if(NOT Matlab_MAIN_PROGRAM_FOUND)  # slow to find, doesn't cache !?
  find_package(Matlab COMPONENTS MAIN_PROGRAM)
endif()

if(Matlab_MAIN_PROGRAM_FOUND)
  add_test(NAME BasicMatlab
    COMMAND ${Matlab_MAIN_PROGRAM} -batch "r=runtests(); exit(any([r.Failed]))"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
  set_tests_properties(BasicMatlab PROPERTIES TIMEOUT ${MATLAB_TIMEOUT})
endif()

if(WIN32)
  set(libpath ${Matlab_ROOT_DIR}/bin/win64/)
   # no ospath on Windows
  set(libenv "PATH=${libpath};$ENV{PATH}")
elseif(APPLE)
  set(libpath ${Matlab_ROOT_DIR}/bin/maci64/)
  set(ospath ${Matlab_ROOT_DIR}/sys/os/maci64/)
  set(libenv "DYLD_LIBRARY_PATH=${libpath}:${ospath}:$ENV{DYLD_LIBRARY_PATH}")
elseif(UNIX)
  # https://www.mathworks.com/help/matlab/matlab_external/building-on-unix-operating-systems.html
  set(libpath ${Matlab_ROOT_DIR}/bin/glnxa64/)
  set(ospath ${Matlab_ROOT_DIR}/sys/os/glnxa64/)
  set(libenv "LD_LIBRARY_PATH=${libpath}:${ospath}:$ENV{LD_LIBRARY_PATH}")
else()
  return()
endif()

include(CheckLanguage)

check_language(CXX)
if(CMAKE_CXX_COMPILER)
  enable_language(CXX)
  include(matlab_cpp.cmake)
  matlab_cpp(${MATLAB_TIMEOUT} ${libenv})
endif(CMAKE_CXX_COMPILER)

check_language(Fortran)
if(CMAKE_Fortran_COMPILER)
  enable_language(Fortran)
  include(matlab_fortran.cmake)
  matlab_fortran(${MATLAB_TIMEOUT} ${libenv})
endif(CMAKE_Fortran_COMPILER)