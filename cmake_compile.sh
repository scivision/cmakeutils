#!/bin/bash
#
# NOTE: most Linux users can simply download and install almost instantly
#   instead of this lengthly compilation with cmake_setup.sh
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

url=https://github.com/Kitware/CMake/releases/download/
cver=$(<.cmake-version)
PREF=$HOME/.local
WD=/tmp

stem=cmake-$cver
cfn=$stem-SHA-256.txt
fn=$stem.tar.gz

set -e

# 0. check prereqs
[[ $(ldconfig -p | grep ssl) ]] || { echo "must have SSL development library installed"; exit 1; }


# 1. download
[[ -f $WD/$fn ]] || curl -L $url/v$cver/$fn -o $WD/$fn

# 2. build
(
cd $WD

[[ -f $cfn ]] || curl -L $url/v$cver/$cfn -o $cfn
csum=$(grep $fn $cfn | cut -f1 -d' ')
[[ $(sha256sum $fn | cut -f1 -d' ') == $csum ]] || { echo "checksum not match $fn"; exit 1; }

tar -xf $fn

echo "installing cmake to $PREF"

./cmake-$cver/bootstrap --prefix=$PREF --parallel=2 -- -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_USE_OPENSSL:BOOL=ON

make -j -l 2

mkdir -p $PREF

make install
)

echo "----------------------------------------------------"
echo "please add to ~/.bashrc:"
echo
echo 'export PATH='$PREF'/bin/:$PATH'
echo
echo "then reopen a new terminal to use CMake $cver"
