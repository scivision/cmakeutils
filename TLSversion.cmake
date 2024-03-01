cmake_minimum_required(VERSION 3.29)  # actually 3.30 when out of nightly

message(STATUS "CMake version: ${CMAKE_VERSION}")

function(dl url tv)

file(DOWNLOAD ${url} TLS_VERIFY on TLS_VERSION ${tv} LOG log STATUS stat)

message(STATUS "${url} TLS v${tv} status: ${stat}")
message(VERBOSE "${url} TLS v${tv} log: ${log}")

endfunction(dl)


set(urls https://hsts.badssl.com https://tls-v1-2.badssl.com:1012/ https://tls-v1-1.badssl.com:1011/ https://tls-v1-0.badssl.com:1010/)
# badssl.com didn't yet have TLS v1.3

foreach(tv IN ITEMS 1.0 1.1 1.2 1.3)
    foreach(url IN LISTS urls)
        dl(${url} ${tv})
    endforeach()
endforeach()

# ~\cmake-20240228\bin/cmake -P .\TLSversion.cmake
# -- https://hsts.badssl.com TLS v1.0 status: 0;"No error"
# -- https://tls-v1-2.badssl.com:1012/ TLS v1.0 status: 0;"No error"
# -- https://tls-v1-1.badssl.com:1011/ TLS v1.0 status: 0;"No error"
# -- https://tls-v1-0.badssl.com:1010/ TLS v1.0 status: 0;"No error"
# -- https://hsts.badssl.com TLS v1.1 status: 0;"No error"
# -- https://tls-v1-2.badssl.com:1012/ TLS v1.1 status: 0;"No error"
# -- https://tls-v1-1.badssl.com:1011/ TLS v1.1 status: 0;"No error"
# -- https://tls-v1-0.badssl.com:1010/ TLS v1.1 status: 35;"SSL connect error"
# -- https://hsts.badssl.com TLS v1.2 status: 0;"No error"
# -- https://tls-v1-2.badssl.com:1012/ TLS v1.2 status: 0;"No error"
# -- https://tls-v1-1.badssl.com:1011/ TLS v1.2 status: 35;"SSL connect error"
# -- https://tls-v1-0.badssl.com:1010/ TLS v1.2 status: 35;"SSL connect error"
# -- https://hsts.badssl.com TLS v1.3 status: 35;"SSL connect error"
# -- https://tls-v1-2.badssl.com:1012/ TLS v1.3 status: 35;"SSL connect error"
# -- https://tls-v1-1.badssl.com:1011/ TLS v1.3 status: 35;"SSL connect error"
# -- https://tls-v1-0.badssl.com:1010/ TLS v1.3 status: 35;"SSL connect error"
