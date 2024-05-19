cmake_minimum_required(VERSION 3.19)

execute_process(COMMAND mktemp -d OUTPUT_VARIABLE bindir OUTPUT_STRIP_TRAILING_WHITESPACE RESULT_VARIABLE ret)
if(NOT ret EQUAL 0)
  string(RANDOM LENGTH 6 r)
  set(bindir /tmp/build_${r})
endif()

if(version)
  list(APPEND args -Dversion=${version})
endif()
if(prefix)
  list(APPEND args -DCMAKE_INSTALL_PREFIX:PATH=${prefix})
endif()

execute_process(COMMAND ${CMAKE_COMMAND} ${args}
-B${bindir}
-S${CMAKE_CURRENT_LIST_DIR}/build_ninja
COMMAND_ERROR_IS_FATAL ANY
)

execute_process(COMMAND ${CMAKE_COMMAND} --build ${bindir}
COMMAND_ERROR_IS_FATAL ANY
)
