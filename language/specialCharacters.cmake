# Pipe | and semicolon ; are not possible to use in CMake for paths due to
# implicit meanings to build tools (| pipe) or CMake (; lists)

file(READ "${CMAKE_CURRENT_LIST_DIR}/windows.txt" spec)
string(STRIP "${spec}" spec) # Remove trailing newline in input files
if(NOT WIN32)
  file(READ "${CMAKE_CURRENT_LIST_DIR}/unix.txt" spec2)
  string(STRIP "${spec2}" spec2)
  string(APPEND spec "${spec2}")
endif()

set(test "${CMAKE_CURRENT_BINARY_DIR}/${spec}")

message(STATUS "Testing path with special characters: ${test}")
file(TOUCH "${test}")

if(NOT EXISTS "${test}")
  message(FATAL_ERROR "Failed to detect path with special characters: ${spec}")
endif()
