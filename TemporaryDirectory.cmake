# Generally, the system temporary directory should not be used in CMake scripts, as
# it can trigger virus scanners and other side effects.

function(generateTemporaryDir out_var)
  if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set(var TMP TEMP)
  else()
    set(var XDG_RUNTIME_DIR TMPDIR)
  endif()

  set(o "")
  foreach(v IN LISTS var)
    if(DEFINED ENV{${v}} AND NOT "$ENV{${v}}" STREQUAL "")
      set(o "$ENV{${v}}")
      break()
    endif()
  endforeach()

  if(o STREQUAL "")
    set(o ${CMAKE_CURRENT_BINARY_DIR}/tmp)
  endif()

  string(RANDOM LENGTH 12 r)
  set(o "${o}/cmake_${r}")

  file(TO_CMAKE_PATH "${o}" o)

  set(${out_var} "${o}" PARENT_SCOPE)
endfunction()

# allow command line demo if run from "cmake -P TemporaryDirectory.cmake"
if(DEFINED CMAKE_SCRIPT_MODE_FILE)
  generateTemporaryDir(tmpdir)
  message(STATUS "${tmpdir}")
endif()
