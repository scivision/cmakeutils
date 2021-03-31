function(expanduser in outvar)
# expands ~ to user home directory
#
# cmake_path and file do not expand ~
# get_filename_component expands ~ in C++ similar to above
#
# usage:
# expanduser("~/code" x)

string(SUBSTRING ${in} 0 1 first)
if(NOT ${first} STREQUAL "~")
  set(${outvar} ${in} PARENT_SCOPE)
  return()
endif()

if(WIN32 AND NOT CYGWIN)
  set(home $ENV{USERPROFILE})
else()
  set(home $ENV{HOME})
endif()

if(NOT home)
  set(${outvar} ${in} PARENT_SCOPE)
  return()
endif()

string(SUBSTRING ${in} 1 -1 tail)
if(CMAKE_VERSION VERSION_LESS 3.20)
  file(TO_CMAKE_PATH ${home}${tail} out)
else()
  cmake_path(CONVERT ${home}${tail} TO_CMAKE_PATH_LIST out)
endif()

set(${outvar} ${out} PARENT_SCOPE)

endfunction(expanduser)


expanduser("~/code" x)
message(STATUS "${x}")
