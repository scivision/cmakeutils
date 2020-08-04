#!/usr/bin/env python3
"""
Download, checksum and install CMake
for Linux, Mac and Windows

Automatically determines URL of latest CMake via Git >= 2.18, or manual choice.
"""
from pathlib import Path
import argparse
import subprocess
import re
import sys
import typing as T
import shutil
import urllib.request
import hashlib
import platform
import tarfile
import zipfile

HEAD = "https://github.com/Kitware/CMake/releases/download/"
PLATFORMS = ("amd64", "x86_64", "x64", "i86pc")


def get_latest_version(repo: str, *, tail: str = "", request: str = None) -> str:
    """
    get latest version using Git
    """

    git = shutil.which("git")
    if not git:
        raise FileNotFoundError("Git required to download CMake")

    cmd = [git, "ls-remote", "--tags", "--sort=v:refname", repo]
    revs = subprocess.check_output(cmd, universal_newlines=True).strip().split("\n")
    pat = r".*refs/tags/v(\w+\.\w+\.\w+.*)" + tail

    versions = []
    for v in revs:
        mat = re.match(pat, v)
        if mat:
            versions.append(mat.group(1))

    if request:
        if request in versions:
            return request
        raise ValueError(f"version {request} is not available. Available versions: {versions}")

    return versions[-1]


def url_retrieve(url: str, outfile: Path):
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


def install_cmake(
    cmake_version: str, outfile: Path, prefix: Path = None, quiet: bool = False,
):

    if sys.platform == "darwin":
        brew = shutil.which("brew")
        if brew:
            subprocess.check_call(["brew", "install", "cmake"])
        else:
            subprocess.check_call(["pip", "install", "cmake"])
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


def cmake_files(cmake_version: str, odir: Path) -> T.Tuple[Path, str]:
    """
    this relies on the per-OS naming scheme used by Kitware in their GitHub Releases
    """

    if sys.platform == "cygwin":
        raise ValueError("use Cygwin setup.exe to install CMake, or manual compile")
    elif sys.platform == "darwin":
        tail = "Darwin-x86_64.dmg"
    elif sys.platform == "linux":
        if platform.machine().lower() not in PLATFORMS:
            raise ValueError("This method is for Linux 64-bit x86_64 systems")
        tail = "Linux-x86_64.tar.gz"
    elif sys.platform == "win32":
        tail = "win64-x64.zip"
    else:
        raise ValueError(f"unknown platform {sys.platform}")

    ofn = f"cmake-{cmake_version}-{tail}"

    return odir / ofn, HEAD + f"v{cmake_version}/{ofn}"


def download_cmake(outdir: Path, get_version: str) -> Path:

    outdir = Path(outdir).expanduser()
    outdir.mkdir(parents=True, exist_ok=True)
    outfile, url = cmake_files(get_version, outdir)
    # %% checksum
    hashstem = f"cmake-{get_version}-SHA-256.txt"
    hashurl = HEAD + f"v{get_version}/{hashstem}"
    hashfile = outdir / hashstem

    if not hashfile.is_file() or hashfile.stat().st_size == 0:
        url_retrieve(hashurl, hashfile)

    if not outfile.is_file() or outfile.stat().st_size < 1e6:
        url_retrieve(url, outfile)

    if not file_checksum(outfile, hashfile, "sha256"):
        raise ValueError(f"{outfile} SHA256 checksum did not match {hashfile}")

    return outfile


def check_cmake_version(min_version: str) -> bool:
    cmake = shutil.which("cmake")
    if not cmake:
        return False

    cmake_version = subprocess.check_output([cmake, "--version"], universal_newlines=True).split()[2]

    try:
        import pkg_resources

        return pkg_resources.parse_version(cmake_version) >= pkg_resources.parse_version(min_version)
    except ImportError:
        print(f"CMake {cmake_version} already installed.")

    return None


def main():
    p = argparse.ArgumentParser()
    p.add_argument("version", help="request version (default latest)", nargs="?")
    p.add_argument("-o", "--outdir", help="download archive directory", default="~/Downloads")
    p.add_argument("--prefix", help="Path prefix to install CMake under", default="~/.local")
    p.add_argument("-q", "--quiet", help="non-interactive install", action="store_true")
    p.add_argument("-n", "--dryrun", help="just check version", action="store_true")
    P = p.parse_args()

    get_version = get_latest_version("git://github.com/kitware/cmake.git", tail=r"\^\{\}$", request=P.version)

    if not P.version and check_cmake_version(get_version):
        print(f"You already have the latest CMake {get_version}")
        return

    if P.dryrun:
        print(f"CMake {get_version} is available")
        return

    if sys.platform != "darwin":
        outfile = download_cmake(P.outdir, get_version)
    else:
        outfile = None

    install_cmake(get_version, outfile, P.prefix, P.quiet)


if __name__ == "__main__":
    main()
