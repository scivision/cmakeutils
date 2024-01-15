cmake_minimum_required(VERSION 3.19...3.28)

include(FetchContent)

option(CMAKE_TLS_VERIFY "Verify TLS certs" on)

set(host https://github.com/ninja-build/ninja/releases/download/)

if(NOT version)
  file(READ ${CMAKE_CURRENT_LIST_DIR}/versions.json _j)
  string(JSON version GET ${_j} ninja)
endif()

if(NOT prefix)
  set(prefix ~/ninja-${version})
endif()
get_filename_component(prefix ${prefix} ABSOLUTE)

string(APPEND host "v${version}/")

if(APPLE)
  set(stem ninja-mac)
elseif(WIN32)
  set(stem ninja-win)
elseif(UNIX)
  execute_process(COMMAND uname -m
  OUTPUT_VARIABLE arch OUTPUT_STRIP_TRAILING_WHITESPACE
  COMMAND_ERROR_IS_FATAL ANY
  )
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
TLS_VERIFY ${CMAKE_TLS_VERIFY}
UPDATE_DISCONNECTED true
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

get_filename_component(ninja_filename ${exe} NAME)


message(STATUS "installed Ninja ${version} to ${prefix}")

set(ep $ENV{PATH})
if(NOT ep MATCHES "${prefix}")
  message(STATUS "add to environment variable PATH ${prefix}")
endif()
