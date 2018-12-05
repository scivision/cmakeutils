#!/bin/bash
#
# NOTE: most Linux users can simply download and install almost instantly
#   instead of this lengthly compilation:
#  1. browse to https://cmake.org/download/
#  2. scroll down to "Binary Distributions"
#  3. download cmake-*-Linux-x86_64.sh
#  4. install CMake for Linux almost instantly by:
#    ./cmake-*-Linux-x86_64.sh --prefix=$HOME/.local --exclude-subdir
# ------------------------------------------------------------------------
# 
# Does NOT use sudo
#
# Compiles and installs CMake on Linux (CentOS, Debian, Ubuntu)
#
# Alternatives: linuxbrew (Linux), Homebrew (Mac), Scoop (Windows)
#
# For Windows, simply use the .msi from  https://cmake.org/download/
#
# prereqs
# CentOS, Cygwin:  gcc-c++ make ncurses-devel openssl-devel
# Debian / Ubuntu: g++ make libncurses-dev libssl-dev

cver=3.13.1
PREF=$HOME/.local
WD=/tmp

set -e

# 0. check prereqs
[[ $(ldconfig -p | grep ssl) ]] || { echo "must have SSL development library installed"; exit 1; }


# 1. download
[[ -d $WD/cmake-$cver ]] || curl https://cmake.org/files/v${cver:0:4}/cmake-$cver.tar.gz | tar -C $WD  -xzf -

# 2. build
(
cd $WD

echo "installing cmake to $PREF"

./cmake-$cver/bootstrap --prefix=$PREF --parallel=2 -- -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_USE_OPENSSL:BOOL=ON

make -j -l 2

mkdir -p $PREF

make install
)

echo "----------------------------------------------------"
echo "please add $PREF/bin to your PATH (in ~/.bashrc)"
echo "then reopen a new terminal to use CMake $cver"
