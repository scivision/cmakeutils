cmake_minimum_required(VERSION 3.12)

# examples of list(TRANSFORM ...)
# these examples come from CMake self-test and various GitLab Issues and Discourse.

message(STATUS "Extract major.minor version from a version string")

set(x 1.2.3.4 1.2.3 1.2 1)

message(STATUS "before: ${x}")

list(TRANSFORM x REPLACE "^([0-9]+\\.[0-9]+).*" "\\1" OUTPUT_VARIABLE y)
message(STATUS "list(TRANSFORM) ${y}")

foreach(z IN LISTS x)
  string(REGEX REPLACE "^([0-9]+\\.[0-9]+).*" "\\1" z "${z}")
  message(STATUS "string(REGEX REPLACE) ${z}")
endforeach()


# SELECTOR examples

set(in alpha bravo charlie delta)

list(TRANSFORM in REPLACE "(.+a)$" "\\1_\\1" OUTPUT_VARIABLE out)
message(STATUS "${out}")

list(TRANSFORM in REPLACE "(.+a)$" "\\1_\\1" AT 1 3 OUTPUT_VARIABLE out)
message(STATUS "AT 1 3    ${out}")

list(TRANSFORM in REPLACE "(.+e)$" "\\1_\\1" AT 1 -2 OUTPUT_VARIABLE out)
message(STATUS "AT 1 -2   ${out}")

list(TRANSFORM in REPLACE "(.+e)$" "\\1_\\1" FOR 1 2 OUTPUT_VARIABLE out)
message(STATUS "FOR 1 2   ${out}")

list(TRANSFORM in REPLACE "(.+a)$" "\\1_\\1" FOR 1 -1 OUTPUT_VARIABLE out)
message(STATUS "FOR 1 -1  ${out}")

list(TRANSFORM in REPLACE "(.+a)$" "\\1_\\1" FOR 0 -1 2 OUTPUT_VARIABLE out)
message(STATUS "FOR 0 -1 2 ${out}")

list(TRANSFORM in REPLACE "(.+a)$" "\\1_\\1" REGEX "(r|t)a" OUTPUT_VARIABLE out)
message(STATUS "REGEX (r|t)a   ${out}")
