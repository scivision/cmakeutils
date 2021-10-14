# Example of using CMake ExternalProject
# this is more complicated than FetchContent, but completely isolates scopes unlike FetchContent
# Ninja requires BUILD_BYPRODUCTS, which requires a priori knowledge of the other project's directory structure
# Note how BUILD_BYPRODUCTS ${BINARY_DIR}/... couldn't be used because BINARY_DIR is populated by ExternalProject_Get_Property()

cmake_minimum_required(VERSION 3.19...3.22)
project(ExternalProject_Demo
  LANGUAGES Fortran
  DESCRIPTION "Demonstrate ExternalProject in Fortran")
enable_testing()

include(ExternalProject)

ExternalProject_Add(child_proj
  GIT_REPOSITORY https://github.com/scivision/cmake-externalproject.git
  GIT_TAG 35f1c97ab1f102e9b00d1d3241f53666856bb1a5
  INACTIVITY_TIMEOUT 15
  CONFIGURE_HANDLED_BY_BUILD true  # avoid constant reconfigure
  INSTALL_COMMAND ""  # disables the install step for the external project
  BUILD_BYPRODUCTS ${CMAKE_CURRENT_BINARY_DIR}/child_proj-prefix/src/child_proj-build/${CMAKE_STATIC_LIBRARY_PREFIX}timestwo${CMAKE_STATIC_LIBRARY_SUFFIX}
)
# in this scope, we have already set directory property EP_UPDATE_DISCONNECTED true
# to avoid constant rebuild of externalProjects

ExternalProject_Get_Property(child_proj BINARY_DIR)

# avoid race condition.
file(MAKE_DIRECTORY ${BINARY_DIR}/include)

add_library(timestwo STATIC IMPORTED GLOBAL)
add_dependencies(timestwo child_proj)
set_target_properties(timestwo PROPERTIES
  IMPORTED_LOCATION ${BINARY_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}timestwo${CMAKE_STATIC_LIBRARY_SUFFIX}
  INTERFACE_INCLUDE_DIRECTORIES ${BINARY_DIR}/include)
#
add_executable(test_timestwo test_timestwo.f90)
target_link_libraries(test_timestwo timestwo)
add_test(NAME ExternalProjectSubmodule COMMAND $<TARGET_FILE:test_timestwo>)
