# FIXME: add an autotools-based ExternalProject to show these used
cmake_minimum_required(VERSION 3.14...3.20)
project(Autotools_detect LANGUAGES NONE)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/Modules/)

find_package(Autotools)
# this simply returns autotools_FOUND if all basic programs are detected.
