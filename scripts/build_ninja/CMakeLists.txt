# build and install a recent Ninja version

cmake_minimum_required(VERSION 3.21)

project(ninja LANGUAGES C CXX)

include(ExternalProject)

include(${CMAKE_CURRENT_LIST_DIR}/../../functions/GithubRelease.cmake)


if(NOT DEFINED version)
  github_latest_release(ninja-build ninja version)
endif()

set(cmake_args
-DBUILD_TESTING:BOOL=OFF
-DCMAKE_BUILD_TYPE=Release
-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
)

set(url https://github.com/ninja-build/ninja.git)
set(tag v${version})

message(STATUS "installing Ninja ${tag} to ${CMAKE_INSTALL_PREFIX}")

ExternalProject_Add(NINJA
GIT_REPOSITORY ${url}
GIT_TAG ${tag}
GIT_SHALLOW true
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
