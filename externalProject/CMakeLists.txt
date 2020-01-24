# Example of using CMake ExternalProject
# notice how this is much more complicated than FetchContent
# Ninja generator may not work with this on Windows, and BYPRODUCTS doesn't help
cmake_minimum_required(VERSION 3.14)
project(parentExtProj LANGUAGES Fortran)
enable_testing()

if(WIN32 AND CMAKE_GENERATOR STREQUAL "Ninja")
  message(STATUS "CMake ExternalProject and Ninja on Windows may not work")
  return()
endif()

include(ExternalProject)

ExternalProject_Add(child_proj
  GIT_REPOSITORY https://github.com/scivision/cmake-externalproject
  GIT_TAG master  # it's much better to use a specific Git revision or Git tag for reproducability
  INSTALL_COMMAND ""  # this disables the install step for the external project
)

ExternalProject_Get_Property(child_proj BINARY_DIR)

file(MAKE_DIRECTORY ${BINARY_DIR}/include)  # avoid race condition

add_library(timestwo STATIC IMPORTED GLOBAL)
set_target_properties(timestwo PROPERTIES
  IMPORTED_LOCATION ${BINARY_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}timestwo${CMAKE_STATIC_LIBRARY_SUFFIX}
  INTERFACE_INCLUDE_DIRECTORIES ${BINARY_DIR}/include)

add_executable(test_timestwo test_timestwo.f90)
add_dependencies(test_timestwo child_proj)
target_link_libraries(test_timestwo timestwo)
add_test(NAME ExternalSubmodule COMMAND test_timestwo)
