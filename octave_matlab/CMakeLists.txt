cmake_minimum_required(VERSION 3.12)
project(CMakeDemos
        LANGUAGES NONE
        DESCRIPTION "Demonstrate Octave in CMake"
        HOMEPAGE_URL https://github.com/scivision/cmake-utils)
enable_testing()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/Modules/)

find_package(Octave REQUIRED)

add_test(NAME octave1
         COMMAND ${Octave_EXECUTABLE} -q --eval "runtests('${CMAKE_CURRENT_SOURCE_DIR}')"
         )
set_tests_properties(octave1 PROPERTIES
                     TIMEOUT 180
                    )
