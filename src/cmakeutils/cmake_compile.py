#!/usr/bin/env python3
"""
NOTE: most Linux users can simply download and install almost instantly
  instead of this lengthly compilation with cmake_setup.py

---

Does NOT use sudo

Compiles and installs CMake.

Alternative: use binary downloads from:

* pip install cmake
* https://cmake.org/download/

prereqs
CentOS:    yum install gcc-c++ make ncurses-devel openssl-devel unzip
Debian / Ubuntu: apt install g++ make libncurses-dev libssl-dev unzip
Cygwin: setup-x86_64.exe -P gcc-g++ make libncurses-devel libssl-devel

Git > 2.18 required, or specify CMake version at command line e.g.

python cmake_compile.py v3.18.1
"""

import tempfile
import argparse
import os
import sys
import subprocess
import tarfile
import shutil
import urllib.request
from pathlib import Path

from .cmake_setup import get_latest_version, file_checksum

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


def main():
    p = argparse.ArgumentParser()
    p.add_argument("version", nargs="?")
    p.add_argument("-prefix", default="~/.local")
    p = p.parse_args()

    prefix = Path(p.prefix).expanduser()

    # get latest CMake version if not specified
    version = get_latest_version("git://github.com/kitware/cmake.git", tail=r"\^\{\}$", request=p.version)

    WD = Path(tempfile.gettempdir())
    WD.mkdir(exist_ok=True)

    stem = f"cmake-{version}"
    src_root = (WD / stem).resolve(strict=False)
    cfn = f"{stem}-SHA-256.txt"
    fn = f"{stem}.tar.gz"

    # 0. check prereqs
    if subprocess.run(
        ["cmake", "--find-package", "-DNAME=OpenSSL", "-DCOMPILER_ID=GNU", "-DLANGUAGE=C", "-DMODE=EXIST"]
    ).returncode:
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

    if not src_root.is_dir():
        print("extracting CMake source")
        with tarfile.open(str(cmake_archive)) as tf:
            tf.extractall(str(WD))

    print("installing cmake:", prefix)

    # CMake or bootstrap

    def bootstrap(src_root: Path):
        if os.name == "nt":
            raise RuntimeError("CMake bootstrap is for Unix-like systems only")
        cmake_bootstrap = src_root / "bootstrap"
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
            cwd=src_root,
        )

        subprocess.check_call(["make", "-j", Njobs], cwd=src_root)

        print("installing cmake:", prefix)
        subprocess.check_call(["make", "install"], cwd=src_root)

    prefix.mkdir(parents=True, exist_ok=True)

    if shutil.which("cmake"):
        build_root = src_root / "build"
        subprocess.check_call(
            [
                "cmake",
                "-S",
                str(src_root),
                "-B",
                str(build_root),
                f"-DCMAKE_INSTALL_PREFIX={prefix}",
                "-DCMAKE_BUILD_TYPE:STRING=Release",
                "-DCMAKE_USE_OPENSSL:BOOL=ON",
            ]
        )

        subprocess.check_call(["cmake", "--build", str(build_root), "--parallel", Njobs])

        print("installing cmake:", prefix)
        subprocess.check_call(["cmake", "--install", str(build_root)])
    else:
        bootstrap(build_root)

    print("\n----------------------------------------------------")
    print(f"please add to your system PATH:  {prefix}/bin/")
    print("\nreopen a new terminal to use CMake", version)


if __name__ == "__main__":
    main()
