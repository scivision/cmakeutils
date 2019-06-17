#!/usr/bin/env python
"""
Download, checksum and install CMake
for Linux, Mac and Windows

Automatically determines URL of latest CMake via Git >= 2.18, or manual choice.
"""
from argparse import ArgumentParser
from pathlib import Path
import shutil
import subprocess

import cmakeutils as cm


def main():
    p = ArgumentParser()
    p.add_argument('version', help='request CMake version (default latest)', nargs='?')
    p.add_argument('-o', '--outdir', help='download directory', default='~/Downloads')
    p.add_argument('--install_path', help='Linux install path', default='~/.local')
    p.add_argument('-q', '--quiet', help='non-interactive install', action='store_true')
    p.add_argument('-n', '--dryrun', help='just check version', action='store_true')
    p.add_argument('--force', help='reinstall CMake even if the latest version is already installed', action='store_true')
    P = p.parse_args()

    odir = Path(P.outdir).expanduser()
    odir.mkdir(parents=True, exist_ok=True)

    if P.version:
        get_version = P.version
    else:
        get_version = cm.latest_cmake_version()

    if not P.force:
        cmake = shutil.which('cmake')
        if cmake:
            cmake_version = subprocess.check_output([cmake, '--version'], universal_newlines=True).split()[2]
            if get_version == cmake_version:
                print('You already have the latest CMake version {}'.format(get_version))
                return

    if P.dryrun:
        print('CMake {} is available'.format(get_version))
        return

    outfile, url, stem = cm.cmake_files(get_version, odir)
# %% checksum
    hashstem = 'cmake-{}-SHA-256.txt'.format(get_version)
    hashurl = cm.HEAD + 'v{}/{}'.format(get_version, hashstem)
    hashfile = odir / hashstem

    if not hashfile.is_file() or hashfile.stat().st_size == 0:
        cm.url_retrieve(hashurl, hashfile)

    if not outfile.is_file() or outfile.stat().st_size < 1e6:
        cm.url_retrieve(url, outfile)

    if not cm.file_checksum(outfile, hashfile, 'sha256'):
        raise ValueError('{} SHA256 checksum did not match {}'.format(outfile, hashfile))

    cm.install_cmake(get_version, outfile, P.install_path, stem, P.quiet)


if __name__ == '__main__':
    main()
