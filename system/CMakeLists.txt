cmake_minimum_required(VERSION 3.10)
project(systemdemo NONE)

include(ProcessorCount)
ProcessorCount(NCORES)
math(EXPR NCORES "${NCORES}/2")

cmake_host_system_information(RESULT OSNAME QUERY OS_NAME)
#cmake_host_system_information(RESULT NCORES QUERY NUMBER_OF_PHYSICAL_CORES)  # incorrect on Cygwin, says 1.


cmake_host_system_information(RESULT VIRTTOT QUERY TOTAL_VIRTUAL_MEMORY)
cmake_host_system_information(RESULT VIRTFREE QUERY AVAILABLE_VIRTUAL_MEMORY)

cmake_host_system_information(RESULT PHYSTOT QUERY TOTAL_PHYSICAL_MEMORY)
cmake_host_system_information(RESULT PHYSFREE QUERY AVAILABLE_PHYSICAL_MEMORY)

message("${OSNAME} has ${NCORES} physical CPU cores.")

message("Units are Megabytes.")
message("Total RAM: " ${PHYSTOT})
message("Free RAM: " ${PHYSFREE})

message("Total virtual  memory: " ${VIRTTOT})
message("Free virtual memory: " ${VIRTFREE})
