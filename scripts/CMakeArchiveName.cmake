function(full_version version_req)

string(LENGTH "${version_req}" L)
if (L LESS 5)  # 3.x or 3.xx, read latest full version for that minor version
  if(CMAKE_VERSION VERSION_LESS 3.19)
    message(FATAL_ERROR "When using CMake < 3.19, specify full cmake version to download like:
    cmake -Dversion=\"3.27.9\" -P ${CMAKE_CURRENT_LIST_FILE}")
  endif()
  file(READ ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/versions.json _j)
  if(L LESS 1)  # version not specified
    string(JSON version_req GET ${_j} "cmake" "latest")
  endif()
  string(JSON version GET ${_j} "cmake" "${version_req}")
endif()

set(version ${version} PARENT_SCOPE)

endfunction(full_version)


function(iter_json json key pat out)

unset(${out} PARENT_SCOPE)

string(JSON L LENGTH ${json} ${key})

math(EXPR L "${L} - 1")

foreach(i RANGE ${L})
  string(JSON o GET ${json} ${key} ${i})
  # message(DEBUG "pat: ${pat}   o: ${o}")
  if(pat STREQUAL o)
    set(${out} ${o} PARENT_SCOPE)
    # message(DEBUG "${out}: ${o}")
    return()
  endif()
endforeach()

endfunction(iter_json)


function(unknown_archive version arch)

message(FATAL_ERROR "No CMake ${version} binary download available for system architecture ${arch}.
Try building CMake from source:
  cmake -P ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/build_cmake.cmake
or use Python:
  pip install cmake
or use Snap:
  snap install cmake"
)

endfunction(unknown_archive)


function(cmake_archive_name version file_json arch out)
# CMake >= 3.20 dynamic filename

if(WIN32)
  set(sname "windows")
elseif(APPLE)
  set(sname "macos")
else()
  set(sname "linux")
endif()

file(READ ${file_json} json)

string(JSON L LENGTH ${json} "files")
math(EXPR L "${L} - 1")

foreach(i RANGE ${L})

  string(JSON d GET ${json} "files" ${i})

  iter_json("${d}" "os" "${sname}" "os_key")
  if(NOT os_key)
    continue()
  endif()
  # message(DEBUG "os_key: ${os_key}")

  iter_json("${d}" "architecture" "${arch}" "arch_key")
  if(NOT arch_key)
    continue()
  endif()
  message(DEBUG "os_key: ${os_key}  arch_key: ${arch_key}")

  string(JSON c GET ${json} "files" ${i} "class")
  if(NOT c STREQUAL "archive")
    continue()
  endif()

  string(JSON filename GET ${json} "files" ${i} "name")
  break()

endforeach()

if(NOT filename)
  unknown_archive(${version} ${arch})
endif()

# hash
string(JSON L LENGTH ${json} "hashFiles")
math(EXPR L "${L} - 1")
foreach(i RANGE ${L})
  string(JSON d GET ${json} "hashFiles" ${i})

  iter_json("${d}" "algorithm" "sha256" "hash_key")
  if(NOT hash_key)
    continue()
  endif()

  string(JSON hash_name GET ${json} "hashFiles" ${i} "name")
  break()
endforeach()

set(hash_url ${url_stem}/${hash_name})
set(hash_file ${prefix}/${hash_name})
message(STATUS "CMake ${version} hash: ${hash_url} => ${hash_file}")

file(DOWNLOAD ${hash_url} ${hash_file} STATUS ret LOG log)
list(GET ret 0 stat)
if(NOT stat EQUAL 0)
  list(GET ret 1 err)
  message(FATAL_ERROR "CMake hash download failed: ${stat} ${err} ${log}")
endif()

set(pat "([0-9a-f]+)  ${filename}")
file(STRINGS ${hash_file} sha256
LIMIT_COUNT 1
REGEX ${pat}
)
string(REGEX MATCH ${pat} sha256 ${sha256})
set(sha256 ${CMAKE_MATCH_1})
if(NOT sha256)
  message(FATAL_ERROR "did not extract sha256 hash from ${hash_file}")
endif()

message(STATUS "CMake ${version} ${filename} sha256 hash: ${sha256}")

set(${out} ${filename} PARENT_SCOPE)
set(sha256 ${sha256} PARENT_SCOPE)

endfunction(cmake_archive_name)


function(cmake_legacy_name arch out)
# CMake < 3.20 static filename

if(APPLE)

if(version VERSION_LESS 3.19)
  set(file_arch Darwin-x86_64)
else()
  set(file_arch macos-universal)
endif()

elseif(UNIX)

if(version VERSION_LESS 3.20)
  set(file_arch L)
else()
  set(file_arch l)
endif()
string(APPEND file_arch inux-${arch})

elseif(WIN32)

if(arch STREQUAL "ARM64")
  if(version VERSION_GREATER_EQUAL 3.24)
    set(file_arch windows-arm64)
  endif()
elseif(arch STREQUAL "x86_64")
  if(version VERSION_LESS 3.20)
    set(file_arch win64-x64)
  else()
    set(file_arch windows-x86_64)
  endif()
elseif(arch STREQUAL "x86")
  if(version VERSION_LESS 3.20)
    set(file_arch win32-x86)
  else()
    set(file_arch windows-i386)
  endif()
endif()

endif()


if(NOT file_arch)
  unknown_archive(${version} ${arch})
endif()

if(UNIX)
  set(suffix .tar.gz)
else()
  set(suffix .zip)
endif()

set(${out} cmake-${version}-${file_arch}${suffix} PARENT_SCOPE)

endfunction(cmake_legacy_name)
