cmake_minimum_required(VERSION 3.21...3.30)

include(FetchContent)

set(host https://github.com/ninja-build/ninja/releases/download/)

if(NOT version)
  file(READ ${CMAKE_CURRENT_LIST_DIR}/versions.json _j)
  string(JSON version GET ${_j} ninja)
endif()

if(NOT prefix)
  set(prefix ~/ninja-${version})
endif()
file(REAL_PATH ${prefix} prefix EXPAND_TILDE)

file(MAKE_DIRECTORY ${prefix})

message(STATUS "CMake ${CMAKE_VERSION}: prefix ${prefix}")

string(APPEND host "v${version}/")

get_property(cmake_role GLOBAL PROPERTY CMAKE_ROLE)
if(cmake_role STREQUAL "SCRIPT")
  set(CMAKE_PLATFORM_INFO_DIR ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY})
  # define CMAKE_HOST*, CMAKE_SYSTEM*, etc.
  include(${CMAKE_ROOT}/Modules/CMakeDetermineSystem.cmake)
  # set booleans like CYGWIN
  include(${CMAKE_ROOT}/Modules/CMakeSystemSpecificInitialize.cmake)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  set(stem ninja-mac)
elseif(WIN32)
  set(stem ninja-win)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  set(arch ${CMAKE_SYSTEM_PROCESSOR})
  string(TOLOWER "${arch}" arch)
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
  message(STATUS "add to environment variable PATH ${prefix}")
endif()
