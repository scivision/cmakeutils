#!/usr/bin/env python3
"""
Download and install Ninja
for Linux, Mac and Windows

Automatically determines URL of latest version or manual choice.
"""

import tempfile
import importlib.resources
import json
from pathlib import Path
from argparse import ArgumentParser, Namespace
import zipfile
import sys
import os
import stat
import platform

from .cmake_setup import url_retrieve


ninja_files = {"win32": "ninja-win.zip", "darwin": "ninja-mac.zip", "linux": "ninja-linux.zip"}
PLATFORMS = ("amd64", "x86_64", "x64", "i86pc")


def latest_version() -> str:
    return json.load(importlib.resources.open_text("cmakeutils", "versions.json"))["ninja"][
        "latest"
    ]


def get_host() -> str:
    return json.load(importlib.resources.open_text("cmakeutils", "versions.json"))["ninja"][
        "binary"
    ]


def main():
    p = ArgumentParser()
    p.add_argument(
        "version", help="request version (default latest)", nargs="?", default=latest_version()
    )
    p.add_argument("--prefix", help="Path prefix to install under", default="~/.local/bin")
    P = p.parse_args()

    cli(P)


def cli(P: Namespace):
    if sys.platform in ("darwin", "linux"):
        if platform.machine().lower() not in PLATFORMS:
            raise ValueError("This method is for Linux 64-bit x86_64 systems")

    outfile = Path(tempfile.gettempdir()) / ninja_files[sys.platform]

    url = f"{get_host()}v{P.version}/{outfile.name}"

    url_retrieve(url, outfile)

    install_ninja(outfile, P.prefix)


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
