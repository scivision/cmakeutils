#!/usr/bin/env python3
"""
Download and install Ninja
for Linux, Mac and Windows

Automatically determines URL of latest version or manual choice.
"""

import tempfile
from pathlib import Path
from argparse import ArgumentParser, Namespace
import zipfile
import sys
import os
import stat
import urllib.request
import platform


HEAD = "https://github.com/ninja-build/ninja/releases/download"
ninja_files = {"win32": "ninja-win.zip", "darwin": "ninja-mac.zip", "linux": "ninja-linux.zip"}
PLATFORMS = ("amd64", "x86_64", "x64", "i86pc")
VERSION = "1.10.2"


def main():
    p = ArgumentParser()
    p.add_argument("version", help="request version (default latest)", nargs="?", default=VERSION)
    p.add_argument("--prefix", help="Path prefix to install under", default="~/.local/bin")
    P = p.parse_args()

    cli(P)


def cli(P: Namespace):
    if sys.platform in ("darwin", "linux"):
        if platform.machine().lower() not in PLATFORMS:
            raise ValueError("This method is for Linux 64-bit x86_64 systems")

    outfile = Path(tempfile.gettempdir()) / ninja_files[sys.platform]

    url = f"{HEAD}/v{P.version}/{outfile.name}"

    url_retrieve(url, outfile)

    install_ninja(outfile, P.prefix)


def url_retrieve(url: str, outfile: Path):
    print("downloading", url)
    outfile = Path(outfile).expanduser().resolve()
    if outfile.is_dir():
        raise ValueError("Please specify full filepath, including filename")
    outfile.parent.mkdir(parents=True, exist_ok=True)

    urllib.request.urlretrieve(url, str(outfile))


def install_ninja(outfile: Path, prefix: Path = None):

    prefix = Path(prefix).expanduser().resolve()

    if sys.platform in ("darwin", "linux"):
        if platform.machine().lower() not in PLATFORMS:
            raise ValueError("This method is for Linux 64-bit x86_64 systems")
        stanza = f"export PATH={prefix}:$PATH"
        for c in ("~/.bashrc", "~/.zshrc", "~/.profile"):
            cfn = Path(c).expanduser()
            if cfn.is_file():
                print("\n add to", cfn, "\n\n", stanza)
                break
    else:
        print("add to PATH environment variable:")
        print(prefix)

    # %% extract ninja exe
    prefix.mkdir(parents=True, exist_ok=True)
    print("Installing to", prefix)

    member = "ninja"
    if os.name == "nt":
        member += ".exe"

    with zipfile.ZipFile(outfile) as z:
        z.extract(member, str(prefix))

    os.chmod(prefix / member, stat.S_IRWXU)


if __name__ == "__main__":
    main()
