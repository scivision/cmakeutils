#!/usr/bin/env python
"""
Download, checksum and install CMake
for Linux, Mac and Windows

Automatically determines URL of latest CMake via Git >= 2.18, or manual choice.
"""
from argparse import ArgumentParser

import cmakeutils as cm


def main():
    p = ArgumentParser()
    p.add_argument("version", help="request CMake version (default latest)", nargs="?")
    p.add_argument(
        "-o", "--outdir", help="download archive directory", default="~/Downloads"
    )
    p.add_argument(
        "--prefix", help="Linux install prefix to install under", default="~/.local"
    )
    p.add_argument("-q", "--quiet", help="non-interactive install", action="store_true")
    p.add_argument("-n", "--dryrun", help="just check version", action="store_true")
    p.add_argument(
        "--force",
        help="reinstall CMake even if the latest version is already installed",
        action="store_true",
    )
    P = p.parse_args()

    cm.cli(P)


if __name__ == "__main__":
    main()
