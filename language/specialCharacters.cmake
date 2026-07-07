# Pipe | and semicolon ; are not possible to use in CMake for paths due to
# implicit meanings to build tools (| pipe) or CMake (; lists)

set(spec "`'~!@#$%^&()_-+={}[] ,.c")
if(NOT WIN32)
  string(APPEND spec "*:\"<>?")
endif()

set(test "${CMAKE_CURRENT_BINARY_DIR}/${spec}")

file(TOUCH "${test}")

if(NOT EXISTS "${test}")
  message(FATAL_ERROR "Failed to detect path with special characters: ${spec}")
endif()
