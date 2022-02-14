cmake_minimum_required(VERSION 3.21...3.23)

file(READ ${CMAKE_CURRENT_LIST_DIR}/versions.json _j)
string(JSON zstd_version GET ${_j} zstd)

cmake_path(SET prefix "~/zstd-${zstd_version}")

set(CMAKE_TLS_VERIFY true)

if(DEFINED ENV{TMPDIR})
  cmake_path(SET tmpdir $ENV{TMPDIR})
elseif(IS_DIRECTORY /var/tmp)
  cmake_path(SET tmpdir /var/tmp)
elseif(IS_DIRECTORY /tmp)
  cmake_path(SET tmpdir /tmp)
else()
  cmake_path(SET tmpdir ~/tmp)
endif()

file(REAL_PATH ${tmpdir} tmpdir EXPAND_TILDE)

set(name zstd-${zstd_version}.tar.gz)
cmake_path(SET archive ${tmpdir}/${name})

cmake_path(SET src ${tmpdir}/zstd-${zstd_version}/build/cmake)
cmake_path(SET build ${src}/build)

if(NOT IS_DIRECTORY ${src})
  file(DOWNLOAD https://github.com/facebook/zstd/releases/download/v${zstd_version}/${name} ${archive}
  INACTIVITY_TIMEOUT 15
  )
  file(ARCHIVE_EXTRACT INPUT ${archive} DESTINATION ${tmpdir})
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
