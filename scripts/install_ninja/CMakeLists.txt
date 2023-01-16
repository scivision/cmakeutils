# install a recent Ninja version
cmake_minimum_required(VERSION 3.11...3.25)

project(ninja LANGUAGES NONE)

include(FetchContent)

if(NOT version)
  if(CMAKE_VERSION VERSION_LESS 3.19)
    file(STRINGS ${CMAKE_CURRENT_SOURCE_DIR}/../version_ninja_latest.txt version
    REGEX "^([0-9]+\.[0-9]+\.[0-9]+)" LIMIT_INPUT 12 LENGTH_MAXIMUM 12 LIMIT_COUNT 1
    )
  else()
    file(READ ${CMAKE_CURRENT_LIST_DIR}/../versions.json _j)
    string(JSON version GET ${_j} ninja)
  endif()
endif()

set(host https://github.com/ninja-build/ninja/releases/download/v${version}/)

if(APPLE)
  set(stem ninja-mac)
elseif(UNIX)
  if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
    set(stem ninja-linux)
  endif()
elseif(WIN32)
  if(CMAKE_SYSTEM_PROCESSOR STREQUAL "AMD64")
    set(stem ninja-win)
  endif()
endif()

if(NOT stem)
  message(FATAL_ERROR "unknown CPU arch ${arch}. Try building Ninja from source:
    cmake -P ${CMAKE_CURRENT_LIST_DIR}/build_ninja.cmake")
endif()

set(url ${host}${stem}.zip)

FetchContent_Declare(ninja
URL ${url}
TLS_VERIFY true
UPDATE_DISCONNECTED true
INACTIVITY_TIMEOUT 60
)

FetchContent_Populate(ninja)

find_program(exe
NAMES ninja
HINTS ${ninja_SOURCE_DIR}
NO_DEFAULT_PATH
)
if(NOT exe)
  message(FATAL_ERROR "failed to download Ninja ${version}")
endif()


get_filename_component(ninja_filename ${exe} NAME)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  get_filename_component(p ~/ninja-${version} ABSOLUTE)
  set(CMAKE_INSTALL_PREFIX ${p} CACHE PATH "install path" FORCE)
endif()

file(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX})
file(COPY ${exe} DESTINATION ${CMAKE_INSTALL_PREFIX}/)

message(STATUS "installed Ninja ${version} to ${CMAKE_INSTALL_PREFIX}")

set(ep $ENV{PATH})
if(NOT ep MATCHES "${CMAKE_INSTALL_PREFIX}")
  message(STATUS "add to environment variable PATH ${CMAKE_INSTALL_PREFIX}")
endif()
