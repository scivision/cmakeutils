cmake_minimum_required(VERSION 3.3)
project(demoOctave CXX)
enable_testing()

get_directory_property(hasParent PARENT_DIRECTORY)
if(NOT hasParent)
  list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../cmake/Modules/)
endif()

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.12)
  cmake_policy(SET CMP0074 NEW)
endif()
# --- GNU Octave ---
find_package(Octave COMPONENTS Interpreter Development)


if(Octave_Interpreter_FOUND)
  add_test(NAME BasicOctave
           COMMAND Octave::Interpreter -q --eval "runtests('.')"
           WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
endif()

if(Octave_Development_FOUND)
  add_executable(octdemo octdemo.cpp)
  target_link_libraries(octdemo PRIVATE Octave::Octave)
  
  add_test(NAME DevOctave COMMAND octdemo)
endif()

