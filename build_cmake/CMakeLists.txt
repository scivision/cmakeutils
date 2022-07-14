# Most users should use install_cmake.cmake instead.
#
# builds and installs a recent CMake version
#
# NOTE: CMake 3.24 needs CMake >= 3.13 to build CMake itself.

cmake_minimum_required(VERSION 3.13...3.24)

project(cmake LANGUAGES C CXX)

include(ExternalProject)

# --- version
if(CMAKE_VERSION VERSION_LESS 3.19)
  set(version 3.23.2)
else()
  file(READ ${CMAKE_CURRENT_LIST_DIR}/../versions.json _j)

  if(version VERSION_LESS 3.1)
    string(JSON version GET ${_j} cmake latest)
  endif()

  # only major.minor specified -- default to latest release known.
  string(LENGTH ${version} L)
  if (L LESS 5)  # 3.x or 3.xx
    string(JSON version GET ${_j} cmake ${version})
  endif()
endif()

# --- CMake build arguments
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  get_filename_component(p ~ ABSOLUTE)
  set(CMAKE_INSTALL_PREFIX ${p} CACHE PATH "install path" FORCE)
endif()

set(cmake_args
-DBUILD_TESTING:BOOL=OFF
-DCMAKE_BUILD_TYPE=Release
-DCMAKE_USE_OPENSSL:BOOL=ON
-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
)

set(url https://gitlab.kitware.com/cmake/cmake.git)
set(tag v${version})

message(STATUS "installing CMake ${tag} to ${CMAKE_INSTALL_PREFIX}")

ExternalProject_Add(CMAKE
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

message(STATUS "Next run command:
cmake --build ${CMAKE_BINARY_DIR}

and add to environment variable PATH:

${CMAKE_INSTALL_PREFIX}/bin
")
