cmake_minimum_required(VERSION 3.3)
project(demoMatlab Fortran)
enable_testing()


find_package(Matlab COMPONENTS MAIN_PROGRAM)

if(Matlab_MAIN_PROGRAM_FOUND)
  add_test(NAME BasicMatlab
    COMMAND ${Matlab_MAIN_PROGRAM} -nojvm -r "r=runtests(); exit(any([r.Failed]))"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
  set_tests_properties(BasicMatlab PROPERTIES TIMEOUT 30)
endif()


find_package(Matlab COMPONENTS ENG_LIBRARY MX_LIBRARY)
if(Matlab_ENG_LIBRARY_FOUND AND Matlab_MX_LIBRARY_FOUND)
  add_executable(fengdemo fengdemo.F90)
  target_include_directories(fengdemo PRIVATE ${Matlab_INCLUDE_DIRS})
  target_link_libraries(fengdemo PRIVATE ${Matlab_ENG_LIBRARY} ${Matlab_MX_LIBRARY})

  add_test(NAME MexFortran
    COMMAND fengdemo)
  set_tests_properties(MexFortran PROPERTIES TIMEOUT 30)
endif()
