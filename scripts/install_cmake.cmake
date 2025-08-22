# CMake 3.17 required for CMAKE_CURRENT_FUNCTION_LIST_DIR in CMakeArchiveName.cmake

cmake_minimum_required(VERSION 3.17...3.30)

include(FetchContent)
include(${CMAKE_CURRENT_LIST_DIR}/CMakeArchiveName.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/CMakeVar.cmake)


macro(cpu_arch)

# system arch to arch index
string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" arch)

if(WIN32)
  if(arch STREQUAL "x86")
    set(arch "i386")
  elseif(arch STREQUAL "amd64")
    set(arch "x86_64")
  endif()
endif()

endmacro(cpu_arch)

# --- main program ---

if(DEFINED version)
  full_version("${version}")
else()
  github_latest_release(kitware cmake version)
endif()

if(NOT prefix)
  set(prefix ~/cmake-${version})
endif()
get_filename_component(prefix ${prefix} ABSOLUTE)

message(STATUS "Using CMake ${CMAKE_VERSION} to install CMake ${version} to ${prefix}")

set(url_stem "https://github.com/Kitware/CMake/releases/download/v${version}")

cpu_arch()

message(STATUS "Download CMake ${version}  ${arch}")

cmake_binary_url(${version} ${arch} ${prefix} ${url_stem})

FetchContent_Populate(cmake
URL ${url_stem}/${archive}
${cmake_hash}
UPDATE_DISCONNECTED true
SOURCE_DIR ${prefix}
)

# --- verify
find_program(cmake_exe
NAMES cmake
HINTS ${prefix}
PATH_SUFFIXES bin CMake.app/Contents/bin
NO_DEFAULT_PATH
)
if(NOT cmake_exe)
  message(FATAL_ERROR "failed to install CMake ${version} to ${prefix}")
endif()

get_filename_component(bindir ${cmake_exe} DIRECTORY)
message(STATUS "installed CMake ${version} to ${bindir}")

if(NOT "$ENV{PATH}" MATCHES "${bindir}")
  message(STATUS "add to environment variable PATH ${bindir}")
endif()
