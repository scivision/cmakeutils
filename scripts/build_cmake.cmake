cmake_minimum_required(VERSION 3.17)

execute_process(COMMAND mktemp -d OUTPUT_VARIABLE bindir OUTPUT_STRIP_TRAILING_WHITESPACE RESULT_VARIABLE ret)
if(NOT ret EQUAL 0)
  string(RANDOM LENGTH 6 r)
  set(bindir /tmp/build_${r})
endif()

set(args)
if(version)
  list(APPEND args -Dversion=${version})
endif()

if(NOT prefix)
  message(FATAL_ERROR "tell where to install CMake like:
    cmake -Dprefix=~/cmake-dev -P build_cmake.cmake")
endif()

execute_process(COMMAND ${CMAKE_COMMAND} ${args}
-B${bindir}
-S${CMAKE_CURRENT_LIST_DIR}/build_cmake
-DCMAKE_INSTALL_PREFIX:PATH=${prefix}
RESULT_VARIABLE ret
)

# avoid overloading CPU/RAM with extreme GNU Make --parallel
if(DEFINED ENV{CMAKE_BUILD_PARALLEL_LEVEL})
  set(N $ENV{CMAKE_BUILD_PARALLEL_LEVEL})
else()
  cmake_host_system_information(RESULT N QUERY NUMBER_OF_PHYSICAL_CORES)
endif()

if(ret EQUAL 0)
  message(STATUS "CMake build with ${N} workers")
else()
  message(FATAL_ERROR "CMake failed to configure.")
endif()

execute_process(COMMAND ${CMAKE_COMMAND} --build ${bindir} --parallel ${N}
RESULT_VARIABLE ret
)

if(ret EQUAL 0)
  message(STATUS "CMake install complete.")
else()
  message(FATAL_ERROR "CMake failed to build and install.")
endif()
