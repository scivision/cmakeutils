cmake_minimum_required(VERSION 3.14...3.20)

project(systemdemo LANGUAGES NONE)

include(ProcessorCount)
ProcessorCount(NCORES)

cmake_host_system_information(RESULT OSNAME QUERY OS_NAME)
#cmake_host_system_information(RESULT NCORES QUERY NUMBER_OF_PHYSICAL_CORES)  # incorrect on Cygwin, says 1.


cmake_host_system_information(RESULT VIRTTOT QUERY TOTAL_VIRTUAL_MEMORY)
cmake_host_system_information(RESULT VIRTFREE QUERY AVAILABLE_VIRTUAL_MEMORY)

cmake_host_system_information(RESULT PHYSTOT QUERY TOTAL_PHYSICAL_MEMORY)
cmake_host_system_information(RESULT PHYSFREE QUERY AVAILABLE_PHYSICAL_MEMORY)

message(STATUS "${OSNAME} has ${NCORES} CPU cores.")

message(STATUS "Units are Megabytes.")
message(STATUS "Total RAM: " ${PHYSTOT})
message(STATUS "Free RAM: " ${PHYSFREE})

message(STATUS "Total virtual  memory: " ${VIRTTOT})
message(STATUS "Free virtual memory: " ${VIRTFREE})
