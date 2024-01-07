cmake_minimum_required(VERSION 3.19)

function(check_tls)
# some CMake may not have SSL/TLS enabled, or may have missing/broken system certificates.
# this is a publicly-usable service (as per their TOS)

set(url https://www.howsmyssl.com/a/check)
set(temp ${PROJECT_BINARY_DIR}/check_tls.json)

message(STATUS "CheckTLS: ${url} => ${temp}")
file(DOWNLOAD ${url} ${temp} INACTIVITY_TIMEOUT 5 TLS_VERIFY on)

file(READ ${temp} json)
string(JSON rating ERROR_VARIABLE e GET ${json} rating)

message(STATUS "CMake ${CMAKE_VERSION} TLS status: ${rating}")
if(NOT rating STREQUAL "Probably Okay")
  message(WARNING "TLS seems to be broken. Download will probably fail.  ${rating}")
endif()

endfunction(check_tls)

if(CMAKE_SCRIPT_MODE_FILE)
  check_tls()
endif()
