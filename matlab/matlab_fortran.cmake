function(matlab_fortran timeout libenv)
# https://www.mathworks.com/support/requirements/supported-compilers.html
if(WIN32 OR APPLE)
# on Windows and MacOS, only the Intel compiler is supported through at least R2019a
  if(NOT CMAKE_Fortran_COMPILER_ID STREQUAL Intel)
    return()
  endif()
else()
# On Linux, only Gfortran is supported through at least R2019a
  if(NOT CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
    return()
  endif()
endif()

if(Matlab_ENG_LIBRARY_FOUND AND Matlab_MX_LIBRARY_FOUND)
  add_executable(fengdemo fengdemo.F90)
  target_include_directories(fengdemo PRIVATE ${Matlab_INCLUDE_DIRS})
  target_link_libraries(fengdemo PRIVATE ${Matlab_LIBRARIES})

  add_test(NAME MexFortran COMMAND fengdemo)
  set_tests_properties(MexFortran PROPERTIES
    TIMEOUT ${timeout}
    ENVIRONMENT ${libenv})
endif()

endfunction()