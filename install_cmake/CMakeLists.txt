# install a recent CMake version

cmake_minimum_required(VERSION 3.11...3.24)

project(cmake LANGUAGES NONE)

include(FetchContent)

# --- version
if(CMAKE_VERSION VERSION_LESS 3.19)
  set(version 3.23.2)
else()
  file(READ ${CMAKE_CURRENT_LIST_DIR}/../versions.json _j)

  if(version VERSION_LESS 3.1)
    string(JSON version GET ${_j} cmake latest)
  endif()

  # only major.minor specified -- default to latest release known.
  string(LENGTH ${version} L)
  if (L LESS 5)  # 3.x or 3.xx
    string(JSON version GET ${_j} cmake ${version})
  endif()
endif()

# --- URL
set(host https://github.com/Kitware/CMake/releases/download/v${version}/)

set(vname cmake-${version}-)

if(APPLE)

if(version VERSION_LESS 3.19)
  set(file_arch Darwin-x86_64)
else()
  set(file_arch macos-universal)
endif()

set(suffix .tar.gz)

elseif(UNIX)

if(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86_64")
  if(version VERSION_LESS 3.20)
    set(file_arch Linux-x86_64)
  else()
    set(file_arch linux-x86_64)
  endif()
elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "aarch64")
  if(version VERSION_LESS 3.20)
    set(file_arch Linux-aarch64)
  else()
    set(file_arch linux-aarch64)
  endif()
endif()

set(suffix .tar.gz)

elseif(WIN32)

if(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "ARM64")
  if(version VERSION_GREATER_EQUAL 3.24)
    set(file_arch windows-arm64)
  endif()
elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "AMD64")
  if(version VERSION_LESS 3.6)
    set(file_arch win32-x86)
  elseif(version VERSION_LESS 3.20)
    set(file_arch win64-x64)
  else()
    set(file_arch windows-x86_64)
  endif()
elseif(CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86")
  if(version VERSION_LESS 3.20)
    set(file_arch win32-x86)
  else()
    set(file_arch windows-i386)
  endif()
endif()

set(suffix .zip)

endif()


if(NOT file_arch)
  message(FATAL_ERROR "No CMake ${version} binary downwload available for ${arch}.
  Try building CMake from source:
    cmake -S ${CMAKE_CURRENT_LIST_DIR}/build_cmake -B build
  or use Python:
    pip install cmake
  or use Snap:
    snap install cmake")
endif()

set(stem ${vname}${file_arch})
set(name ${stem}${suffix})

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  get_filename_component(p ~ ABSOLUTE)
  set(CMAKE_INSTALL_PREFIX ${p} CACHE PATH "install path" FORCE)
endif()

set(path ${CMAKE_INSTALL_PREFIX}/${stem})

find_program(exe1
NAMES cmake
HINTS ${path}
PATH_SUFFIXES bin
NO_DEFAULT_PATH
)
if(exe1)
  message(STATUS "CMake already installed at ${exe1}")
  return()
endif()

set(url ${host}${name})

FetchContent_Declare(cmake
URL ${url}
TLS_VERIFY true
UPDATE_DISCONNECTED true
INACTIVITY_TIMEOUT 60
)

FetchContent_Populate(cmake)

file(MAKE_DIRECTORY ${path})
file(COPY ${cmake_SOURCE_DIR}/ DESTINATION ${path})
# must have trailing slash on source dir

# --- verify
find_program(exe2
NAMES cmake
HINTS ${path}
PATH_SUFFIXES bin
NO_DEFAULT_PATH
)
if(NOT exe2)
  message(FATAL_ERROR "failed to install CMake ${version} to ${path}")
endif()

message(STATUS "installed CMake ${version} to ${path}")

set(bindir ${path}/bin)

set(ep $ENV{PATH})
if(NOT ep MATCHES "${bindir}")
  message(STATUS "add to environment variable PATH ${bindir}")
endif()
