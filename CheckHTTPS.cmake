cmake_minimum_required(VERSION 3.19)

option(bad "only do bad tests" off)
option(CMAKE_TLS_VERIFY "Verify TLS" on)

set(url_good
https://hsts.badssl.com
https://gitlab.kitware.com
https://github.com
https://dropbox.com
https://zenodo.org
https://bitbucket.org
https://box.com
https://www.zlib.net/
https://www.gnu.org/software/gcc/
https://drive.google.com
https://invisible-mirror.net/archives/ncurses/
https://sourceforge.net/projects/libisl/
https://gitlab.inria.fr/
https://www.python.org/downloads/source/
https://hg.nginx.org/pkg-oss/tags
)

set(url_fail
https://expired.badssl.com
https://wrong.host.badssl.com
https://self-signed.badssl.com
https://untrusted-root.badssl.com
https://revoked.badssl.com
https://null.badssl.com
)

# passes with CMake 3.26 due to cURL
# https://pinning-test.badssl.com
# https://tls-v1-0.badssl.com


# --- helper functions

function(user_agent)

# Get CMake's user agent
file(DOWNLOAD https://www.whatsmyua.info/api/v1/ua ua.json)
file(READ ua.json meta)
string(JSON ua GET ${meta} 0 ua rawUa)

message(STATUS "User agent: ${ua}")
if(DEFINED ENV{SSL_CERT_FILE})
  message(STATUS "SSL_CERT_FILE: $ENV{SSL_CERT_FILE}")
endif()

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.25)
  execute_process(COMMAND ${CMAKE_COMMAND} -E capabilities OUTPUT_VARIABLE cap)

  string(JSON has_tls GET ${cap} "tls")
  message(STATUS "TLS: ${has_tls}")
endif()

endfunction()


function(check_url url ok)

file(DOWNLOAD ${url}
LOG log
STATUS stat
INACTIVITY_TIMEOUT 15
)
message(STATUS "${url}  ${stat}")

list(GET stat 0 code)
if(code EQUAL 0)
  set(${ok} true PARENT_SCOPE)
else()
  set(${ok} false PARENT_SCOPE)
  message(NOTICE "${url}  ${stat}
  ${log}")
endif()

endfunction()

# --- main program

if(bad)
  set(url_good)
  message(STATUS "Skipping good URL tests")
endif()

if(WIN32)
  set(name "Windows $ENV{PROCESSOR_ARCHITECTURE}")
else()
  execute_process(COMMAND uname -ms OUTPUT_VARIABLE name OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()

message(STATUS "CMake ${CMAKE_VERSION}  ${name}")


user_agent()

foreach(u IN LISTS url_good)
  check_url(${u} ok)
  if(NOT ok)
    message(SEND_ERROR ${u})
  endif()
endforeach()


foreach(u IN LISTS url_fail)
  check_url(${u} ok)
  if(ok)
    message(SEND_ERROR "Bad URL should have failed: ${u}")
  endif()
endforeach()
