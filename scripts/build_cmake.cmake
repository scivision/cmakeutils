cmake_minimum_required(VERSION 3.13)

set(bindir ${CMAKE_CURRENT_LIST_DIR}/../build/cmake_build)

# need to remove cache to avoid corner cases
file(REMOVE ${bindir}/CMakeCache.txt)

set(args)
if(version)
  list(APPEND args -Dversion=${version})
endif()
if(prefix)
  list(APPEND args -DCMAKE_INSTALL_PREFIX:PATH=${prefix})
endif()
if(WIN32)
  list(APPEND args -G "MinGW Makefiles")
endif()

execute_process(COMMAND ${CMAKE_COMMAND} ${args}
-B${bindir}
-S${CMAKE_CURRENT_LIST_DIR}/build_cmake
RESULT_VARIABLE ret
)

# avoid overloading CPU/RAM with extreme GNU Make --parallel
cmake_host_system_information(RESULT N QUERY NUMBER_OF_PHYSICAL_CORES)

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
