# Use / troubleshoot oneAPI with CMake, particularly for Windows.
cmake_minimum_required(VERSION 3.19)

set(CMAKE_EXECUTE_PROCESS_COMMAND_ECHO STDOUT)

# directories
if(NOT SOURCE)
  set(SOURCE ${CMAKE_CURRENT_SOURCE_DIR})
endif()

set(BUILD ${SOURCE}/build_oneapi)

if(DEFINED ENV{ONEAPI_ROOT})
  message(STATUS "ONEAPI_ROOT is set to $ENV{ONEAPI_ROOT}")
else()
  find_file(setvars NAMES setvars.sh setvars.bat
  PATHS
    ENV PROGRAMFILES
    ENV PROGRAMFILES(X86)
    /opt
    ENV HOME
  PATH_SUFFIXES intel/oneapi
  )
  if(setvars)
    message(STATUS "Please run setvars script ${setvars} and then rerun this script.")
    return()
  else()
    message(FATAL_ERROR "Could not find setvars.sh / setvars.bat script, is oneAPI installed?
https://www.intel.com/content/www/us/en/docs/oneapi/programming-guide/2023-2/oneapi-development-environment-setup.html")
  endif()
endif()

find_program(CMAKE_C_COMPILER
NAMES icx
HINTS $ENV{ONEAPI_ROOT}
)

find_program(CMAKE_CXX_COMPILER
NAMES icpx
HINTS $ENV{ONEAPI_ROOT}
)

find_program(CMAKE_Fortran_COMPILER
NAMES ifx
HINTS $ENV{ONEAPI_ROOT}
)

foreach(lang IN ITEMS C CXX Fortran)

  if(NOT CMAKE_${lang}_COMPILER)
    message(FATAL_ERROR "oneAPI ${lang}: compiler not found")
  endif()

  message(STATUS "${lang} Compiler: ${CMAKE_${lang}_COMPILER}")

endforeach()

# --- Generator

function(DownloadNinja)

if(APPLE)
  set(ninja_os mac)
elseif(WIN32)
  set(ninja_os win)
else()
  set(ninja_os linux)
endif()
set(ninja_file "ninja-${ninja_os}.zip")
set(ninja_url "https://github.com/ninja-build/ninja/releases/download/v1.11.1/${ninja_file}")

set(ninja_zip ${BUILD}/${ninja_file})
if(NOT EXISTS ${ninja_zip})
  message(STATUS "Did not find Ninja or Make, downloading ${ninja_url} => ${ninja_zip}")
  file(DOWNLOAD ${ninja_url} ${ninja_zip} TLS_VERIFY true INACTIVITY_TIMEOUT 30 SHOW_PROGRESS)
endif()

file(ARCHIVE_EXTRACT INPUT ${ninja_zip} DESTINATION ${BUILD} VERBOSE)
unset(CMAKE_MAKE_PROGRAM CACHE)

find_program(CMAKE_MAKE_PROGRAM NAMES ninja HINTS ${BUILD} NO_DEFAULT_PATH REQUIRED)
set(CMAKE_MAKE_PROGRAM ${CMAKE_MAKE_PROGRAM} PARENT_SCOPE)
set(CMAKE_GENERATOR "Ninja" ${PARENT_SCOPE})

endfunction()


if(DEFINED ENV{CMAKE_GENERATOR})
  set(CMAKE_GENERATOR $ENV{CMAKE_GENERATOR})
endif()

if(NOT CMAKE_GENERATOR)
  find_program(CMAKE_MAKE_PROGRAM NAMES ninja)
  if(CMAKE_MAKE_PROGRAM)
    set(CMAKE_GENERATOR "Ninja")
  elseif(WIN32)
    set(CMAKE_GENERATOR "MinGW Makefiles")
    find_program(CMAKE_MAKE_PROGRAM NAMES mingw32-make)
  else()
    set(CMAKE_GENERATOR "Unix Makefiles")
    find_program(CMAKE_MAKE_PROGRAM NAMES gmake make)
  endif()

  if(NOT CMAKE_MAKE_PROGRAM)
    DownloadNinja()
  endif()
endif()

if(NOT CMAKE_MAKE_PROGRAM)
  if(CMAKE_GENERATOR STREQUAL "Ninja")
    find_program(CMAKE_MAKE_PROGRAM NAMES ninja REQUIRED)
  else()
    find_program(CMAKE_MAKE_PROGRAM NAMES gmake mingw32-make make REQUIRED)
  endif()
endif()
message(STATUS "CMAKE_GENERATOR ${CMAKE_GENERATOR}  ${CMAKE_MAKE_PROGRAM}")

execute_process(COMMAND ${CMAKE_COMMAND}
-S${SOURCE}
-B${BUILD}
-DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
-DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
-DCMAKE_Fortran_COMPILER:FILEPATH=${CMAKE_Fortran_COMPILER}
-DCMAKE_GENERATOR:STRING=${CMAKE_GENERATOR}
-DCMAKE_MAKE_PROGRAM:FILEPATH=${CMAKE_MAKE_PROGRAM}
COMMAND_ERROR_IS_FATAL ANY
)

execute_process(COMMAND ${CMAKE_COMMAND} --build ${BUILD})
