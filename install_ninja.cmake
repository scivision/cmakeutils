#!/usr/bin/env -S cmake -P

# this script is to install a recent Ninja version
#
# cmake -P install_ninja.cmake
# will install Ninja under the user's home directory.

cmake_minimum_required(VERSION 3.20...3.24)

include(${CMAKE_CURRENT_LIST_DIR}/CheckNinja.cmake)

if(NOT prefix)
  set(prefix "~")
endif()

set(CMAKE_TLS_VERIFY true)

file(READ ${CMAKE_CURRENT_LIST_DIR}/versions.json _j)

if(NOT version)
  string(JSON version GET ${_j} ninja latest)
endif()

string(JSON host GET ${_j} ninja binary)
set(host ${host}v${version}/)

if(APPLE)
  set(stem ninja-mac)
elseif(UNIX)
  execute_process(COMMAND uname -m
    OUTPUT_VARIABLE arch
    OUTPUT_STRIP_TRAILING_WHITESPACE
    TIMEOUT 5
    COMMAND_ERROR_IS_FATAL ANY)
  if(arch STREQUAL "x86_64")
    set(stem ninja-linux)
  endif()
elseif(WIN32)
  # https://docs.microsoft.com/en-us/windows/win32/winprog64/wow64-implementation-details?redirectedfrom=MSDN#environment-variables
  set(arch $ENV{PROCESSOR_ARCHITECTURE})
  if(arch STREQUAL "AMD64")
    set(stem ninja-win)
  endif()
endif()

if(NOT stem)
  message(FATAL_ERROR "unknown CPU arch ${arch}. Try building Ninja from source:
    cmake -P ${CMAKE_CURRENT_LIST_DIR}/build_ninja.cmake")
endif()

set(name ${stem}.zip)

if(CMAKE_VERSION VERSION_LESS 3.21)
  get_filename_component(prefix ${prefix} ABSOLUTE)
else()
  file(REAL_PATH ${prefix} prefix EXPAND_TILDE)
endif()
cmake_path(SET path ${prefix}/ninja-${version})

message(STATUS "installing Ninja ${version} to ${path}")

cmake_path(SET archive ${path}/${name})

set(url ${host}${name})
message(STATUS "download ${url} to ${archive}")
file(DOWNLOAD ${url} ${archive} INACTIVITY_TIMEOUT 60 STATUS ret)
list(GET ret 0 stat)
if(NOT stat EQUAL 0)
  list(GET ret 1 err)
  message(FATAL_ERROR "download failed: ${stat} ${err}")
endif()

message(STATUS "extracting to ${path}")
file(ARCHIVE_EXTRACT INPUT ${archive} DESTINATION ${path})

check_ninja(${path})
