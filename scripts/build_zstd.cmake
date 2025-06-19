cmake_minimum_required(VERSION 3.20)

include(${CMAKE_CURRENT_LIST_DIR}/../functions/GithubRelease.cmake)

if(NOT version)
  github_latest_release(facebook zstd zstd_version)
endif()

set(prefix "~/zstd-${zstd_version}")
get_filename_component(prefix ${prefix} ABSOLUTE)

set(name zstd-${zstd_version}.tar.gz)
set(archive ${prefix}/${name})

set(src ${prefix}/zstd-${zstd_version}/build/cmake)
set(build ${src}/build)

if(NOT IS_DIRECTORY ${src})
  file(DOWNLOAD
  https://github.com/facebook/zstd/releases/download/v${zstd_version}/${name}
  ${archive}
  )
  file(ARCHIVE_EXTRACT INPUT ${archive} DESTINATION ${prefix})
endif()

execute_process(COMMAND ${CMAKE_COMMAND} --install-prefix=${prefix} -S ${src} -B ${build}
COMMAND_ERROR_IS_FATAL ANY
)

execute_process(COMMAND ${CMAKE_COMMAND} --build ${build} --parallel
COMMAND_ERROR_IS_FATAL ANY
)

execute_process(COMMAND ${CMAKE_COMMAND} --install ${build}
COMMAND_ERROR_IS_FATAL ANY
)

message(STATUS "Please add ${CMAKE_INSTALL_PREFIX}/bin to environment variable PATH")
