# Most users should use install_cmake.cmake instead.
#
# builds and installs a recent CMake version
#
# NOTE: CMake 3.24 needs CMake >= 3.13 to build CMake itself.

cmake_minimum_required(VERSION 3.13...3.29)

project(cmake LANGUAGES C CXX)

include(ExternalProject)

option(gui "build cmake-gui")

option(CMAKE_TLS_VERIFY "Verify TLS certs" on)

function(full_version)

if(version VERSION_LESS 3.5)
  if(CMAKE_VERSION VERSION_LESS 3.19)
    set(version 3.28.2)
  else()
    file(READ ${CMAKE_CURRENT_SOURCE_DIR}/../versions.json _j)
    string(JSON version GET ${_j} cmake latest)
  endif()
endif()

# only major.minor specified -- default to latest release known.
string(LENGTH ${version} L)
if (L LESS 5)  # 3.x or 3.xx
  string(JSON version GET ${_j} cmake ${version})
endif()

set(version ${version} PARENT_SCOPE)

endfunction(full_version)

# --- main program ---

full_version()

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  get_filename_component(p "~/cmake-${version}" ABSOLUTE)
  set(CMAKE_INSTALL_PREFIX ${p} CACHE PATH "install path" FORCE)
endif()

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

set(url https://gitlab.kitware.com/cmake/cmake.git)
set(tag v${version})

message(STATUS "install CMake ${tag} => ${CMAKE_INSTALL_PREFIX}/bin")

ExternalProject_Add(CMAKE
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
USES_TERMINAL_TEST true
)
