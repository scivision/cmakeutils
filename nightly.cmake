# Download specified nightly binary archive and extract to home directory
#
# get latest nightly
#   cmake -P nightly.cmake
#
# specify date
#   cmake -Ddate=20240102 -P nightly.cmake
#
# specify install prefix
#   cmake -Dprefix=~/cmake -P nightly.cmake

cmake_minimum_required(VERSION 3.22)

include(FetchContent)

if(NOT date)
  string(TIMESTAMP date "%Y%m%d")
  math(EXPR date "${date} - 1")
endif()


if(NOT prefix)
  set(prefix "~/cmake-${date}")
endif()
file(REAL_PATH ${prefix} prefix EXPAND_TILDE)
file(MAKE_DIRECTORY ${prefix})
if(NOT IS_DIRECTORY ${prefix})
  message(FATAL_ERROR "prefix ${prefix} is not a directory")
endif()

if(WIN32)
  set(os "windows")
elseif(APPLE)
  set(os "macos")
else()
  set(os "linux")
endif()

get_property(cmake_role GLOBAL PROPERTY CMAKE_ROLE)
if(cmake_role STREQUAL "SCRIPT")
  set(CMAKE_PLATFORM_INFO_DIR ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY})
  # define CMAKE_HOST*, CMAKE_SYSTEM*, etc.
  include(${CMAKE_ROOT}/Modules/CMakeDetermineSystem.cmake)
  # set booleans like CYGWIN
  include(${CMAKE_ROOT}/Modules/CMakeSystemSpecificInitialize.cmake)
endif()

macro(cpu_arch)

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  set(arch "universal")
else()
  set(arch ${CMAKE_SYSTEM_PROCESSOR})
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

endmacro(cpu_arch)

cpu_arch()

if(UNIX)
  set(suffix .tar.gz)
else()
  set(suffix .zip)
endif()

set(pat ">(cmake-[1-9]+\.[0-9]+\.${date}-g[a-f0-9]+-${os}-${arch}${suffix})</a>")

message(VERBOSE "${pat}")

set(dev_url "https://cmake.org/files/dev/")
set(dev_index "${prefix}/index.html")
#if(NOT EXISTS ${dev_index})
file(DOWNLOAD ${dev_url} ${dev_index} SHOW_PROGRESS STATUS ret)
list(GET ret 0 status)
if(NOT status EQUAL 0)
  list(GET ret 1 msg)
  message(FATAL_ERROR "download ${dev_url} failed.
  Return code: ${status}
  Error: ${msg}"
  )
endif()
#endif()

file(STRINGS ${dev_index} lines REGEX "${pat}")
string(REGEX MATCH "${pat}" line "${lines}")
message(DEBUG "${lines}")
message(DEBUG "${line}")
if(NOT CMAKE_MATCH_COUNT GREATER 0)
  message(FATAL_ERROR "No binary available for date ${date}
  ${lines}
  ${line}"
  )
endif()

set(archive "${CMAKE_MATCH_1}")

set(url "https://cmake.org/files/dev/${archive}")

message(STATUS "${url} => ${prefix}")

FetchContent_Populate(cmake
URL ${url}
SOURCE_DIR ${prefix}
)
