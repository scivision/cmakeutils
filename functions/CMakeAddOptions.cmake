function(cmake_add_compile_options lang)

  set(args "")

  foreach(arg ${ARGN})
    string(APPEND args ${arg}$<SEMICOLON>)
  endforeach()

  add_compile_options($<$<COMPILE_LANGUAGE:${lang}>:${args}>)
endfunction()


function(cmake_add_link_options lang)
# cmake >= 3.18

  set(args "")

  foreach(arg ${ARGN})
    string(APPEND args ${arg}$<SEMICOLON>)
  endforeach()

  add_link_options($<$<LINK_LANGUAGE:${lang}>:${args}>)
endfunction()
