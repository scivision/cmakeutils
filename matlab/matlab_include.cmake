# sets include paths needed for each OS with Matlab Engine

if(WIN32)
  set(libpath ${Matlab_ROOT_DIR}/bin/win64/)
   # no ospath on Windows
  set(libenv "PATH=${libpath};$ENV{PATH}")
elseif(APPLE)
  set(libpath ${Matlab_ROOT_DIR}/bin/maci64/)
  set(ospath ${Matlab_ROOT_DIR}/sys/os/maci64/)
  set(libenv "DYLD_LIBRARY_PATH=${libpath}:${ospath}:$ENV{DYLD_LIBRARY_PATH}")
elseif(UNIX)
  # https://www.mathworks.com/help/matlab/matlab_external/building-on-unix-operating-systems.html
  set(libpath ${Matlab_ROOT_DIR}/bin/glnxa64/)
  set(ospath ${Matlab_ROOT_DIR}/sys/os/glnxa64/)
  set(libenv "LD_LIBRARY_PATH=${libpath}:${ospath}:$ENV{LD_LIBRARY_PATH}")
endif()

# message(STATUS "libpath:  ${libpath}")
# message(STATUS "libenv:   ${libenv}")