# build and install a recent Ninja version

cmake_minimum_required(VERSION 3.19...3.28)

project(ninja LANGUAGES C CXX)

include(ExternalProject)

option(CMAKE_TLS_VERIFY "Verify TLS certs" on)

if(NOT version)
  file(READ ${CMAKE_CURRENT_LIST_DIR}/../versions.json _j)
  string(JSON version GET ${_j} ninja)
endif()

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  get_filename_component(p "~/ninja-${version}" ABSOLUTE)
  set(CMAKE_INSTALL_PREFIX ${p} CACHE PATH "install path" FORCE)
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
)
