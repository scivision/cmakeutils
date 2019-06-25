function(matlab_cpp timeout libenv)
# https://www.mathworks.com/support/requirements/supported-compilers.html

find_package(Matlab COMPONENTS ENG_LIBRARY MX_LIBRARY)

if(Matlab_ENG_LIBRARY_FOUND AND Matlab_MX_LIBRARY_FOUND)
  add_executable(cppdemo engdemo.cpp)
  target_include_directories(cppdemo PRIVATE ${Matlab_INCLUDE_DIRS})
  target_link_libraries(cppdemo PRIVATE ${Matlab_LIBRARIES})

  add_test(NAME MexC++ COMMAND cppdemo)
  set_tests_properties(MexC++ PROPERTIES
    TIMEOUT ${timeout}
    ENVIRONMENT ${libenv})
endif()

endfunction()