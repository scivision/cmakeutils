# Use to find oneAPI source script
# note that sourcing / running oneAPI script doesn't persist within CMake.
# have to source oneapi-vars.{bat,sh} before running CMake
#
# https://www.intel.com/content/www/us/en/docs/oneapi/programming-guide/2025-0/use-the-setvars-script-with-windows.html
# https://www.intel.com/content/www/us/en/docs/oneapi/programming-guide/2025-0/use-the-setvars-and-oneapi-vars-scripts-with-linux.html

cmake_minimum_required(VERSION 3.20...4.3)

message(STATUS "ONEAPI_ROOT: $ENV{ONEAPI_ROOT}")
message(STATUS "CMPLR_ROOT: $ENV{CMPLR_ROOT}")
message(STATUS "MKLROOT: $ENV{MKLROOT}")

if(WIN32)
  set(_n oneapi-vars.bat)
  set(_p $ENV{PROGRAMFILES\(X86\)}/intel/oneapi)
else()
  set(_n oneapi-vars.sh)
  set(_p /opt/intel/oneapi)
endif()

if(DEFINED ENV{MKLROOT})
  file(REAL_PATH "$ENV{MKLROOT}/../.." _m)
  cmake_path(CONVERT _m TO_CMAKE_PATH_LIST _m)
endif()

# Unified directory structure
# works for years 2020-2099
file(GLOB _g "${_p}/20[2-9][0-9].*/${_n}")
if(DEFINED _m)
  file(GLOB _gr "${_m}/20[2-9][0-9].*/${_n}")
endif()

message(DEBUG "oneAPI glob hints: ${_g} ${_gr}")
foreach(_h IN LISTS _g _gr)
  cmake_path(GET _h PARENT_PATH _h_dir)
  list(APPEND _oneapi_hint_dirs "${_h_dir}")
endforeach()

list(SORT _oneapi_hint_dirs COMPARE NATURAL ORDER DESCENDING)


message(DEBUG "oneAPI hint dirs: ${_oneapi_hint_dirs}")

find_file(setvars
NAMES ${_n}
HINTS $ENV{ONEAPI_ROOT} ${_oneapi_hint_dirs}
PATHS ${_p} $ENV{HOME}/intel/oneapi
NO_DEFAULT_PATH
REQUIRED
)

message(STATUS "run this script before running CMake to set up oneAPI environment:
${setvars}")
