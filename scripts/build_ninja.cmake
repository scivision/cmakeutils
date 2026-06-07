cmake_minimum_required(VERSION 3.19)

set(bindir ${prefix}/build-ninja)

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
