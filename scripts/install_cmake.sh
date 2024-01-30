#!/usr/bin/env bash
# Download / extract CMake binary archive for CMake >= 3.20
# On Windows, this works from Git Bash or MSYS2 for native Windows.

set -o errexit

if [[ $# -lt 1 ]]; then
[[ "$OSTYPE" == "msys" ]] && prefix=$USERPROFILE || prefix=$HOME
else
prefix=$1
fi
[[ -z "${prefix+x}" ]] && { echo "Usage: $0 install_prefix_path" >&2; exit 1; }

[[ $# -lt 2 ]] && version="3.28.2" || version=$2

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
