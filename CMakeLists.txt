cmake_minimum_required(VERSION 3.0)
project(CMakeDemos
        LANGUAGES NONE)
        #DESCRIPTION "Demonstrate CMake usage"
        #HOMEPAGE_URL https://github.com/scivision/cmake-utils)
enable_testing()

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/Modules/)

add_subdirectory(ssl)
add_subdirectory(zip)

add_subdirectory(matlab)
add_subdirectory(octave)

add_subdirectory(system)
