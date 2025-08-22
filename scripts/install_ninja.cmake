cmake_minimum_required(VERSION 3.20...3.30)

include(FetchContent)
include(${CMAKE_CURRENT_LIST_DIR}/CMakeVar.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../functions/GithubRelease.cmake)


if(NOT DEFINED version)
  github_latest_release(ninja-build ninja version)
endif()

if(NOT prefix)
  set(prefix ~/ninja-${version})
endif()
get_filename_component(prefix ${prefix} ABSOLUTE)

file(MAKE_DIRECTORY ${prefix})

message(STATUS "CMake ${CMAKE_VERSION} installing Ninja ${version} in prefix ${prefix}")

set(host "https://github.com/ninja-build/ninja/releases/download/v${version}/")

string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" arch)

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  set(stem ninja-mac)
elseif(WIN32)
  if(arch STREQUAL "x86_64")
    set(stem ninja-win)
  elseif(arch STREQUAL "arm64")
    set(stem ninja-winarm64)
  endif()
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
 if(arch STREQUAL "x86_64")
    set(stem ninja-linux)
  elseif(arch STREQUAL "aarch64")
    set(stem ninja-linux-aarch64)
  endif()
endif()

if(NOT stem)
  message(FATAL_ERROR "unknown CPU arch ${arch}. Try building Ninja from source:
    cmake -P ${CMAKE_CURRENT_LIST_DIR}/build_ninja.cmake")
endif()

set(url ${host}${stem}.zip)

FetchContent_Populate(ninja
URL ${url}
SOURCE_DIR ${prefix}
)

find_program(exe
NAMES ninja
HINTS ${ninja_SOURCE_DIR}
NO_DEFAULT_PATH
)
if(NOT exe)
  message(FATAL_ERROR "failed to download Ninja ${version}")
endif()

message(STATUS "installed Ninja ${version} to ${prefix}")

set(ep $ENV{PATH})
if(NOT ep MATCHES "${prefix}")
  message(STATUS "add to environment variable CMAKE_PROGRAM_PATH ${prefix}")
endif()
