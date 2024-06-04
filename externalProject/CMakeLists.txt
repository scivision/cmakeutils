# Example of using CMake ExternalProject
# this is more complicated than FetchContent, but completely isolates scopes unlike FetchContent
# Ninja requires BUILD_BYPRODUCTS, which requires a priori knowledge of the other project's directory structure
# Note how BUILD_BYPRODUCTS ${BINARY_DIR}/... couldn't be used because BINARY_DIR is populated by ExternalProject_Get_Property()

cmake_minimum_required(VERSION 3.19...3.28)

project(ExternalProject_Demo
LANGUAGES Fortran
DESCRIPTION "Demonstrate ExternalProject in Fortran"
)

enable_testing()

option(CMAKE_TLS_VERIFY "Verify TLS certificates" ON)

include(ExternalProject)
include(GNUInstallDirs)

if(BUILD_SHARED_LIBS)
  if(WIN32)
    set(tt_LIBRARY ${CMAKE_INSTALL_FULL_BINDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}multiplier${CMAKE_SHARED_LIBRARY_SUFFIX})
  else()
    set(tt_LIBRARY ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_SHARED_LIBRARY_PREFIX}multiplier${CMAKE_SHARED_LIBRARY_SUFFIX})
  endif()
else()
  set(tt_LIBRARY ${CMAKE_INSTALL_FULL_LIBDIR}/${CMAKE_STATIC_LIBRARY_PREFIX}multiplier${CMAKE_STATIC_LIBRARY_SUFFIX})
endif()

set(cmake_args
-DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}
)

ExternalProject_Add(child_proj
GIT_REPOSITORY https://github.com/scivision/cmake-externalproject.git
GIT_TAG v1.0.0
UPDATE_DISCONNECTED true
CONFIGURE_HANDLED_BY_BUILD true
BUILD_BYPRODUCTS ${tt_LIBRARY}
CMAKE_ARGS ${cmake_args}
)

file(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX}/include)

add_library(timestwo INTERFACE IMPORTED)
target_link_libraries(timestwo INTERFACE ${tt_LIBRARY})
target_include_directories(timestwo INTERFACE ${CMAKE_INSTALL_PREFIX}/include)
add_dependencies(timestwo child_proj)

# --- our current project

add_executable(test_timestwo test_timestwo.f90)
target_link_libraries(test_timestwo PRIVATE timestwo)

add_test(NAME ExternalProject COMMAND test_timestwo)
