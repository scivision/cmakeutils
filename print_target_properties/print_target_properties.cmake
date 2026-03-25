# usage: from your CMakeLists.txt:
#
# include(print_target_properties.make)
#
# print_target_properties(my_target)
#
# example:
# find_package(ZLIB)
# print_target_properties(ZLIB::ZLIB)
#
# There is an MR proposing this built-into CMake 4.4 https://gitlab.kitware.com/cmake/cmake/-/merge_requests/11834

include_guard()

function(print_target_property tgt prop)

get_target_property(v ${tgt} ${prop})

# only produce output for values that are set and are target properties
if(v)
  message(STATUS "${tgt}  ${prop}  ${v}")
else()
  message(DEBUG "${tgt}  ${prop} is not set or not a target property")
endif()

endfunction()


function(print_target_properties target)

# https://cmake.org/cmake/help/latest/manual/cmake-properties.7.html#target-properties
# this approach is dynamic, but lists non target properties as well, which will be ignored by silent error

execute_process(COMMAND ${CMAKE_COMMAND} cmake --help-property-list
  OUTPUT_VARIABLE props
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
string(REPLACE "\n" ";" props "${props}")
list(REMOVE_DUPLICATES props)

if(NOT TARGET ${target})
  message(STATUS "There is no target ${target}")
  return()
endif()

foreach(p IN LISTS props)
  print_target_property("${target}" "${p}")
endforeach()

endfunction()
