cmake_minimum_required(VERSION 3.15)

project(printer LANGUAGES NONE)

include(${CMAKE_CURRENT_LIST_DIR}/print_target_properties.cmake)

find_package(ZLIB)
if(ZLIB_FOUND)
  print_target_properties(ZLIB::ZLIB)
endif()
