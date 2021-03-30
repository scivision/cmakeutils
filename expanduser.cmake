set(x "~/code")

# cmake_path does not expand ~

cmake_path(ABSOLUTE_PATH x NORMALIZE)

message(STATUS "cmake_path(ABSOLUTE_PATH ~): ${x}")

# --- file()

file(REAL_PATH "~/code" x)
message(STATUS "file(REAL_PATH ~): ${x}")

# --- get_filename_component()

get_filename_component(x "~/code" ABSOLUTE)
message(STATUS "get_filename_component(... ABSOLUTE): ${x}")

get_filename_component(x "~/code" REALPATH)
message(STATUS "get_filename_component(... REALPATH): ${x}")
