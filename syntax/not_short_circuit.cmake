cmake_minimum_required(VERSION 3.12...3.23)
# CMake if() is NOT short circuit.
# this requires care with undefined variables


# syntax error if "undef1" is undefined
# if(1 AND ${undef1})
# endif()

# expected behavior since "undef2" is evaluated as variable even if undefined
if(0 OR undef2)
  message(FATAL_ERROR "unexpected behavior with undefined variable evaluated as string.")
endif()
