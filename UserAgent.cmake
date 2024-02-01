# get CMake UserAgent (cURL version)
cmake_minimum_required(VERSION 3.19)

option(CMAKE_TLS_VERIFY "Enable TLS verification" ON)

set(url "https://www.whatsmyua.info/api/v1/ua")
set(file "${CMAKE_CURRENT_BINARY_DIR}/ua.json")

file(DOWNLOAD ${url} ${file})
# CMake UserAgent like curl/7.69.0
file(READ ${file} json)

string(JSON ua GET ${json} 0 "ua" "rawUa")

message(STATUS "CMake ${CMAKE_VERSION}
${ua}")
