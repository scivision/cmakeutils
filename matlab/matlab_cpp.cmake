# https://www.mathworks.com/support/requirements/supported-compilers.html

if(Matlab_ENG_LIBRARY_FOUND AND Matlab_MX_LIBRARY_FOUND)
  add_executable(cppdemo engdemo.cpp)
  target_include_directories(cppdemo PRIVATE ${Matlab_INCLUDE_DIRS})
  target_link_libraries(cppdemo PRIVATE ${Matlab_LIBRARIES})

  add_test(NAME MexC++ COMMAND $<TARGET_FILE:cppdemo>)
  set_tests_properties(MexC++ PROPERTIES
    TIMEOUT ${timeout}
    ENVIRONMENT "${libenv}")
endif()
