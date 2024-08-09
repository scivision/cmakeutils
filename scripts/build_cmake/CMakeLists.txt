# Most users should use install_cmake.cmake instead.
#
# builds and installs a recent CMake version
#
# NOTE: CMake 3.24 needs CMake >= 3.13 to build CMake itself.
# CMake 3.17 required for CMAKE_CURRENT_FUNCTION_LIST_DIR in CMakeArchiveName.cmake

cmake_minimum_required(VERSION 3.17...3.24)

project(cmake LANGUAGES C CXX)

include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/../CMakeArchiveName.cmake)

option(gui "build cmake-gui")

# --- main program ---

full_version("${version}")

message(STATUS "Using CMake ${CMAKE_VERSION} to build CMake ${version} and install to ${CMAKE_INSTALL_PREFIX}")

set(cmake_args
-DBUILD_TESTING:BOOL=OFF
-DCMAKE_BUILD_TYPE=Release
-DCMAKE_USE_OPENSSL:BOOL=ON
-DBUILD_QtDialog:BOOL=${gui}
-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
)

find_package(OpenSSL)
if(NOT OPENSSL_FOUND)
  find_program(brew NAMES brew)
  if(brew)
    execute_process(COMMAND ${brew} --prefix openssl
    OUTPUT_VARIABLE out
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE ret
    TIMEOUT 5
    )
    if(ret EQUAL 0)
      list(APPEND cmake_args -DOPENSSL_ROOT_DIR=${out})
    endif()
  endif()
endif()

set(url "https://github.com/Kitware/CMake/releases/download/v${version}/cmake-${version}.tar.gz")

message(STATUS "${url} => ${CMAKE_INSTALL_PREFIX}/bin")

ExternalProject_Add(CMAKE
URL ${url}
CMAKE_ARGS ${cmake_args}
TEST_COMMAND ""
UPDATE_DISCONNECTED true
CONFIGURE_HANDLED_BY_BUILD ON
USES_TERMINAL_DOWNLOAD true
USES_TERMINAL_UPDATE true
USES_TERMINAL_CONFIGURE true
USES_TERMINAL_BUILD true
USES_TERMINAL_INSTALL true
USES_TERMINAL_TEST true
)
