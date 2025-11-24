# get CMake UserAgent (cURL version)
function(user_agent)

# Get CMake's user agent
set(url https://www.whatsmyua.info/api/v1/ua)
set(file ${CMAKE_CURRENT_BINARY_DIR}/ua.json)

file(DOWNLOAD ${url} ${file} STATUS s)
list(GET s 0 ret)
if(NOT ret EQUAL 0)
  message(FATAL_ERROR "failed to get UserAgent from ${url}. ${s}")
endif()
# CMake UserAgent like curl/7.69.0
file(READ ${file} json)

string(JSON ua GET "${json}" 0 "ua" "rawUa")

message(STATUS "User agent: ${ua}")
if(DEFINED ENV{SSL_CERT_FILE})
    message(STATUS "SSL_CERT_FILE: $ENV{SSL_CERT_FILE}")
endif()

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.25)
    execute_process(COMMAND ${CMAKE_COMMAND} -E capabilities OUTPUT_VARIABLE cap)

    string(JSON has_tls GET ${cap} "tls")
    message(STATUS "TLS: ${has_tls}")
endif()

message(STATUS "CMake ${CMAKE_VERSION}
${ua}")

endfunction()


if(CMAKE_SCRIPT_MODE_FILE)
  user_agent()
endif()
