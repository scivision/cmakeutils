cmake_minimum_required(VERSION 3.20)

include(FetchContent)
include(${CMAKE_CURRENT_LIST_DIR}/CMakeArchiveName.cmake)

if(NOT prefix)
  message(FATAL_ERROR "tell where to install CMake like:
    cmake -Dprefix=~/cmake-dev -P build_cmake.cmake")
endif()

expanduser(${prefix} prefix)

option(gui "build cmake-gui")
option(curses "build cmake-curses")

full_version("${version}")

set(url_stem "https://github.com/Kitware/CMake/releases/download/v${version}")

cmake_binary_url(${version} "source" ${prefix} ${url_stem})

set(url ${url_stem}/${archive})

FetchContent_Populate(CMAKE URL ${url} SOURCE_DIR ${prefix})

message(STATUS "Using CMake ${CMAKE_VERSION} to build CMake ${version} and install to ${prefix}")

set(cmake_args
-DBUILD_TESTING:BOOL=OFF
-DCMAKE_BUILD_TYPE=Release
-DCMAKE_USE_OPENSSL:BOOL=ON
-DBUILD_QtDialog:BOOL=${gui}
-DBUILD_CursesDialog:BOOL=${curses}
-DCMAKE_BUILD_LTO:BOOL=ON
-DCMAKE_INSTALL_PREFIX:PATH=${prefix}
)

set(builddir ${cmake_SOURCE_DIR}/build-cmake)

# avoid overloading CPU/RAM with extreme GNU Make --parallel
if(DEFINED ENV{CMAKE_BUILD_PARALLEL_LEVEL})
  set(N $ENV{CMAKE_BUILD_PARALLEL_LEVEL})
else()
  cmake_host_system_information(RESULT N QUERY NUMBER_OF_PHYSICAL_CORES)
endif()
message(STATUS "CMake build with ${N} workers")

execute_process(COMMAND ${CMAKE_COMMAND} ${cmake_args} -B${builddir} -S${cmake_SOURCE_DIR}
COMMAND_ERROR_IS_FATAL ANY
)

execute_process(COMMAND ${CMAKE_COMMAND} --build ${builddir} --parallel ${N}
COMMAND_ERROR_IS_FATAL ANY
)

execute_process(COMMAND ${CMAKE_COMMAND} --install ${builddir}
COMMAND_ERROR_IS_FATAL ANY
)
