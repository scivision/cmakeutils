# get CMake UserAgent
cmake_minimum_required(VERSION 3.14)
project(CMakeUserAgent LANGUAGES NONE)

set(url "https://www.whatismybrowser.com/detect/what-is-my-user-agent")

file(DOWNLOAD ${url} ${CMAKE_CURRENT_BINARY_DIR}/result.html)
# examine contents of result.html to find CMake UserAgent like
# curl/7.69.0
