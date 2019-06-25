cmake_minimum_required(VERSION 3.7)
project(demoOctave LANGUAGES NONE)
enable_testing()

if(CMAKE_VERSION VERSION_LESS 3.14)
  list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../cmake/Modules/)
endif()

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.12)
  cmake_policy(SET CMP0074 NEW)
endif()
# --- GNU Octave ---
find_package(Octave COMPONENTS Interpreter Development)

if(Octave_Interpreter_FOUND)
  add_test(NAME BasicOctave
           COMMAND Octave::Interpreter -q --eval "runtests('${CMAKE_CURRENT_SOURCE_DIR}')"
           )
endif()

if(Octave_Development_FOUND)
  include(CheckLanguage)
  check_language(CXX)
  if(CMAKE_CXX_COMPILER)
    enable_language(CXX)
    add_executable(octdemo octdemo.cpp)
    target_link_libraries(octdemo PRIVATE Octave::Octave)
    set_target_properties(octdemo PROPERTIES CXX_STANDARD 11)

    add_test(NAME DevOctave COMMAND octdemo)
  endif()
endif()

