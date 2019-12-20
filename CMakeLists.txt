cmake_minimum_required(VERSION 3.13)
project(CMakeDemos
        LANGUAGES NONE
        VERSION 1.5.0
        DESCRIPTION "Demonstrate CMake usage"
        HOMEPAGE_URL https://github.com/scivision/cmake-utils)
enable_testing()

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/Modules/)

add_subdirectory(fetchContent)
add_subdirectory(externalProject)

add_subdirectory(zip)

add_subdirectory(mpi)
add_subdirectory(openmp)

add_subdirectory(fortran)
add_subdirectory(matlab)
add_subdirectory(octave)

add_subdirectory(system)
