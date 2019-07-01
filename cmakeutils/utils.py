import subprocess
from typing import Tuple
from pathlib import Path
import sys
import tarfile
import pkg_resources
import shutil
import platform
from argparse import Namespace

from .git import latest_cmake_version
from .io import url_retrieve, file_checksum

HEAD = 'https://github.com/Kitware/CMake/releases/download/'
PLATFORMS = ('amd64', 'x86_64', 'x64', 'i86pc')


def check_cmake_version(min_version: str) -> bool:
    cmake = shutil.which('cmake')
    if not cmake:
        return False

    cmake_version = subprocess.check_output([cmake, '--version'], universal_newlines=True).split()[2]

    pmin = pkg_resources.parse_version(min_version)
    pcmake = pkg_resources.parse_version(cmake_version)

    return pcmake >= pmin


def install_cmake(cmake_version: str, outfile: Path,
                  install_path: Path = None, stem: str = None,
                  quiet: bool = False):
    if sys.platform == 'darwin':
        raise ValueError('please install CMake {} from disk image {} or do\n brew install cmake'.format(cmake_version, outfile))
    elif sys.platform == 'linux':
        if platform.machine().lower() not in PLATFORMS:
            raise ValueError('This method is for Linux 64-bit x86_64 systems')
        assert isinstance(install_path, (str, Path))
        assert isinstance(stem, str)
        instpath = Path(install_path).expanduser()
        instpath.mkdir(parents=True, exist_ok=True)
        print('Installing CMake to', instpath)
        with tarfile.open(str(outfile)) as tf:
            tf.extractall(str(instpath))
        print('add to ~/.bashrc:')
        print('export PATH={}:$PATH'.format(instpath/stem/'bin'))
    elif sys.platform == 'win32':
        passive = '/passive' if quiet else ''
        cmd = ['msiexec', passive, '/package', str(outfile)]
        print(' '.join(cmd))
        # without shell=True, install will fail
        subprocess.run(' '.join(cmd), shell=True)


def cmake_files(cmake_version: str, odir: Path) -> Tuple[Path, str, str]:
    """
    this relies on the per-OS naming scheme used by Kitware in their GitHub Releases
    """

    stem = ''
    if sys.platform == 'cygwin':
        raise ValueError('use Cygwin setup.exe to install CMake, or manual compile')
    elif sys.platform == 'darwin':
        ofn = 'cmake-{}-Darwin-x86_64.dmg'.format(cmake_version)
        url = HEAD + 'v{}/{}'.format(cmake_version, ofn)
    elif sys.platform == 'linux':
        if platform.machine().lower() not in PLATFORMS:
            raise ValueError('This method is for Linux 64-bit x86_64 systems')
        stem = 'cmake-{}-Linux-x86_64'.format(cmake_version)
        ofn = '{}.tar.gz'.format(stem)
        url = HEAD + 'v{}/{}'.format(cmake_version, ofn)
    elif sys.platform == 'win32':
        ofn = 'cmake-{}-win64-x64.msi'.format(cmake_version)
        url = HEAD + 'v{}/{}'.format(cmake_version, ofn)
    else:
        raise ValueError('unknown platform {}'.format(sys.platform))

    outfile = odir / ofn

    return outfile, url, stem


def cli(P: Namespace):
    odir = Path(P.outdir).expanduser()
    odir.mkdir(parents=True, exist_ok=True)

    if P.version:
        get_version = P.version
    else:
        get_version = latest_cmake_version()

        if not P.force and check_cmake_version(get_version):
            print('You already have the latest CMake version {}'.format(get_version))
            return

    if P.dryrun:
        print('CMake {} is available'.format(get_version))
        return

    outfile, url, stem = cmake_files(get_version, odir)
# %% checksum
    hashstem = 'cmake-{}-SHA-256.txt'.format(get_version)
    hashurl = HEAD + 'v{}/{}'.format(get_version, hashstem)
    hashfile = odir / hashstem

    if not hashfile.is_file() or hashfile.stat().st_size == 0:
        url_retrieve(hashurl, hashfile)

    if not outfile.is_file() or outfile.stat().st_size < 1e6:
        url_retrieve(url, outfile)

    if not file_checksum(outfile, hashfile, 'sha256'):
        raise ValueError('{} SHA256 checksum did not match {}'.format(outfile, hashfile))

    install_cmake(get_version, outfile, P.install_path, stem, P.quiet)
