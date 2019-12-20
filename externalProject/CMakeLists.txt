# Example of using CMake ExternalProject
cmake_minimum_required(VERSION 3.1)
project(demoExtProj LANGUAGES C)
enable_testing()

include(ExternalProject)

ExternalProject_Add(Demo_proj
  GIT_REPOSITORY https://github.com/scivision/cmake-externalproject
  GIT_TAG master  # it's much better to use a specific Git revision or Git tag for reproducability
  INSTALL_COMMAND ""  # this disables the install step for the external project
)



ExternalProject_Get_Property(Demo_proj BINARY_DIR)
set(Demo_BINARY_DIR ${BINARY_DIR})

# ------- target_link_directories() is easier and more robust than this
# set(_prefix lib)
# set(_suffix .a)
# if(MSVC OR (WIN32 AND (CMAKE_C_COMPILER_ID STREQUAL Intel)))
#   set(_prefix)
#   set(_suffix .lib)
# endif()
# add_library(times_two STATIC IMPORTED)
# set_target_properties(times_two PROPERTIES IMPORTED_LOCATION ${Demo_BINARY_DIR}/${_prefix}times_two${_suffix})
# -------

add_executable(useext use_ext.c)
add_dependencies(useext Demo_proj)
target_link_libraries(useext PRIVATE times_two)
target_link_directories(useext PRIVATE ${Demo_BINARY_DIR})
# set_target_properties(useext PROPERTIES Fortran_MODULE_DIRECTORY ${BINARY_DIR})
add_test(NAME ExternalSubmodule COMMAND useext)

# NOTES:
#
# * target_link_directories() is easier than cross-platform specifying the full path
# https://cmake.org/cmake/help/latest/command/target_link_directories.html
#
# * add_dependencies() makes external project always update and build first
#
# * In the other project called by ExternalProject, I made all the targets have
#   set_target_properties(... PROPERTIES Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR})