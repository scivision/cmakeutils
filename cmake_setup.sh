#!/bin/bash
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

cver=3.13.0-rc3
PREF=$HOME/.local
WD=/tmp

set -e # after prereqs

# 1. download
[[ -d $WD/cmake-$cver ]] || curl https://cmake.org/files/v${cver:0:4}/cmake-$cver.tar.gz | tar -C $WD  -xzf -

# 2. build
(
cd $WD

echo "installing cmake to $PREF"
./cmake-$cver/bootstrap --prefix=$PREF --parallel=2 -- -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_USE_OPENSSL:BOOL=ON

make -j -l 2
make install
)

echo "----------------------------------------------------"
echo "please add $PREF/bin to your PATH (in ~/.bashrc)"
echo "then reopen a new terminal to use CMake $cver"
