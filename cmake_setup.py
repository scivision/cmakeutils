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

from cmakeutils import latest_cmake_version, cmake_files, HEAD, install_cmake, url_retrieve, file_checksum


def main():
    p = ArgumentParser()
    p.add_argument('version', help='request CMake version (default latest)', nargs='?')
    p.add_argument('-o', '--outdir', help='download directory', default='~/Downloads')
    p.add_argument('--install_path', help='Linux install path', default='~/.local')
    p.add_argument('-q', '--quiet', help='non-interactive install', action='store_true')
    p.add_argument('--force', help='reinstall CMake even if the latest version is already installed', action='store_true')
    P = p.parse_args()

    odir = Path(P.outdir).expanduser()
    odir.mkdir(parents=True, exist_ok=True)

    if P.version:
        get_version = P.version
    else:
        get_version = latest_cmake_version(P.force)

    if not P.force:
        cmake = shutil.which('cmake')
        if cmake:
            cmake_version = subprocess.check_output([cmake, '--version'], universal_newlines=True).split()[2]
            if get_version == cmake_version:
                raise SystemExit('You already have the latest CMake version {}'.format(get_version))

    outfile, url, stem = cmake_files(cmake_version, odir)
# %% checksum
    hashstem = 'cmake-{}-SHA-256.txt'.format(cmake_version)
    hashurl = HEAD + 'v{}/{}'.format(cmake_version, hashstem)
    hashfile = odir / hashstem

    if not hashfile.is_file() or hashfile.stat().st_size == 0:
        url_retrieve(hashurl, hashfile)

    if not outfile.is_file() or outfile.stat().st_size < 1e6:
        url_retrieve(url, outfile)

    if not file_checksum(outfile, hashfile, 'sha256'):
        raise RuntimeError('File checksum did not match')

    install_cmake(cmake_version, outfile, P.install_path, stem, P.quiet)


if __name__ == '__main__':
    main()
