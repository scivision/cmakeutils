cmake_minimum_required(VERSION 3.19)

get_filename_component(CMAKE_INSTALL_PREFIX ~/zstd ABSOLUTE)

if(DEFINED ENV{TMP})
  set(tmp $ENV{TMP})
elseif(DEFINED ENV{TMPDIR})
  set(tmp $ENV{TMPDIR})
else()
  set(tmp ~/tmp)
endif()

get_filename_component(tmp ${tmp} ABSOLUTE)

set(src ${tmp}/zstd/build/cmake)
set(build ${src}/build)

if(NOT IS_DIRECTORY ${src})
  find_package(Git REQUIRED)
  execute_process(COMMAND ${GIT_EXECUTABLE} -C ${tmp} clone https://github.com/facebook/zstd/
  COMMAND_ERROR_IS_FATAL ANY)
endif()

execute_process(COMMAND ${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX} -S ${src} -B ${build}
COMMAND_ERROR_IS_FATAL ANY)

execute_process(COMMAND ${CMAKE_COMMAND} --build ${build} --parallel
COMMAND_ERROR_IS_FATAL ANY)

execute_process(COMMAND ${CMAKE_COMMAND} --install ${build}
COMMAND_ERROR_IS_FATAL ANY)

message(STATUS "Please add ${CMAKE_INSTALL_PREFIX}/bin to environment variable PATH")
