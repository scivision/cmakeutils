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
        Njobs = ""
    elif free > 2e9:
        Njobs = "2"
except ImportError:
    pass

url_stem = "https://github.com/Kitware/CMake/releases/download"


def main():
    p = argparse.ArgumentParser()
    p.add_argument("version", nargs="?")
    p.add_argument("-prefix", help="where to install CMake")
    p.add_argument("-workdir", help="use existing source code path")
    p = p.parse_args()

    # 0. check prereqs
    if subprocess.run(
        ["cmake", "--find-package", "-DNAME=OpenSSL", "-DCOMPILER_ID=GNU", "-DLANGUAGE=C", "-DMODE=EXIST"]
    ).returncode:
        print("WARNING: SSL development library needed for typical CMake use", file=sys.stderr)

    # 1. download
    if p.workdir:
        src_root = Path(p.workdir).expanduser()
    else:
        # get latest CMake version if not specified
        version = get_latest_version("git://github.com/kitware/cmake.git", tail=r"\^\{\}$", request=p.version)

        src_root = download_and_extract(tempfile.gettempdir(), version)

    prefix = None
    if p.prefix:
        prefix = Path(p.prefix).expanduser()
        print("installing cmake:", prefix)
        prefix.mkdir(parents=True, exist_ok=True)

    if shutil.which("cmake"):
        cmake_build(src_root, prefix)
    else:
        bootstrap(src_root, prefix)

    print("\n----------------------------------------------------")
    if prefix:
        print(f"please add to your system PATH:  {prefix}/bin/")
        print("\nreopen a new terminal to use CMake", version)
    else:
        print(f"CMake built under {src_root}")
        print("To install CMake, rerun using cmake_compile -prefix option set to desired install path.")


def cmake_build(src_root: Path, prefix: Path):

    build_root = src_root / "build"

    opts = [
        "-DCMAKE_BUILD_TYPE:STRING=Release",
        "-DCMAKE_USE_OPENSSL:BOOL=ON",
    ]
    if prefix:
        opts.append(f"-DCMAKE_INSTALL_PREFIX={prefix}")

    subprocess.check_call(["cmake", "-S", str(src_root), "-B", str(build_root)] + opts)

    popts = ["--parallel"]
    if Njobs:
        popts.append(Njobs)
    subprocess.check_call(["cmake", "--build", str(build_root)] + popts)

    if prefix:
        print("installing cmake:", prefix)
        subprocess.check_call(["cmake", "--install", str(build_root)])


def bootstrap(src_root: Path, prefix: Path):
    """ cmake Unix bootstrap """

    if os.name == "nt":
        raise RuntimeError("CMake bootstrap is for Unix-like systems only")

    cmake_bootstrap = src_root / "bootstrap"
    if not cmake_bootstrap.is_file():
        raise FileNotFoundError(cmake_bootstrap)

    opts = [
        "--",
        "-DCMAKE_BUILD_TYPE:STRING=Release",
        "-DCMAKE_USE_OPENSSL:BOOL=ON",
    ]

    if prefix:
        opts.append(f"--prefix={prefix}")
    if Njobs:
        opts.append(f"--parallel={Njobs}")

    print("running CMake bootstrap", cmake_bootstrap)
    subprocess.check_call(
        [str(cmake_bootstrap)] + opts, cwd=src_root,
    )

    popts = ["-j"]
    if Njobs:
        popts.append(Njobs)

    subprocess.check_call(["make"] + popts, cwd=src_root)

    if prefix:
        print("installing cmake:", prefix)
        subprocess.check_call(["make", "install"], cwd=src_root)


def download_and_extract(workdir: Path, version: str) -> Path:

    workdir = Path(workdir)
    workdir.mkdir(exist_ok=True)
    stem = f"cmake-{version}"
    src_root = (workdir / stem).resolve(strict=False)
    cfn = f"{stem}-SHA-256.txt"
    fn = f"{stem}.tar.gz"

    cmake_archive = workdir / fn
    url = f"{url_stem}/v{version}/{fn}"
    if not cmake_archive.is_file():
        print("downloading", url)
        urllib.request.urlretrieve(url, cmake_archive)

    # 2. build
    cmake_sig = workdir / cfn
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
            tf.extractall(str(workdir))

    return src_root


if __name__ == "__main__":
    main()
