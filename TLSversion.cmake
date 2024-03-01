cmake_minimum_required(VERSION 3.29)  # actually 3.30 when out of nightly

foreach(url IN ITEMS https://tls-v1-0.badssl.com:1010/ https://tls-v1-1.badssl.com:1011/ https://tls-v1-2.badssl.com:1012/)

file(DOWNLOAD ${url}
TLS_VERIFY on
TLS_VERSION 1.3
LOG log STATUS stat
)
list(GET stat 0 code)
if(code EQUAL 0)
  message(SEND_ERROR "${url} should fail")
endif()
message(STATUS "${url} status: ${stat}")
message(STATUS "${url} log: ${log}")

endforeach()


set(url https://hsts.badssl.com)
# badssl.com didn't yet have TLS v1.3
file(DOWNLOAD ${url} TLS_VERIFY on TLS_VERSION 1.2 LOG log STATUS stat)
list(GET stat 0 code)
if(NOT code EQUAL 0)
  message(SEND_ERROR "${url} should succeed")
endif()
message(STATUS "${url} status: ${stat}")
message(STATUS "${url} log: ${log}")
