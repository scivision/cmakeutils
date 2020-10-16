# https://www.mathworks.com/support/requirements/supported-compilers.html
if(WIN32 OR APPLE)
  if(NOT CMAKE_Fortran_COMPILER_ID STREQUAL Intel)
    message(STATUS "SKIP: on Windows and MacOS, Matlab Fortran supports only Intel compiler.")
    return()
  endif()
else()
  if(NOT CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
    message(STATUS "SKIP: On Linux, Matlab Fortran supports only Gfortran.")
    return()
  endif()
endif()

if(Matlab_ENG_LIBRARY_FOUND AND Matlab_MX_LIBRARY_FOUND)
  add_executable(fengdemo fengdemo.F90)
  target_include_directories(fengdemo PRIVATE ${Matlab_INCLUDE_DIRS})
  target_link_libraries(fengdemo PRIVATE ${Matlab_LIBRARIES})

  add_test(NAME MexFortran COMMAND $<TARGET_FILE:fengdemo>)
  set_tests_properties(MexFortran PROPERTIES
    TIMEOUT ${timeout}
    ENVIRONMENT "${libenv}")
endif()
