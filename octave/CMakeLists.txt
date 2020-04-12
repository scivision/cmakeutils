cmake_minimum_required(VERSION 3.14)
project(demoOctave LANGUAGES CXX)
enable_testing()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/Modules/)

# --- GNU Octave ---
find_package(Octave COMPONENTS Interpreter)

if(Octave_Interpreter_FOUND)
  add_test(NAME BasicOctave
           COMMAND Octave::Interpreter -q --eval "runtests('${CMAKE_CURRENT_SOURCE_DIR}')")
  set_tests_properties(BasicOctave PROPERTIES TIMEOUT 20)
endif()

# -- devel
# Fortran: https://wiki.octave.org/Fortran
find_package(Octave COMPONENTS Development)
if(Octave_Development_FOUND)
  add_executable(octdemo octdemo.cpp)
  target_link_libraries(octdemo Octave::Octave)
  target_compile_features(octdemo PROPERTIES cxx_std_17)

  add_test(NAME DevOctave COMMAND octdemo)
  set_tests_properties(BasicOctave PROPERTIES TIMEOUT 10)
endif()
