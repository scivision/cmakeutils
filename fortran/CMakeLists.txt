include(CheckFortranSourceCompiles)
include(CheckFortranSourceRuns)

check_fortran_source_compiles("end" OK_Compile SRC_EXT F90)

check_fortran_source_runs("end" OK_Run)
