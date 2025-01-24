get_property(cmake_role GLOBAL PROPERTY CMAKE_ROLE)
if(cmake_role STREQUAL "SCRIPT")
  set(CMAKE_PLATFORM_INFO_DIR ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY})
  # define CMAKE_HOST*, CMAKE_SYSTEM*, etc.
  include(${CMAKE_ROOT}/Modules/CMakeDetermineSystem.cmake)
  # set booleans like CYGWIN
  include(${CMAKE_ROOT}/Modules/CMakeSystemSpecificInitialize.cmake)
endif()
