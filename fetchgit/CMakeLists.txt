cmake_minimum_required(VERSION 3.11)
project(FetchContent_Demo
        LANGUAGES NONE
        DESCRIPTION "Demonstrate that CMake SSL is installed and working with FetchContent")
        #HOMEPAGE_URL https://github.com/scivision/cmake-utils) # 3.12

# --- sub-projects
include(FetchContent)

FetchContent_Declare(demo
  GIT_REPOSITORY https://github.com/scivision/hellofortran.git
  GIT_TAG 267e898
)

# this if() statement is canonical usage of FetchContent, to avoid repeatedly doing same thing in different parts of same project.
FetchContent_GetProperties(demo)
if(NOT demo_POPULATED)
  FetchContent_Populate(demo)
  # builds under bin/_deps/demo-build/
  add_subdirectory(${demo_SOURCE_DIR} ${demo_BINARY_DIR})
endif()

# -- data
# This MUST be a .zip, .tar, .tar.gz or similar archive, NOT just a file itself!
# you will find the extracted data files under bin/_deps/demodata-src/
FetchContent_Declare(demodata
  URL https://github.com/scivision/hellofortran/raw/master/octo.zip
  URL_HASH SHA256=8a1df15d6ed7ae28ad872e5425adbcb31573ede1e84c21121a88de38a293bd97
)
FetchContent_GetProperties(demodata)
if(NOT demodata_POPULATED)
  FetchContent_Populate(demodata)
endif()

