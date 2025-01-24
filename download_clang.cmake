# downloads and extracts Clang LLVM binaries if available
# not a robust script at all

cmake_minimum_required(VERSION 3.25...3.30)

include(FetchContent)

message(STATUS "CMake ${CMAKE_VERSION}")

set(head clang+llvm)

set(version 18.1.6)

if(NOT prefix)
  set(prefix ~/clang-${version})
endif()
get_filename_component(prefix ${prefix} ABSOLUTE)

if(NOT DEFINED n)
if(WIN32)
  set(n x86_64-pc-windows-msvc)
else()
  execute_process(COMMAND uname -m
  OUTPUT_VARIABLE unamem OUTPUT_STRIP_TRAILING_WHITESPACE
  COMMAND_ERROR_IS_FATAL ANY
  )
  execute_process(COMMAND uname -s
  OUTPUT_VARIABLE unames OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  if(unamem MATCHES "poweerpc")
    if(unames MATCHES "AIX")
      set(n powerpc64-ibm-aix-7.2)
    elseif(LINUX)
      set(n powerpc64le-linux-rhel-8.8)
    endif()
  endif()
endif()
endif()

if(NOT DEFINED n)
  message(FATAL_ERROR "unsupported platform")
endif()

set(tail .tar.xz)

set(url "https://github.com/llvm/llvm-project/releases/download/llvmorg-${version}/${head}-${version}-${n}${tail}")

message(STATUS "${url} => ${prefix}")

FetchContent_Populate(llvm
URL ${url}
SOURCE_DIR ${prefix}
)
