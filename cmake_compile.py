#!/usr/bin/env python3
"""
NOTE: most Linux users can simply download and install almost instantly
  instead of this lengthly compilation with cmake_setup.py

---

Does NOT use sudo

Compiles and installs CMake.

Alternatives: Homebrew (MacOS / Linux), Scoop (Windows)

Windows:use the .msi from  https://cmake.org/download/
 If you need to compile on Windows, suggest MSYS2.

prereqs
CentOS:    yum install gcc-c++ make ncurses-devel openssl-devel unzip
Debian / Ubuntu: apt install g++ make libncurses-dev libssl-dev unzip
Cygwin: setup-x86_64.exe -P gcc-g++ make libncurses-devel libssl-devel

Git > 2.18 required, or specify CMake version at command line e.g.

python cmake_compile.py v3.17.0
"""

import argparse
import os
import sys
import subprocess
import tarfile
import shutil
import urllib.request
from pathlib import Path
from cmake_setup import get_latest_version, file_checksum

# RAM is a problem for parallel build, so make a guess at number of parallel jobs
Njobs = "1"
try:
    import psutil

    free = psutil.virtual_memory().free
    if free > 4e9:
        Njobs = "4"
    elif free > 2e9:
        Njobs = "2"
except ImportError:
    pass


url_stem = "https://github.com/Kitware/CMake/releases/download"

p = argparse.ArgumentParser()
p.add_argument("version", nargs="?")
p.add_argument("-prefix", default="~/.local")
p = p.parse_args()

prefix = Path(p.prefix).expanduser()

# get latest CMake version if not specified
version = p.version
if version is None:
    version = get_latest_version("git://github.com/kitware/cmake.git", r"\^\{\}$")

WD = Path("build")
WD.mkdir(exist_ok=True)

stem = f"cmake-{version}"
build_root = (WD / stem).resolve(strict=False)
cfn = f"{stem}-SHA-256.txt"
fn = f"{stem}.tar.gz"

# 0. check prereqs
if subprocess.run(["cmake", "--find-package", "-DNAME=OpenSSL", "-DCOMPILER_ID=GNU", "-DLANGUAGE=C", "-DMODE=EXIST"]).returncode:
    print("WARNING: SSL development library needed for typical CMake use", file=sys.stderr)

# 1. download
cmake_archive = WD / fn
url = f"{url_stem}/v{version}/{fn}"
if not cmake_archive.is_file():
    print("downloading", url)
    urllib.request.urlretrieve(url, cmake_archive)

# 2. build
cmake_sig = WD / cfn
url_sig = f"{url_stem}/v{version}/{cfn}"
if not cmake_sig.is_file():
    print("downloading", url_sig)
    urllib.request.urlretrieve(url_sig, cmake_sig)

print("checking SHA256 signature")
if not file_checksum(cmake_archive, cmake_sig, "sha256"):
    raise ValueError(f"{cmake_archive} SHA256 checksum did not match {cmake_sig}")

if not build_root.is_dir():
    print("extracting CMake source")
    with tarfile.open(str(cmake_archive)) as tf:
        tf.extractall(str(WD))

print("installing cmake:", prefix)

# CMake or bootstrap


def bootstrap(build_root: Path):
    if os.name == "nt":
        raise RuntimeError("CMake bootstrap is for Unix-like systems only")
    cmake_bootstrap = build_root / "bootstrap"
    if not cmake_bootstrap.is_file():
        raise FileNotFoundError(cmake_bootstrap)

    print("running CMake bootstrap", cmake_bootstrap)
    subprocess.check_call(
        [
            str(cmake_bootstrap),
            f"--prefix={prefix}",
            f"--parallel={Njobs}",
            "--",
            "-DCMAKE_BUILD_TYPE:STRING=Release",
            "-DCMAKE_USE_OPENSSL:BOOL=ON",
        ],
        cwd=build_root,
    )

    subprocess.check_call(["make", "-j", Njobs], cwd=build_root)

    print("installing cmake:", prefix)
    subprocess.check_call(["make", "install"], cwd=build_root)


prefix.mkdir(parents=True, exist_ok=True)

if shutil.which("cmake"):
    subprocess.check_call(
        ["cmake", ".", f"-DCMAKE_INSTALL_PREFIX={prefix}", "-DCMAKE_BUILD_TYPE:STRING=Release", "-DCMAKE_USE_OPENSSL:BOOL=ON"],
        cwd=build_root,
    )
    # --parallel is CMake >= 3.12, probably too new to require for now.
    # Ninja will build in parallel even without --parallel
    subprocess.check_call(["cmake", "--build", str(build_root), "--", "-j", Njobs])

    print("installing cmake:", prefix)
    subprocess.check_call(["cmake", "--build", str(build_root), "--target", "install"])
else:
    bootstrap(build_root)

print("\n----------------------------------------------------")
print(f"please add to your system PATH:  {prefix}/bin/")
print("\nreopen a new terminal to use CMake", version)
