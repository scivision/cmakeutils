cmake_minimum_required(VERSION 3.13)

set(bindir ${CMAKE_CURRENT_LIST_DIR}/../build/cmake_install)

set(args)
if(version)
  list(APPEND args -Dversion=${version})
endif()
if(prefix)
  list(APPEND args -DCMAKE_INSTALL_PREFIX:PATH=${prefix})
endif()

execute_process(
COMMAND ${CMAKE_COMMAND} ${args}
-B${bindir}
-S${CMAKE_CURRENT_LIST_DIR}/install_cmake
RESULT_VARIABLE ret
)

if(ret EQUAL 0)
  message(STATUS "CMake install complete.")
else()
  message(FATAL_ERROR "CMake failed to install.")
endif()
