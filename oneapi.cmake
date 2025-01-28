# Use to find oneAPI source script
# note that sourcing / running oneAPI script doesn't persist within CMake.
# have to source oneapi-vars.{bat,sh} before running CMake
#
# https://www.intel.com/content/www/us/en/docs/oneapi/programming-guide/2025-0/use-the-setvars-script-with-windows.html
# https://www.intel.com/content/www/us/en/docs/oneapi/programming-guide/2025-0/use-the-setvars-and-oneapi-vars-scripts-with-linux.html

cmake_minimum_required(VERSION 3.18)

if(DEFINED ENV{ONEAPI_ROOT})
  message(STATUS "ONEAPI_ROOT: $ENV{ONEAPI_ROOT}")
  message(STATUS "CMPLR_ROOT: $ENV{CMPLR_ROOT}")
  return()
endif()

if(WIN32)
  set(_n oneapi-vars.bat)
  set(_p $ENV{PROGRAMFILES\(X86\)}/intel/oneapi)
else()
  set(_n oneapi-vars.sh)
  set(_p /opt/intel/oneapi)
endif()

# Unified directory structure
# works for years 2020-2099
if(NOT DEFINED ENV{ONEAPI_ROOT})
  file(GLOB _g "${_p}/20[2-9][0-9].*/${_n}")
  message(DEBUG "oneAPI glob hints: ${_g}")
  foreach(_h IN LISTS _g)
    get_filename_component(_h "${_h}" DIRECTORY)
    list(APPEND _oneapi_hint_dirs "${_h}")
  endforeach()

  list(SORT _oneapi_hint_dirs COMPARE NATURAL ORDER DESCENDING)
endif()

find_file(setvars
NAMES ${_n}
HINTS $ENV{ONEAPI_ROOT} ${_oneapi_hint_dirs}
PATHS ${_p} $ENV{HOME}/intel/oneapi
REQUIRED
)

message(STATUS "run this script before running CMake to set up oneAPI environment:
${setvars}")
