# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
FindAutotools
-------------

The main purpose is to detect that commonly used Autotools programs are isntalled.
This lets the user know at CMake configuration time if the computer is ready to
build an autotools-based ExternalProject.

Result Variables
^^^^^^^^^^^^^^^^

``Autotools_FOUND``
  indicates Autotools and associated programs are detected
#]=======================================================================]

find_program(AUTOCONF_EXECUTABLE
NAMES autoconf
DOC "Autoconf")

find_program(AUTOMAKE_EXECUTABLE
NAMES automake
DOC "Automake")

find_program(MAKE_EXECUTABLE
NAMES gmake make
NAMES_PER_DIR
DOC "GNU Make")

find_program(LIBTOOL_EXECUTABLE
NAMES libtoolize
DOC "libtool sets up shared libraries")


include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Autotools
  REQUIRED_VARS AUTOCONF_EXECUTABLE AUTOMAKE_EXECUTABLE MAKE_EXECUTABLE LIBTOOL_EXECUTABLE)
