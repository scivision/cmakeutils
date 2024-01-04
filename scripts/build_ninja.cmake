cmake_minimum_required(VERSION 3.15)

execute_process(COMMAND mktemp -d OUTPUT_VARIABLE bindir OUTPUT_STRIP_TRAILING_WHITESPACE RESULT_VARIABLE ret)
if(NOT ret EQUAL 0)
  string(RANDOM LENGTH 6 r)
  set(bindir /tmp/build_${r})
endif()

set(args)
if(version)
  list(APPEND args -Dversion=${version})
endif()
if(prefix)
  list(APPEND args -DCMAKE_INSTALL_PREFIX:PATH=${prefix})
endif()

execute_process(COMMAND ${CMAKE_COMMAND} ${args}
-B${bindir}
-S${CMAKE_CURRENT_LIST_DIR}/build_ninja
RESULT_VARIABLE ret
)

if(ret EQUAL 0)
  message(STATUS "Ninja build")
else()
  message(FATAL_ERROR "Ninja failed to configure.")
endif()

execute_process(COMMAND ${CMAKE_COMMAND} --build ${bindir} --parallel
RESULT_VARIABLE ret
)

if(ret EQUAL 0)
  message(STATUS "Ninja install complete.")
else()
  message(FATAL_ERROR "Ninja failed to build and install.")
endif()
