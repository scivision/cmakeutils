function(check_ninja path)

find_program(ninja
NAMES ninja
PATHS ${path}
PATH_SUFFIXES bin
NO_DEFAULT_PATH
REQUIRED
)

cmake_path(GET ninja PARENT_PATH ninja_path)

set(ep $ENV{PATH})
cmake_path(CONVERT "${ep}" TO_CMAKE_PATH_LIST ep NORMALIZE)

if(NOT ${ninja_path} IN_LIST ep)
  message(STATUS "add to environment variable PATH ${ninja_path}")
endif()

if(NOT DEFINED ENV{CMAKE_GENERATOR})
  message(STATUS "add environment variable CMAKE_GENERATOR Ninja")
endif()

endfunction(check_ninja)
