# CMake 3.17 required for CMAKE_CURRENT_FUNCTION_LIST_DIR in CMakeArchiveName.cmake

cmake_minimum_required(VERSION 3.17...3.29)

include(FetchContent)
include(${CMAKE_CURRENT_LIST_DIR}/CMakeArchiveName.cmake)

option(CMAKE_TLS_VERIFY "Verify TLS certs")


function(cpu_arch)

if(WIN32)
  set(arch $ENV{PROCESSOR_ARCHITECTURE})
elseif(UNIX)
  execute_process(COMMAND uname -m OUTPUT_VARIABLE arch OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()

if(NOT arch)
  unknown_archive(${version} "unknown")
endif()

# system arch to arch index
string(TOLOWER ${arch} arch)
if(WIN32)
  if(arch STREQUAL "x86")
    set(arch "i386")
  elseif(arch STREQUAL "amd64")
    set(arch "x86_64")
  endif()
endif()

set(arch ${arch} PARENT_SCOPE)

endfunction(cpu_arch)

# --- main program ---

full_version("${version}")

if(NOT prefix)
  set(prefix ~/cmake-${version})
endif()
get_filename_component(prefix ${prefix} ABSOLUTE)

message(STATUS "Using CMake ${CMAKE_VERSION} to install CMake ${version} to ${prefix}")

set(CMAKE_FIND_APPBUNDLE LAST)

set(url_stem https://github.com/Kitware/CMake/releases/download/v${version})

cpu_arch()

message(STATUS "Download CMake ${version}  ${arch}")

if(CMAKE_VERSION VERSION_LESS 3.19 OR version VERSION_LESS 3.20)
  cmake_legacy_name("${arch}" "archive")
else()
  set(json_name cmake-${version}-files-v1.json)
  set(json_file ${prefix}/${json_name})
  set(json_url ${url_stem}/cmake-${version}-files-v1.json)

  message(STATUS "CMake ${version} metadata: ${json_url} => ${json_file}")
  file(DOWNLOAD ${json_url} ${json_file} STATUS ret LOG log)
  list(GET ret 0 stat)
  if(NOT stat EQUAL 0)
    list(GET ret 1 err)
    message(FATAL_ERROR "CMake metadata download failed: ${stat} ${err} ${log}")
  endif()

  cmake_archive_name(${version} ${json_file} "${arch}" "archive")

  set(_hash URL_HASH SHA256=${sha256})
endif()

FetchContent_Populate(cmake
URL ${url_stem}/${archive}
${_hash}
TLS_VERIFY ${CMAKE_TLS_VERIFY}
UPDATE_DISCONNECTED true
SOURCE_DIR ${prefix}
)

# --- verify
find_program(cmake_exe
NAMES cmake
HINTS ${prefix}
PATH_SUFFIXES bin CMake.app/Contents/bin
NO_DEFAULT_PATH
NO_CACHE
)
if(NOT cmake_exe)
  message(FATAL_ERROR "failed to install CMake ${version} to ${prefix}")
endif()

get_filename_component(bindir ${cmake_exe} DIRECTORY)
message(STATUS "installed CMake ${version} to ${bindir}")

set(ep $ENV{PATH})
if(NOT ep MATCHES "${bindir}")
  message(STATUS "add to environment variable PATH ${bindir}")
endif()
