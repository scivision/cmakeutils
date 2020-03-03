cmake_minimum_required(VERSION 3.0)
project(ZIPdemo
        LANGUAGES NONE)
        #DESCRIPTION "Demonstrate downloading and extracting a ZIP file"
        #HOMEPAGE_URL https://github.com/scivision/cmake-utils)

set(ZIPFN ${CMAKE_CURRENT_BINARY_DIR}/github-mark.zip)
set(OUTFN ${CMAKE_CURRENT_BINARY_DIR}/github-mark.svg)

if(NOT EXISTS ${OUTFN})
  if(NOT EXISTS ${ZIPFN})
    file(DOWNLOAD https://zenodo.org/record/1486184/files/github-mark.zip?download=1 ${ZIPFN}
         SHOW_PROGRESS
         EXPECTED_HASH MD5=49f6a914ea33912471512ac9228c6923)
  endif()

  execute_process(COMMAND ${CMAKE_COMMAND} -E tar -xf ${ZIPFN}
                  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
endif()

# -- check extracted (or any other) file
file(MD5 ${OUTFN} CHKSUM)

if(NOT ${CHKSUM} STREQUAL 07883e93734b98cae0f7b9c55d287250)
  message(WARNING "MD5 checksum did not match ${OUTFN}")
endif()
