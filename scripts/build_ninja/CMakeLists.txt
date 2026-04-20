# build and install a recent Ninja version

cmake_minimum_required(VERSION 3.21)

project(ninja LANGUAGES C CXX)

include(ExternalProject)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  message(FATAL_ERROR "CMAKE_INSTALL_PREFIX is not set. Please set it to the desired installation directory.")
endif()

include(${CMAKE_CURRENT_LIST_DIR}/../../functions/GithubRelease.cmake)


if(NOT DEFINED version)
  github_latest_release(ninja-build ninja version)
endif()

set(cmake_args
-DBUILD_TESTING:BOOL=OFF
-DCMAKE_BUILD_TYPE=Release
-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
)

set(url https://github.com/ninja-build/ninja/archive/refs/tags/v${version}.tar.gz)

message(STATUS "installing Ninja ${version} to ${CMAKE_INSTALL_PREFIX}")

ExternalProject_Add(NINJA
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
)
