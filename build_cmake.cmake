#!/usr/bin/env -S cmake -P

# NOTE: most users should use install_cmake.cmake instead.
#
# this script builds and installs a recent CMake version
#
# cmake -P build_cmake.cmake
#
# will install CMake under the user's home directory.
#
# optionally, specify a specific CMake version like:
#   cmake -Dversion="3.13.5" -P install_cmake.cmake
#
# old CMake versions have broken file(DOWNLOAD)--they just "download" 0-byte files.
#
# NOTE: CMake 3.24 introduced need for CMake >= 3.13 to build CMake itself.
# The execute_process commands below also use Cmake >= 3.13 syntax.

cmake_minimum_required(VERSION 3.13...3.24)

# --- version
if(CMAKE_VERSION VERSION_LESS 3.19)
  set(version 3.23.2)
  set(host https://github.com/Kitware/CMake/archive/refs/tags/)
else()
  file(READ ${CMAKE_CURRENT_LIST_DIR}/versions.json _j)

  if(version VERSION_LESS 3.1)
    string(JSON version GET ${_j} cmake latest)
  endif()

  # only major.minor specified -- default to latest release known.
  string(LENGTH ${version} L)
  if (L LESS 5)  # 3.x or 3.xx
    string(JSON version GET ${_j} cmake ${version})
  endif()

  string(JSON host GET ${_j} cmake source)
endif()

# --- URL
set(host ${host}v${version}/)
set(stem cmake-${version})
set(name ${stem}.tar.gz)

# --- defaults

set(CMAKE_TLS_VERIFY true)

if(NOT prefix)
  get_filename_component(prefix ~ ABSOLUTE)
endif()


function(checkup exe)

get_filename_component(path ${exe} DIRECTORY)
set(ep $ENV{PATH})
if(NOT ep MATCHES ${path})
  message(STATUS "add to environment variable PATH ${path}")
endif()

endfunction(checkup)

get_filename_component(prefix ${prefix} ABSOLUTE)
set(path ${prefix}/${stem})

find_program(cmake NAMES cmake PATHS ${path} PATH_SUFFIXES bin NO_DEFAULT_PATH)
if(cmake)
  message(STATUS "CMake ${version} already at ${cmake}")

  checkup(${cmake})
  return()
endif()

message(STATUS "installing CMake ${version} to ${path}")

set(archive ${prefix}/${name})
set(url ${host}${name})
message(STATUS "download ${url}")
file(DOWNLOAD ${url} ${archive} INACTIVITY_TIMEOUT 15 STATUS ret)
list(GET ret 0 stat)
if(NOT stat EQUAL 0)
  list(GET ret 1 err)
  message(FATAL_ERROR "download failed: ${err}")
endif()

if(NOT IS_DIRECTORY ${path})
  message(STATUS "extracting to ${path}")
  if(CMAKE_VERSION VERSION_LESS 3.18)
    execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf ${archive} WORKING_DIRECTORY ${prefix})
  else()
    file(ARCHIVE_EXTRACT INPUT ${archive} DESTINATION ${prefix})
  endif()
endif()

file(MAKE_DIRECTORY ${path}/build)

execute_process(
COMMAND ${CMAKE_COMMAND} -S${path} -B${path}/build -DBUILD_TESTING:BOOL=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_USE_OPENSSL:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH=${path}
RESULT_VARIABLE err
)
if(NOT err EQUAL 0)
  message(FATAL_ERROR "failed to configure CMake")
endif()

execute_process(COMMAND ${CMAKE_COMMAND} --build ${path}/build --parallel
RESULT_VARIABLE err
)
if(NOT err EQUAL 0)
  message(FATAL_ERROR "failed to build CMake")
endif()

execute_process(COMMAND ${CMAKE_COMMAND} --build ${path}/build --target install
RESULT_VARIABLE err
)
if(NOT err EQUAL 0)
  message(FATAL_ERROR "failed to install CMake")
endif()

find_program(cmake NAMES cmake PATHS ${path} PATH_SUFFIXES bin NO_DEFAULT_PATH)
if(NOT cmake)
  message(FATAL_ERROR "failed to install CMake from ${archive}")
endif()

checkup(${cmake})
