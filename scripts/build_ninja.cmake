cmake_minimum_required(VERSION 3.20)

include(${CMAKE_CURRENT_LIST_DIR}/../functions/GithubRelease.cmake)
include(FetchContent)

if(NOT DEFINED version)
  github_latest_release(ninja-build ninja version)
endif()

if(NOT prefix)
  set(prefix ~/ninja-${version})
endif()

expanduser(${prefix} prefix)
set(bindir ${prefix}/build-ninja)

set(cmake_args
-DBUILD_TESTING:BOOL=OFF
-DCMAKE_BUILD_TYPE=Release
-DCMAKE_INSTALL_PREFIX:PATH=${prefix}
)

set(url https://github.com/ninja-build/ninja/archive/refs/tags/v${version}.tar.gz)

message(STATUS "installing Ninja ${version} to ${prefix}")

FetchContent_Populate(NINJA URL ${url} SOURCE_DIR ${prefix})

execute_process(COMMAND ${CMAKE_COMMAND} ${cmake_args} -B${bindir} -S${ninja_SOURCE_DIR}
COMMAND_ERROR_IS_FATAL ANY
)

execute_process(COMMAND ${CMAKE_COMMAND} --build ${bindir}
COMMAND_ERROR_IS_FATAL ANY
)

execute_process(COMMAND ${CMAKE_COMMAND} --install ${bindir}
COMMAND_ERROR_IS_FATAL ANY
)
