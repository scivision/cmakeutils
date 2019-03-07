# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:

FindLapack
----------

* Michael Hirsch, Ph.D. www.scivision.dev
* David Eklund

Let Michael know if there are more MKl/Lapack/compiler combination you want.
Refer to https://software.intel.com/en-us/articles/intel-mkl-link-line-advisor

Finds LAPACK library. Works with Netlib Lapack and Intel MKL,
including for non-Intel compilers with Intel MKL.

Why not the FindLapack.cmake built into CMake? It has a lot of old code for
infrequently used Lapack libraries and is unreliable for me.


Parameters
^^^^^^^^^^

COMPONENTS default to Netlib LAPACK, otherwise:

``IntelPar``
  Intel MKL 32-bit integer with Intel OpenMP for ICC, GCC and PGCC
``IntelSeq``
  Intel MKL 32-bit integer without threading for ICC, GCC, and PGCC


Result Variables
^^^^^^^^^^^^^^^^

``LAPACK_FOUND``
  Lapack libraries were found
``LAPACK_<component>_FOUND``
  LAPACK <component> specified was found
``LAPACK_LIBRARIES``
  Lapack library files (including BLAS
``LAPACK_INCLUDE_DIRS``
  Lapack include directories (for C/C++)


References
^^^^^^^^^^

* Pkg-Config and MKL:  https://software.intel.com/en-us/articles/intel-math-kernel-library-intel-mkl-and-pkg-config-tool

#]=======================================================================]


cmake_policy(VERSION 3.3)

function(mkl_libs)
# https://software.intel.com/en-us/articles/intel-mkl-link-line-advisor

set(_mkl_libs ${ARGV})
if(CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
  list(INSERT _mkl_libs 0 mkl_gf_lp64)
endif()

foreach(s ${_mkl_libs})
  find_library(LAPACK_${s}_LIBRARY
           NAMES ${s}
           PATHS $ENV{MKLROOT}/lib
                 $ENV{MKLROOT}/lib/intel64
                 $ENV{MKLROOT}/../compiler/lib
                 $ENV{MKLROOT}/../compiler/lib/intel64
           HINTS ${MKL_LIBRARY_DIRS}
           NO_DEFAULT_PATH)
  if(NOT LAPACK_${s}_LIBRARY)
    message(FATAL_ERROR "NOT FOUND: " ${s})
  endif()

  list(APPEND LAPACK_LIB ${LAPACK_${s}_LIBRARY})
endforeach()

if(NOT BUILD_SHARED_LIBS AND (UNIX AND NOT APPLE))
  set(LAPACK_LIB -Wl,--start-group ${LAPACK_LIB} -Wl,--end-group)
endif()

list(APPEND LAPACK_LIB ${MKL_LDFLAGS} pthread ${CMAKE_DL_LIBS} m)

set(LAPACK_LIBRARY ${LAPACK_LIB} PARENT_SCOPE)
set(LAPACK_INCLUDE_DIR $ENV{MKLROOT}/include ${MKL_INCLUDE_DIRS} PARENT_SCOPE)

endfunction()

#===============================================================================

find_package(PkgConfig)

if(BUILD_SHARED_LIBS)
  set(_mkltype dynamic)
else()
  set(_mkltype static)
endif()

if(IntelPar IN_LIST LAPACK_FIND_COMPONENTS)
  pkg_check_modules(MKL mkl-${_mkltype}-lp64-iomp)

  mkl_libs(mkl_intel_lp64 mkl_intel_thread mkl_core iomp5)

  if(LAPACK_LIBRARY)
    set(LAPACK_IntelPar_FOUND true)
  endif()
elseif(IntelSeq IN_LIST LAPACK_FIND_COMPONENTS)
  pkg_check_modules(MKL mkl-${_mkltype}-lp64-seq)

  mkl_libs(mkl_intel_lp64 mkl_sequential mkl_core)

  if(LAPACK_LIBRARY)
    set(LAPACK_IntelSeq_FOUND true)
  endif()
else()

   pkg_check_modules(LAPACK lapack)

  find_library(LAPACK_LIBRARY
    NAMES lapack
    HINTS ${LAPACK_LIBRARY_DIRS})

  find_library(BLAS_LIBRARY
    NAMES refblas blas
    HINTS ${LAPACK_LIBRARY_DIRS})

  mark_as_advanced(BLAS_LIBRARY)

  list(APPEND LAPACK_LIBRARY ${BLAS_LIBRARY})
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  LAPACK
  REQUIRED_VARS LAPACK_LIBRARY
  HANDLE_COMPONENTS)

if(LAPACK_FOUND)
  set(LAPACK_LIBRARIES ${LAPACK_LIBRARY})
  set(LAPACK_INCLUDE_DIRS ${LAPACK_INCLUDE_DIR})
endif()

mark_as_advanced(LAPACK_LIBRARY LAPACK_INCLUDE_DIR)
