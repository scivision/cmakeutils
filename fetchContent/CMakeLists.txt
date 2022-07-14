cmake_minimum_required(VERSION 3.14...3.24)

project(FetchContent_Demo
LANGUAGES Fortran
DESCRIPTION "Demonstrate that CMake SSL is installed and working with FetchContent"
)

enable_testing()
# --- sub-projects
include(FetchContent)

FetchContent_Declare(child
GIT_REPOSITORY https://github.com/scivision/cmake-fetchcontent.git
GIT_TAG v1.3.0
GIT_SHALLOW true
INACTIVITY_TIMEOUT 60
TLS_VERIFY true
UPDATE_DISCONNECTED true  # avoid constant rebuild
)

FetchContent_MakeAvailable(child)

# -- main project
add_executable(test_timestwo_fc test_timestwo.f90)
target_link_libraries(test_timestwo_fc PRIVATE multiplier)

add_test(NAME TimesTwoFetch COMMAND test_timestwo_fc)

# -- data
# This MUST be a .zip, .tar, .tar.gz or similar archive, NOT just a file itself!
# extracted data files under:
# ${CMAKE_CURRENT_BINARY_DIR}/_deps/demodata-src/
FetchContent_Declare(demodata
URL https://github.com/scivision/cmake-fetchcontent/raw/main/octo.zip
URL_HASH SHA256=8a1df15d6ed7ae28ad872e5425adbcb31573ede1e84c21121a88de38a293bd97
INACTIVITY_TIMEOUT 60
TLS_VERIFY true
UPDATE_DISCONNECTED true
)
FetchContent_Populate(demodata)
