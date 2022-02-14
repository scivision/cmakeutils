#!/usr/bin/env -S cmake -P

# this script is to build and install a recent Ninja version
#
# cmake -P build_cmake.cmake
# will install Ninja under the user's home directory.

cmake_minimum_required(VERSION 3.21...3.23)

include(${CMAKE_CURRENT_LIST_DIR}/CheckNinja.cmake)

if(NOT prefix)
  set(prefix "~")
endif()

set(CMAKE_TLS_VERIFY true)

if(NOT version)
  file(READ ${CMAKE_CURRENT_LIST_DIR}/versions.json _j)
  string(JSON version GET ${_j} ninja latest)
endif()

string(JSON host GET ${_j} ninja source)
set(name v${version}.zip)

file(REAL_PATH ${prefix} prefix EXPAND_TILDE)
cmake_path(SET path ${prefix}/ninja-${version})

message(STATUS "installing Ninja ${version} to ${path}")

cmake_path(SET archive ${path}/${name})

set(url ${host}${name})
message(STATUS "download ${url} to ${archive}")
file(DOWNLOAD ${url} ${archive} INACTIVITY_TIMEOUT 15)

cmake_path(SET src_dir ${path}/ninja-${version})

message(STATUS "extracting ${archive} to ${path}")
file(ARCHIVE_EXTRACT INPUT ${archive} DESTINATION ${path})

file(MAKE_DIRECTORY ${src_dir}/build)

execute_process(
COMMAND ${CMAKE_COMMAND} -S${src_dir} -B${src_dir}/build -DBUILD_TESTING:BOOL=OFF -DCMAKE_BUILD_TYPE=Release --install-prefix=${path}
COMMAND_ERROR_IS_FATAL ANY
)

execute_process(COMMAND ${CMAKE_COMMAND} --build ${src_dir}/build --parallel
COMMAND_ERROR_IS_FATAL ANY
)

execute_process(COMMAND ${CMAKE_COMMAND} --install ${src_dir}/build
COMMAND_ERROR_IS_FATAL ANY
)

check_ninja(${path})
