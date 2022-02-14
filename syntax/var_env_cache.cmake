cmake_minimum_required(VERSION 3.12...3.23)
# CMake if() is NOT short circuit.
# this requires care with undefined variables

set(ENV{myvar123} true)
if(ENV{myvar123})
  message(FATAL_ERROR "unexpected behavior with env variable not evaluated .")
endif()
if($ENV{myvar123})
  message(STATUS "expected behavior with env variable evaluated as string.")
endif()

set(ENV{myvar123} false)
if($ENV{myvar123})
  message(FATAL_ERROR "unexpected behavior with env variable evaluated as string.")
endif()
