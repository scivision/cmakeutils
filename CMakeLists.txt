cmake_minimum_required(VERSION 3.20...3.24)

file(STRINGS ${CMAKE_CURRENT_SOURCE_DIR}/VERSION PROJECT_VERSION
  REGEX "^([0-9]+\.[0-9]+\.[0-9]+)" LIMIT_INPUT 16 LENGTH_MAXIMUM 16 LIMIT_COUNT 1)

project(CMakeDemos
LANGUAGES C CXX Fortran
VERSION ${PROJECT_VERSION}
DESCRIPTION "Demonstrate CMake usage"
HOMEPAGE_URL https://github.com/scivision/cmake-utils)

enable_testing()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules/)

set(CMAKE_TLS_VERIFY true)
set_directory_properties(PROPERTIES EP_UPDATE_DISCONNECTED true)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX ${PROJECT_BINARY_DIR} CACHE PATH "install path" FORCE)
endif()

# --- auto-ignore build directory
if(NOT EXISTS ${PROJECT_BINARY_DIR}/.gitignore)
  file(WRITE ${PROJECT_BINARY_DIR}/.gitignore "*")
endif()

message(STATUS "CMake ${CMAKE_VERSION}")

add_subdirectory(autotools)
add_subdirectory(fetchContent)
add_subdirectory(externalProject)

add_subdirectory(zip)

add_subdirectory(openmp)
add_subdirectory(opencl)

add_subdirectory(system)

add_subdirectory(syntax)

# --- demo target echo properties
# include(echo_target_properties.cmake)
# find_package(ZLIB)
# if(ZLIB_FOUND)
#   echo_target_properties(ZLIB::ZLIB)
# endif()
