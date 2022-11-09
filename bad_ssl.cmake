cmake_minimum_required(VERSION 3.19)

set(CMAKE_TLS_VERIFY ON)

# Get CMake's vendored cURL version
file(DOWNLOAD https://www.whatsmyua.info/api/v1/ua ua.json)
file(READ ua.json meta)
string(JSON ua GET ${meta} 0 ua rawUa)

message(STATUS "CMake ${CMAKE_VERSION}
cURL version: ${ua}
TLS_CAINFO: ${CMAKE_TLS_CAINFO}
SSL_CERT_FILE: $ENV{SSL_CERT_FILE}"
)


function(ssl url)

file(DOWNLOAD ${url} STATUS ret)

list(GET ret 0 status)
list(GET ret 1 msg)

message(STATUS "${url}:${status}: ${msg}")

endfunction(ssl)


message(STATUS "These tests should fail.")
ssl(https://expired.badssl.com/)
ssl(https://untrusted-root.badssl.com/)

message(STATUS "These tests should work OK.")
ssl(https://hsts.badssl.com/)
ssl(https://sha256.badssl.com/)
