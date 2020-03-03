#!/usr/bin/env python3
"""
NOTE: most Linux users can simply download and install almost instantly
  instead of this lengthly compilation with cmake_setup.py

---

Does NOT use sudo

Compiles and installs CMake on Linux (CentOS, Debian, Ubuntu)

Alternatives: linuxbrew (Linux), Homebrew (Mac), Scoop (Windows)

Windows:use the .msi from  https://cmake.org/download/
 If you need to compile on Windows, suggest MSYS2.

prereqs
CentOS:    yum install gcc-c++ make ncurses-devel openssl-devel unzip
Debian / Ubuntu: apt install g++ make libncurses-dev libssl-dev unzip
Cygwin: setup-x86_64.exe -P gcc-g++ make libncurses-devel libssl-devel

Git > 2.18 required, or specify CMake version at command line e.g.

python cmake_compile.sh v3.16.4
"""

import argparse
import os
import subprocess
import tarfile
import shutil
import urllib.request
from pathlib import Path
from cmake_setup import latest_cmake_version, file_checksum

# RAM is a problem for parallel build, so make a guess at number of parallel jobs
Njobs = "1"
try:
    import psutil
    free = psutil.virtual_memory().free
    if free > 4e9:
        Njobs = ""
    elif free > 2e9:
        Njobs = "2"
except ImportError:
    pass


url_stem = 'https://github.com/Kitware/CMake/releases/download'

p = argparse.ArgumentParser()
p.add_argument('version', nargs='?')
p.add_argument('-prefix', default='~/.local')
p = p.parse_args()

prefix = Path(p.prefix).expanduser()

# get latest CMake version if not specified
version = p.version
if version is None:
    version = latest_cmake_version()

WD = Path('build')
WD.mkdir(exist_ok=True)

stem = f'cmake-{version}'
build_root = (WD / stem).resolve(strict=False)
cfn = f'{stem}-SHA-256.txt'
fn = f'{stem}.tar.gz'

# 0. check prereqs
nossl = True
if shutil.which('pkg-config'):
    ret = subprocess.run(['pkg-config', 'libssl'])
    if not ret.returncode:
        nossl = False
if nossl:
    raise RuntimeError("must have SSL development library installed")

# 1. download
cmake_archive = WD / fn
url = f'{url_stem}/v{version}/{fn}'
if not cmake_archive.is_file():
    print(f'downloading {url}')
    urllib.request.urlretrieve(url, cmake_archive)

# 2. build
cmake_sig = WD / cfn
url_sig = f'{url_stem}/v{version}/{cfn}'
if not cmake_sig.is_file():
    print(f'downloading {url_sig}')
    urllib.request.urlretrieve(url_sig, cmake_sig)

print('checking SHA256 signature')
if not file_checksum(cmake_archive, cmake_sig, "sha256"):
    raise ValueError("{} SHA256 checksum did not match {}".format(cmake_archive, cmake_sig))

if not build_root.is_dir():
    print('extracting CMake source')
    with tarfile.open(str(cmake_archive)) as tf:
        tf.extractall(str(WD))

print(f"installing cmake to {prefix}")

# CMake or bootstrap


def bootstrap(build_root: Path):
    if os.name == 'nt':
        raise RuntimeError('CMake bootstrap is for Unix-like systems only')
    cmake_bootstrap = build_root / 'bootstrap'
    if not cmake_bootstrap.is_file():
        raise FileNotFoundError(cmake_bootstrap)

    N = Njobs if Njobs else "4"

    print('running CMake bootstrap', cmake_bootstrap)
    subprocess.check_call([str(cmake_bootstrap),
                           f'--prefix={prefix}',
                           f'--parallel={N}',
                           '--',
                           '-DCMAKE_BUILD_TYPE:STRING=Release',
                           '-DCMAKE_USE_OPENSSL:BOOL=ON'], cwd=build_root)

    subprocess.check_call(['make', '-j', Njobs], cwd=build_root)
    subprocess.check_call(['make', 'install'], cwd=build_root)


prefix.mkdir(parents=True, exist_ok=True)

if shutil.which('cmake'):
    subprocess.check_call(['cmake', '.',
                           f'-DCMAKE_INSTALL_PREFIX={prefix}',
                           '-DCMAKE_BUILD_TYPE:STRING=Release',
                           '-DCMAKE_USE_OPENSSL:BOOL=ON'], cwd=build_root)
    # --parallel is CMake >= 3.12, probably too new to require for now.
    # Ninja will build in parallel even without --parallel
    subprocess.check_call(['cmake', '--build', str(build_root)])
    subprocess.check_call(['cmake', '--build', str(build_root), '--target', 'install'])
else:
    bootstrap(build_root)

print("\n----------------------------------------------------")
print(f"please add to your system PATH:  {prefix}/bin/")
print(f"\nreopen a new terminal to use CMake {version}")
