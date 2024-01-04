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

option(CMAKE_TLS_VERIFY "Verify TLS certificates" ON)

if(NOT date)
  string(TIMESTAMP date "%Y%m%d")
  math(EXPR date "${date} - 1")
endif()


if(NOT prefix)
  set(prefix "~/cmake-${date}")
endif()
file(REAL_PATH ${prefix} prefix EXPAND_TILDE)

if(WIN32)
  set(os "windows")
elseif(APPLE)
  set(os "macos")
else()
  set(os "linux")
endif()


function(cpu_arch)

if(APPLE)
  set(arch "universal")
elseif(WIN32)
  set(arch $ENV{PROCESSOR_ARCHITECTURE})
else()
  execute_process(COMMAND uname -m OUTPUT_VARIABLE arch OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
endif()

if(NOT arch)
  message(FATAL_ERROR "Unknown arch")
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

cpu_arch()

if(UNIX)
  set(suffix .tar.gz)
else()
  set(suffix .zip)
endif()

set(pat ">(cmake-[1-9]+\.[0-9]+\.${date}-g[a-f0-9]+-${os}-${arch}${suffix})</a>")

message(VERBOSE "${pat}")

set(dev_url "https://cmake.org/files/dev/")
#if(NOT EXISTS index.html)
file(DOWNLOAD ${dev_url} index.html SHOW_PROGRESS STATUS ret)
list(GET ret 0 status)
if(NOT status EQUAL 0)
  list(GET ret 1 msg)
  message(FATAL_ERROR "download ${dev_url} failed.
  Return code: ${status}
  Error: ${msg}"
  )
endif()
#endif()

file(STRINGS index.html lines REGEX "${pat}")
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
