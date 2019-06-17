import subprocess
from typing import Tuple
from pathlib import Path
import sys
import tarfile

HEAD = 'https://github.com/Kitware/CMake/releases/download/'


def install_cmake(cmake_version: str, outfile: Path,
                  install_path: Path = None, stem: str = None,
                  quiet: bool = False):
    if sys.platform == 'darwin':
        raise ValueError('please install CMake {} from disk image {} or do\n brew install cmake'.format(cmake_version, outfile))
    elif sys.platform == 'linux':
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
        subprocess.run(['msiexec', passive, '/package', str(outfile)])


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
