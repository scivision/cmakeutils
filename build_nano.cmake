# download, build, install nano text editor
# requires Autotools and GNU Make

cmake_minimum_required(VERSION 3.19)

set(CMAKE_EXECUTE_PROCESS_COMMAND_ECHO STDOUT)

file(READ ${CMAKE_CURRENT_LIST_DIR}/scripts/versions.json _j)
string(JSON version GET ${_j} "nano")

set(stem nano-${version})
set(prefix "~/${stem}")
get_filename_component(prefix ${prefix} ABSOLUTE)

option(CMAKE_TLS_VERIFY "verify certificates" true)

execute_process(COMMAND mktemp -d OUTPUT_VARIABLE bindir OUTPUT_STRIP_TRAILING_WHITESPACE)

set(name ${stem}.tar.xz)
set(url https://nano-editor.org/dist/latest/${name})
set(archive ${bindir}/${name})

if(NOT EXISTS ${archive})
  message(STATUS "${url} => ${archive}")
  file(DOWNLOAD ${url} ${archive})
  file(ARCHIVE_EXTRACT INPUT ${archive} DESTINATION ${bindir})
endif()

set(src ${bindir}/${stem})

execute_process(COMMAND ${src}/configure --prefix ${prefix}
WORKING_DIRECTORY ${src}
COMMAND_ERROR_IS_FATAL ANY
)
# need WORKING_DIRECTORY to generate Makefile appropriately

execute_process(COMMAND make -j -C ${src} COMMAND_ERROR_IS_FATAL ANY)

execute_process(COMMAND make -j -C ${src} install COMMAND_ERROR_IS_FATAL ANY)

message(STATUS "Please add ${prefix}/bin to environment variable PATH")
