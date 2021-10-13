#!/usr/bin/env -S cmake -P

# this script is to install a recent CMake version
# this handles the most common cases, but doesn't handle corner cases like 64-bit kernel with 32-bit user space
# CMAKE_HOST_SYSTEM_PROCESSOR, CMAKE_HOST_SYSTEM_NAME don't work in CMake script mode
#
#   cmake -P install_cmake.cmake
# will install CMake under the user's home directory.
#
# optionally, specify a specific CMake version like:
#   cmake -Dversion="3.13.5" -P install_cmake.cmake
#
# This script can be used to install CMake >= 3.7.
# old CMake versions have broken file(DOWNLOAD)--they just "download" 0-byte files.

cmake_minimum_required(VERSION 3.14...3.22)

set(CMAKE_TLS_VERIFY true)

if(NOT prefix)
  get_filename_component(prefix ~ ABSOLUTE)
endif()

if(version VERSION_LESS 3.7)
  file(STRINGS ${CMAKE_CURRENT_LIST_DIR}/src/cmakeutils/CMAKE_VERSION version
    REGEX "^([0-9]+\.[0-9]+\.[0-9]+)" LIMIT_INPUT 16 LENGTH_MAXIMUM 16 LIMIT_COUNT 1)
endif()

set(host https://github.com/Kitware/CMake/releases/download/v${version}/)

function(check_tls)
# some CMake may not have SSL/TLS enabled, or may have missing/broken system certificates.
# this is a publicly-usable service (as per their TOS)

set(url https://www.howsmyssl.com/a/check)
set(temp ${CMAKE_CURRENT_LIST_DIR}/test_ssl.json)

file(DOWNLOAD ${url} ${temp} INACTIVITY_TIMEOUT 5)
file(READ ${temp} json)

if(CMAKE_VERSION VERSION_LESS 3.19)
  string(REGEX MATCH "(\"rating\":\"Probably Okay\")" rating ${json})
else()
  string(JSON rating ERROR_VARIABLE e GET ${json} rating)
endif()

message(STATUS "TLS status: ${rating}")
if(NOT rating)
  message(WARNING "TLS seems to be broken on your system. Download will probably fail.  ${rating}")
endif()

endfunction(check_tls)


function(checkup exe)

get_filename_component(path ${exe} DIRECTORY)
set(ep $ENV{PATH})
if(NOT ep MATCHES ${path})
  message(STATUS "add to environment variable PATH ${path}")
endif()

endfunction(checkup)


check_tls()

if(APPLE)

find_program(brew
  NAMES brew
  PATHS /usr/local /opt/homebrew
  PATH_SUFFIXES bin)

if(brew)
  execute_process(COMMAND ${brew} install cmake)
else(brew)
  message(STATUS "please use Homebrew https://brew.sh to install cmake:
    brew install cmake
  or use Python:
    pip install cmake")
endif(brew)

return()

endif(APPLE)


if(UNIX)

execute_process(COMMAND uname -m
  OUTPUT_VARIABLE arch
  OUTPUT_STRIP_TRAILING_WHITESPACE
  TIMEOUT 5)

if(arch STREQUAL x86_64)
  if(version VERSION_LESS 3.20)
    set(stem cmake-${version}-Linux-x86_64)
  else()
    set(stem cmake-${version}-linux-x86_64)
  endif()
elseif(arch STREQUAL aarch64)
  if(version VERSION_LESS 3.20)
    set(stem cmake-${version}-Linux-aarch64)
  else()
    set(stem cmake-${version}-linux-aarch64)
  endif()
endif()

set(name ${stem}.tar.gz)

elseif(WIN32)

# https://docs.microsoft.com/en-us/windows/win32/winprog64/wow64-implementation-details?redirectedfrom=MSDN#environment-variables
# CMake doesn't currently have binary downloads for ARM64 or IA64
set(arch $ENV{PROCESSOR_ARCHITECTURE})

if(arch STREQUAL AMD64)
  if(version VERSION_LESS 3.20)
    set(stem cmake-${version}-win64-x64)
  else()
    set(stem cmake-${version}-windows-x86_64)
  endif()
elseif(arch STREQUAL x86)
  if(version VERSION_LESS 3.20)
    set(stem cmake-${version}-win32-x86)
  else()
    set(stem cmake-${version}-windows-i386)
  endif()
endif()

set(name ${stem}.zip)

endif()

if(NOT stem)
  message(FATAL_ERROR "unknown CPU arch ${arch}.  Try building CMake from source:
    cmake -P ${CMAKE_CURRENT_LIST_DIR}/build_cmake.cmake
  or use Python:
    pip install cmake")
endif()

get_filename_component(prefix ${prefix} ABSOLUTE)
set(path ${prefix}/${stem})

find_program(cmake NAMES cmake PATHS ${path} PATH_SUFFIXES bin NO_DEFAULT_PATH)
if(cmake)
  message(STATUS "CMake ${version} already at ${cmake}")

  checkup(${cmake})
  return()
endif()

message(STATUS "installing CMake ${version} to ${prefix}")

set(archive ${prefix}/${name})

if(EXISTS ${archive})
  file(SIZE ${archive} fsize)
  if(fsize LESS 1000000)
    file(REMOVE ${archive})
  endif()
endif()

if(NOT EXISTS ${archive})
  set(url ${host}${name})
  message(STATUS "download ${url}")
  file(DOWNLOAD ${url} ${archive} INACTIVITY_TIMEOUT 15)

  file(SIZE ${archive} fsize)
  if(fsize LESS 1000000)
    message(FATAL_ERROR "failed to download ${url}")
  endif()
endif()

message(STATUS "extracting to ${path}")
if(CMAKE_VERSION VERSION_LESS 3.18)
  execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf ${archive} WORKING_DIRECTORY ${prefix})
else()
  file(ARCHIVE_EXTRACT INPUT ${archive} DESTINATION ${prefix})
endif()

find_program(cmake NAMES cmake PATHS ${path} PATH_SUFFIXES bin NO_DEFAULT_PATH)
if(NOT cmake)
  message(FATAL_ERROR "failed to install CMake from ${archive}")
endif()

checkup(${cmake})
