#!/usr/bin/env python3
"""
Download, checksum and install CMake
for Linux, Mac and Windows

Automatically determines URL of latest CMake via Git >= 2.18, or manual choice.
"""
from pathlib import Path
from argparse import ArgumentParser, Namespace
import shutil
import pkg_resources
import subprocess
import re
import sys
import typing
import urllib.request
import hashlib
import platform
import tarfile

HEAD = "https://github.com/Kitware/CMake/releases/download/"
PLATFORMS = ("amd64", "x86_64", "x64", "i86pc")


def main():
    p = ArgumentParser()
    p.add_argument("version", help="request version (default latest)", nargs="?")
    p.add_argument("-o", "--outdir", help="download archive directory", default="~/Downloads")
    p.add_argument("--prefix", help="Path prefix to install CMake under", default="~/.local")
    p.add_argument("-q", "--quiet", help="non-interactive install", action="store_true")
    p.add_argument("-n", "--dryrun", help="just check version", action="store_true")
    p.add_argument(
        "--force", help="reinstall CMake even if the latest version is already installed", action="store_true",
    )
    P = p.parse_args()

    cli(P)


def check_git_version(min_version: str) -> bool:
    """
    checks that Git of a minimum required version is available
    """
    git = shutil.which("git")
    if not git:
        return False

    ret = subprocess.check_output([git, "--version"], universal_newlines=True).split()[2]
    git_version = pkg_resources.parse_version(ret[:6])
    return git_version >= pkg_resources.parse_version(min_version)


def get_latest_version(repo: str, tail: str = "") -> str:
    """
    get latest version using Git
    """

    if not check_git_version("2.18"):
        raise RuntimeError(
            "Git >= 2.18 required for auto latest version--try specifying version manually."
        )

    cmd = [
        "git",
        "ls-remote",
        "--tags",
        "--sort=v:refname", repo
    ]
    lastrev = subprocess.check_output(cmd, universal_newlines=True).strip().split("\n")[-1]
    pat = r".*refs/tags/v(\w+\.\w+\.\w+.*)" + tail

    mat = re.match(pat, lastrev)
    if not mat:
        raise ValueError("Could not determine latest version. Please report this bug.  \nInput: \n {}".format(lastrev))

    latest_version = mat.group(1)

    return latest_version


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


def check_cmake_version(min_version: str) -> bool:
    cmake = shutil.which("cmake")
    if not cmake:
        return False

    cmake_version = subprocess.check_output([cmake, "--version"], universal_newlines=True).split()[2]

    pmin = pkg_resources.parse_version(min_version)
    pcmake = pkg_resources.parse_version(cmake_version)

    return pcmake >= pmin


def install_cmake(
    cmake_version: str, outfile: Path, prefix: Path = None, stem: str = None, quiet: bool = False,
):
    if sys.platform == "darwin":
        raise ValueError("please install CMake {} from disk image {} or do\n brew install cmake".format(cmake_version, outfile))
    elif sys.platform == "linux":
        if platform.machine().lower() not in PLATFORMS:
            raise ValueError("This method is for Linux 64-bit x86_64 systems")
        prefix = Path(prefix).expanduser().resolve()
        prefix.mkdir(parents=True, exist_ok=True)
        print("Installing CMake to", prefix)
        with tarfile.open(str(outfile)) as tf:
            tf.extractall(str(prefix))

        stanza = f"export PATH={prefix / stem}/bin:$PATH"
        for c in ('~/.bashrc', '~/.profile'):
            cfn = Path(c).expanduser()
            if cfn.is_file():
                print(f"\n\n add to", cfn, stanza)
                break

    elif sys.platform == "win32":
        passive = "/passive" if quiet else ""
        cmd = ["msiexec", passive, "/package", str(outfile)]
        print(" ".join(cmd))
        # without shell=True, install will fail
        subprocess.run(" ".join(cmd), shell=True)


def cmake_files(cmake_version: str, odir: Path) -> typing.Tuple[Path, str, str]:
    """
    this relies on the per-OS naming scheme used by Kitware in their GitHub Releases
    """

    stem = ""
    if sys.platform == "cygwin":
        raise ValueError("use Cygwin setup.exe to install CMake, or manual compile")
    elif sys.platform == "darwin":
        ofn = "cmake-{}-Darwin-x86_64.dmg".format(cmake_version)
        url = HEAD + "v{}/{}".format(cmake_version, ofn)
    elif sys.platform == "linux":
        if platform.machine().lower() not in PLATFORMS:
            raise ValueError("This method is for Linux 64-bit x86_64 systems")
        stem = "cmake-{}-Linux-x86_64".format(cmake_version)
        ofn = "{}.tar.gz".format(stem)
        url = HEAD + "v{}/{}".format(cmake_version, ofn)
    elif sys.platform == "win32":
        ofn = "cmake-{}-win64-x64.msi".format(cmake_version)
        url = HEAD + "v{}/{}".format(cmake_version, ofn)
    else:
        raise ValueError("unknown platform {}".format(sys.platform))

    outfile = odir / ofn

    return outfile, url, stem


def cli(P: Namespace):
    odir = Path(P.outdir).expanduser()
    odir.mkdir(parents=True, exist_ok=True)

    if P.version:
        get_version = P.version
    else:
        get_version = get_latest_version("git://github.com/kitware/cmake.git", r"\^\{\}$")

        if not P.force and check_cmake_version(get_version):
            print("You already have the latest CMake version {}".format(get_version))
            return

    if P.dryrun:
        print("CMake {} is available".format(get_version))
        return

    outfile, url, stem = cmake_files(get_version, odir)
    # %% checksum
    hashstem = "cmake-{}-SHA-256.txt".format(get_version)
    hashurl = HEAD + "v{}/{}".format(get_version, hashstem)
    hashfile = odir / hashstem

    if not hashfile.is_file() or hashfile.stat().st_size == 0:
        url_retrieve(hashurl, hashfile)

    if not outfile.is_file() or outfile.stat().st_size < 1e6:
        url_retrieve(url, outfile)

    if not file_checksum(outfile, hashfile, "sha256"):
        raise ValueError("{} SHA256 checksum did not match {}".format(outfile, hashfile))

    install_cmake(get_version, outfile, P.prefix, stem, P.quiet)


if __name__ == "__main__":
    main()
