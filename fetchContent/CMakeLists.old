cmake_minimum_required(VERSION 3.0)
project(SSLdemo
        LANGUAGES NONE)
        #DESCRIPTION "Demonstrate that CMake SSL is installed and working"
        #HOMEPAGE_URL https://github.com/scivision/cmake-utils)

set(OUTFN ${CMAKE_CURRENT_BINARY_DIR}/github-mark.svg)

if(NOT EXISTS ${OUTFN})
  file(DOWNLOAD https://upload.wikimedia.org/wikipedia/commons/9/91/Octicons-mark-github.svg ${OUTFN}
     TIMEOUT 15
     EXPECTED_HASH MD5=07883e93734b98cae0f7b9c55d287250
     TLS_VERIFY ON
     )
endif()
