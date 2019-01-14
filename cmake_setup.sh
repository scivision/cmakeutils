#!/bin/bash
# download and install CMake binary
# Does NOT use sudo
# checks SHA256 checksum

case $OSTYPE in
cygwin*)
  echo "install CMake by Cygwin setup.exe"
  exit
  ;;
darwin*)
  echo "please download cmake*.dmg from https://cmake.org/download/"
  exit
  ;;
*bsd*)
  echo "use setup_compile.sh to compile CMake from source"
  exit
  ;;
esac

[[ -z $PREFIX ]] && PREFIX=$HOME/.local

cver=$(<.cmake-version)
WD=/tmp

#0. config

url=https://github.com/Kitware/CMake/releases/download/
stem=cmake-$cver-Linux-x86_64
fn=$stem.tar.gz
efn=$stem.sh
cfn=cmake-$cver-SHA-256.txt

set -e

(
cd $WD
[[ -f $cfn ]] || curl -L $url/v$cver/$cfn -o $cfn

csum=$(grep $fn $cfn | cut -f1 -d' ')

[[ -f $fn ]] || curl -L $url/v$cver/$fn -o $fn

[[ $(sha256sum $fn | cut -f1 -d' ') == $csum ]] || { echo "checksum not match $fn"; exit 1; }

echo "Installing CMake $cver to $PREFIX/$stem"

tar -C $PREFIX -xf $fn
)


echo "----------------------------------------------------"
echo "please add to your PATH (in ~/.bashrc):"
echo
echo 'export PATH='$PREFIX/$stem'/bin/:$PATH'
echo
echo "then reopen a new terminal to use CMake $cver"
