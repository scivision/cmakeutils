# Example of using CMake ExternalProject
# notice how this is much more complicated than FetchContent
# Ninja requires BUILD_BYPRODUCTS, which requires a priori knowledge of the other project's directory structure
# Note how BUILD_BYPRODUCTS ${BINARY_DIR}/... couldn't be used because BINARY_DIR is populated by ExternalProject_Get_Property()

cmake_minimum_required(VERSION 3.14)
project(parentExtProj LANGUAGES Fortran)
enable_testing()

include(ExternalProject)

ExternalProject_Add(child_proj
  GIT_REPOSITORY https://github.com/scivision/cmake-externalproject
  GIT_TAG master  # it's much better to use a specific Git revision or Git tag for reproducability
  INSTALL_COMMAND ""  # this disables the install step for the external project
  BUILD_BYPRODUCTS ${CMAKE_CURRENT_BINARY_DIR}/child_proj-prefix/src/child_proj-build/${CMAKE_STATIC_LIBRARY_PREFIX}timestwo${CMAKE_STATIC_LIBRARY_SUFFIX}
)

ExternalProject_Get_Property(child_proj BINARY_DIR)

# avoid race condition.
file(MAKE_DIRECTORY ${BINARY_DIR}/include)

add_library(timestwo STATIC IMPORTED GLOBAL)
set_target_properties(timestwo PROPERTIES
  IMPORTED_LOCATION ${BINARY_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}timestwo${CMAKE_STATIC_LIBRARY_SUFFIX}
  INTERFACE_INCLUDE_DIRECTORIES ${BINARY_DIR}/include)
#
add_executable(test_timestwo test_timestwo.f90)
add_dependencies(test_timestwo child_proj)
target_link_libraries(test_timestwo timestwo)
add_test(NAME ExternalProjectSubmodule COMMAND test_timestwo)
