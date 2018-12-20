cmake_minimum_required(VERSION 3.0)
project(systemdemo NONE)

cmake_host_system_information(RESULT VIRTTOT QUERY TOTAL_VIRTUAL_MEMORY)
cmake_host_system_information(RESULT VIRTFREE QUERY AVAILABLE_VIRTUAL_MEMORY)

cmake_host_system_information(RESULT PHYSTOT QUERY TOTAL_PHYSICAL_MEMORY)
cmake_host_system_information(RESULT PHYSFREE QUERY AVAILABLE_PHYSICAL_MEMORY)

message("Units are Megabytes.")
message("Total RAM: " ${PHYSTOT})
message("Free RAM: " ${PHYSFREE})

message("Total virtual  memory: " ${VIRTTOT})
message("Free virtual memory: " ${VIRTFREE})