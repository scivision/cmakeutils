#!/bin/bash
# download and install CMake binary
# Does NOT use sudo
# checks SHA256 checksum
#
# Git > 2.18 required, or specify CMake version at command line e.g.
#
# ./cmake_setup.sh v3.14.0

set -e
set -u

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

[[ -v ${PREFIX:-} ]] || PREFIX=$HOME/.local

mkdir -p $PREFIX

# git >= 2.18
[[ $# -ne 1 ]] && cver=$(git ls-remote --tags --sort="v:refname" git://github.com/kitware/cmake.git | tail -n1 | sed 's/.*\///; s/\^{}//') || cver=$1

WD=~/Downloads

#0. config

url=https://github.com/Kitware/CMake/releases/download/
stem=cmake-${cver:1}-Linux-x86_64
fn=$stem.tar.gz
efn=$stem.sh
cfn=cmake-${cver:1}-SHA-256.txt


(cd $WD

[[ -f $cfn ]] || curl -L $url/$cver/$cfn -o $cfn

csum=$(grep $fn $cfn | cut -f1 -d' ')

[[ -f $fn ]] || curl -L $url/$cver/$fn -o $fn

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
