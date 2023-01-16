# build and install a recent Ninja version

cmake_minimum_required(VERSION 3.15...3.25)

project(ninja LANGUAGES C CXX)

include(ExternalProject)

if(NOT version)
  if(CMAKE_VERSION VERSION_LESS 3.19)
    file(STRINGS ${CMAKE_CURRENT_SOURCE_DIR}/../version_ninja_latest.txt version
    REGEX "^([0-9]+\.[0-9]+\.[0-9]+)" LIMIT_INPUT 12 LENGTH_MAXIMUM 12 LIMIT_COUNT 1
    )
  else()
    file(READ ${CMAKE_CURRENT_LIST_DIR}/../versions.json _j)
    string(JSON version GET ${_j} ninja)
  endif()
endif()

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  get_filename_component(p ~ ABSOLUTE)
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
INACTIVITY_TIMEOUT 60
UPDATE_DISCONNECTED true
TLS_VERIFY true
CONFIGURE_HANDLED_BY_BUILD ON
)
