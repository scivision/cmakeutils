cmake_minimum_required(VERSION 3.18...3.23)

project(ZIPdemo
LANGUAGES NONE
DESCRIPTION "Demonstrate downloading and extracting a ZIP file"
)

set(ZIPFN ${CMAKE_CURRENT_BINARY_DIR}/github-mark.zip)
set(OUTFN ${CMAKE_CURRENT_BINARY_DIR}/github-mark.svg)

if(NOT EXISTS ${OUTFN})
  if(NOT EXISTS ${ZIPFN})
    file(DOWNLOAD https://zenodo.org/record/1486184/files/github-mark.zip?download=1 ${ZIPFN}
    EXPECTED_HASH MD5=49f6a914ea33912471512ac9228c6923
    INACTIVITY_TIMEOUT 15
    )
  endif(NOT EXISTS ${ZIPFN})

  # this is OS-agnostic
  file(ARCHIVE_EXTRACT INPUT ${ZIPFN} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
endif()

# -- check extracted (or any other) file
file(MD5 ${OUTFN} CHKSUM)

if(NOT ${CHKSUM} STREQUAL 07883e93734b98cae0f7b9c55d287250)
  message(WARNING "MD5 checksum did not match ${OUTFN}")
endif()
