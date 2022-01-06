#!/usr/bin/env python3
"""
Download, checksum and install CMake
for Linux, Mac and Windows

Automatically determines URL of latest CMake via Git >= 2.18, or manual choice.
"""

from __future__ import annotations
from pathlib import Path
import importlib.resources
import argparse
import json
import subprocess
import sys
import shutil
import urllib.request
import hashlib
import platform
import tarfile
import zipfile
import tempfile

PLATFORMS = ("amd64", "x86_64", "x64", "i86pc")


def latest_version() -> str:
    cjd = json.load(importlib.resources.open_text("cmakeutils", "versions.json"))["cmake"]
    return cjd[cjd["latest"]]


def get_host() -> str:
    return json.load(importlib.resources.open_text("cmakeutils", "versions.json"))["cmake"][
        "binary"
    ]


def url_retrieve(url: str, outfile: Path):
    print("downloading", url)
    outfile = Path(outfile).expanduser().resolve()
    if outfile.is_dir():
        raise ValueError("Please specify full filepath, including filename")
    outfile.parent.mkdir(parents=True, exist_ok=True)

    urllib.request.urlretrieve(url, str(outfile))


def file_checksum(fn: Path, hashfn: Path, mode: str) -> bool:
    h = hashlib.new(mode)
    h.update(fn.read_bytes())
    digest = h.hexdigest()

    with hashfn.open("r") as f:
        for line in f:
            if line.startswith(digest):
                if line.split()[-1] == fn.name:
                    return True

    return False


def install_cmake(outfile: Path, prefix: Path = None):

    if sys.platform == "darwin":
        brew = shutil.which("brew")
        if brew:
            subprocess.check_call(["brew", "install", "cmake"])
        else:
            raise OSError("Use Homebrew to install CMake   https://brew.sh")
    elif sys.platform == "linux":
        if platform.machine().lower() not in PLATFORMS:
            raise ValueError("This method is for Linux 64-bit x86_64 systems")

    prefix = Path(prefix).expanduser().resolve()
    prefix.mkdir(parents=True, exist_ok=True)
    print("Installing CMake to", prefix)

    if outfile.suffix == ".gz":
        with tarfile.open(outfile) as t:
            t.extractall(str(prefix))
        stem = outfile.name.split(".tar.gz")[0]
        # .stem doesn't work as intended for multiple suffixes:  Path("foo.tar.gz").stem == "foo.tar"
    elif outfile.suffix == ".zip":
        with zipfile.ZipFile(outfile) as z:
            z.extractall(str(prefix))
        stem = outfile.stem
    else:
        raise ValueError(f"Unsure how to extract {outfile}")

    if sys.platform == "linux":
        stanza = f"export PATH={prefix / stem}/bin:$PATH"
        for c in ("~/.bashrc", "~/.profile"):
            cfn = Path(c).expanduser()
            if cfn.is_file():
                print("\n\n add to", cfn, stanza)
                break
    elif sys.platform == "win32":
        print(f"add to PATH: {prefix / stem}/bin")
    else:
        raise ValueError(f"Unsure how to install CMake for {sys.platform}")


def cmake_files(cmake_version: str, odir: Path) -> tuple[Path, str]:
    """
    this relies on the per-OS naming scheme used by Kitware in their GitHub Releases
    """

    if sys.platform == "cygwin":
        raise ValueError("use Cygwin setup.exe to install CMake, or manual compile")
    elif sys.platform == "darwin":
        raise ValueError("use brew install cmake, or manual compile")
    elif sys.platform == "linux":
        if platform.machine().lower() not in PLATFORMS:
            raise ValueError("This method is for Linux 64-bit x86_64 systems")
        tail = "linux-x86_64.tar.gz"
    elif sys.platform == "win32":
        tail = "windows-x86_64.zip"
    else:
        raise ValueError(f"unknown platform {sys.platform}")

    ofn = f"cmake-{cmake_version}-{tail}"

    return odir / ofn, f"{cmake_version}/{ofn}"


def download_cmake(outdir: Path, get_version: str) -> Path:

    host = get_host()

    outdir = Path(outdir).expanduser()
    outdir.mkdir(parents=True, exist_ok=True)
    outfile, tail = cmake_files(get_version, outdir)
    # %% checksum
    hashstem = f"cmake-{get_version}-SHA-256.txt"
    hashurl = f"{host}v{get_version}/{hashstem}"
    hashfile = outdir / hashstem

    if not hashfile.is_file() or hashfile.stat().st_size == 0:
        url_retrieve(hashurl, hashfile)

    if not outfile.is_file() or outfile.stat().st_size < 1e6:
        url_retrieve(f"{host}v{tail}", outfile)

    if not file_checksum(outfile, hashfile, "sha256"):
        raise ValueError(f"{outfile} SHA256 checksum did not match {hashfile}")

    return outfile


def main():
    p = argparse.ArgumentParser()
    p.add_argument(
        "version", help="request version (default latest)", nargs="?", default=latest_version()
    )
    p.add_argument(
        "-o", "--outdir", help="download archive directory", default=tempfile.gettempdir()
    )
    p.add_argument("--prefix", help="Path prefix to install CMake under", default="~")
    P = p.parse_args()

    outfile = None if sys.platform == "darwin" else download_cmake(P.outdir, P.version)

    install_cmake(outfile, P.prefix)


if __name__ == "__main__":
    main()
