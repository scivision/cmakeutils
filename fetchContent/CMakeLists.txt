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
GIT_TAG v1.4.0
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
FetchContent_Declare(demodata
URL https://raw.githubusercontent.com/scivision/cmake-fetchcontent/main/Octicons-mark-github.svg
URL_HASH SHA256=ed5b640553973a1739d5dfddbf9e2c3db64bcd7181f89e99db42e221e295cc3a
INACTIVITY_TIMEOUT 60
TLS_VERIFY true
UPDATE_DISCONNECTED true
DOWNLOAD_NO_EXTRACT true
DOWNLOAD_NAME ${CMAKE_CURRENT_BINARY_DIR}/octocat.svg
)
FetchContent_Populate(demodata)
