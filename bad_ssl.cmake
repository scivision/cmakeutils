cmake_minimum_required(VERSION 3.19)

set(CMAKE_TLS_VERIFY ON)

# Get CMake's vendored cURL version
file(DOWNLOAD https://www.whatsmyua.info/api/v1/ua ua.json)
file(READ ua.json meta)
string(JSON ua GET ${meta} 0 ua rawUa)

message(STATUS "CMake ${CMAKE_VERSION}
cURL version: ${ua}
TLS_CAINFO: ${CMAKE_TLS_CAINFO}
SSL_CERT_DIR: $ENV{SSL_CERT_DIR}
SSL_CERT_FILE: $ENV{SSL_CERT_FILE}"
)


function(ssl url retval)

file(DOWNLOAD ${url} STATUS ret LOG log)

list(GET ret 0 status)
list(GET ret 1 msg)

message(STATUS "${url}:${status}: ${msg}")

if(NOT status EQUAL 0)
  message(NOTICE "${log}")
endif()

set(${retval} ${status} PARENT_SCOPE)

endfunction(ssl)


message(STATUS "These tests should fail.")

foreach(url IN ITEMS https://expired.badssl.com/ https://untrusted-root.badssl.com/)
  ssl(${url} status)
  if(status EQUAL 0)
    message(SEND_ERROR "FAIL: ${url}")
  else()
    message(STATUS "OK: ${url}")
  endif()
endforeach()

message(STATUS "These tests should work OK.")
foreach(url IN ITEMS https://hsts.badssl.com/ https://sha256.badssl.com/)
  ssl(${url} status)
  if(status EQUAL 0)
    message(STATUS "OK: ${url}")
  else()
    message(SEND_ERROR "FAIL: ${url}")
  endif()
endforeach()
