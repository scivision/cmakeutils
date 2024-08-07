#!/usr/bin/env bash
# Download / extract CMake binary archive for CMake >= 3.20
#
# Example:
#    bash install_cmake.sh ~/cmake-3.30.2 3.30.2
#
# On Windows, instead do:
#   winget install Kitware.CMake

set -o errexit

[[ $# -lt 2 ]] && { echo "Usage: $0 install_prefix_path cmake_version" >&2; exit 1; }

prefix=$1
version=$2

# determine OS and arch
stub=""
ext=".tar.gz"

case "$OSTYPE" in
linux*)
os="linux"
arch=$(uname -m)
[[ "$arch" == "arm64" ]] && arch="aarch64";;
darwin*)
os="macos"
arch="universal"
stub="CMake.app/Contents/";;
msys*)
os="windows"
arch=$(uname -m)
ext=".zip";;
*)
echo "$OSTYPE not supported" >&2
exit 1;;
esac

# compose URL
name=cmake-${version}-${os}-${arch}
archive=${name}${ext}
archive_path=${prefix}/${archive}
url=https://github.com/Kitware/CMake/releases/download/v${version}/${archive}

# download and extract CMake
echo "${url} => ${archive_path}"
if curl --fail --location --output ${archive_path} ${url}; then
:
else
echo "failed to download ${url}" >&2
exit 1
fi

case "$ext" in
.tar.gz)
tar -x -v -f ${archive_path} -C ${prefix};;
.zip)
unzip ${archive_path} -d ${prefix};;
*)
echo "unknown archive type ${ext}" >&2
exit 1;;
esac

# prompt user to default shell to this new CMake

case "$SHELL" in
*/zsh)
shell="zsh";;
*/bash)
shell="bash";;
*)
echo "please add to environment variable PATH: ${prefix}/${name}/${stub}bin"
exit;;
esac

[[ -z ${shell+x} ]] || echo "please add the following line to file ${prefix}/.${shell}rc"
echo "export PATH=${prefix}/$name/${stub}bin:\$PATH"
