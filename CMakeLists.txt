cmake_minimum_required(VERSION 3.20...3.27)

project(CMakeDemos
LANGUAGES C CXX
DESCRIPTION "Demonstrate CMake usage"
HOMEPAGE_URL https://github.com/scivision/cmake-utils)

enable_testing()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

option(CMAKE_TLS_VERIFY "Verify TLS certificates" ON)
set_directory_properties(PROPERTIES EP_UPDATE_DISCONNECTED true)

include(CheckLanguage)
check_language(Fortran)
if(CMAKE_Fortran_COMPILER)
  set(fortran on)
  enable_language(Fortran)
else()
  set(fortran off)
endif()

# --- auto-ignore build directory
file(GENERATE OUTPUT .gitignore CONTENT "*")

message(STATUS "CMake ${CMAKE_VERSION}")

add_subdirectory(autotools)

if(fortran)
  add_subdirectory(fetchContent)
endif()

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
