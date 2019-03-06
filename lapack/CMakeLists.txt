cmake_minimum_required(VERSION 3.3)
project(lapack_demo C)

# This targets Intel MKL from GCC, Clang, PGI or ICC.

# environment variable MKLROOT must be defined for MKL to be found, with any build system.

if(CMAKE_BUILD_TYPE STREQUAL Debug)
  add_compile_options(-g -O0)
else()
  add_compile_options(-O3)
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/Modules)

# this forces static libs, as an example. Not necessary in general.
if(NOT BUILD_SHARED_LIBS)
  set(CMAKE_FIND_LIBRARY_SUFFIXES .a .lib)
endif()

if(DEFINED ENV{MKLROOT})
  find_package(LAPACK COMPONENTS IntelPar REQUIRED)
else()
  message(WARNING "MKLROOT environment variable must be set to use Intel MKL")
  find_package(LAPACK REQUIRED)  # netlib
endif()

add_executable(svd_c example_gesvd.c)
target_include_directories(svd_c PRIVATE ${LAPACK_INCLUDE_DIRS})
if(NOT BUILD_SHARED_LIBS AND NOT WINDOWS)
  target_link_libraries(svd_c PRIVATE -Wl,--start-group ${LAPACK_LIBRARIES} -Wl,--end-group)
else()
  target_link_libraries(svd_c PRIVATE ${LAPACK_LIBRARIES})
endif()
