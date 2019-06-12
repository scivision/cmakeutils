import re
import shutil
import pkg_resources
import subprocess
from typing import Tuple
from pathlib import Path
import sys
import tarfile
import requests
import hashlib

HEAD = 'https://github.com/Kitware/CMake/releases/download/'


def url_retrieve(url: str, outfile: Path):
    print('downloading', url, '=>', outfile)
    R = requests.get(url, allow_redirects=True)
    if R.status_code != 200:
        raise ConnectionError('could not download {}   error {}'.format(url, R.status_code))

    outfile.write_bytes(R.content)


def file_checksum(fn: Path, hashfn: Path, mode: str) -> bool:
    h = hashlib.new(mode)
    with fn.open('rb') as f:
        data = f.read()
    h.update(data)
    digest = h.hexdigest()

    with hashfn.open('r') as f:
        for line in f:
            if line.startswith(digest):
                if line.split()[-1] == fn.name:
                    return True

    return False


def install_cmake(cmake_version: str, outfile: Path,
                  install_path: Path = None, stem: str = None,
                  quiet: bool = False):
    if sys.platform == 'darwin':
        print('please install CMake {} from disk image {} or do\n brew install cmake'.format(cmake_version, outfile))
    elif sys.platform == 'linux':
        assert isinstance(install_path, (str, Path))
        assert isinstance(stem, str)
        instpath = Path(install_path).expanduser()
        instpath.mkdir(parents=True, exist_ok=True)
        print('Installing CMake to', instpath)
        with tarfile.open(str(outfile)) as tf:
            tf.extractall(str(instpath))
        print('add to ~/.bashrc:')
        print('export PATH={}:$PATH'.format(instpath/'cmake/bin'))
    elif sys.platform == 'win32':
        passive = '/passive' if quiet else ''
        subprocess.run(['msiexec', passive, '/package', str(outfile)])


def cmake_files(cmake_version: str, odir: Path) -> Tuple[Path, str, str]:

    stem = ''
    if sys.platform == 'cygwin':
        raise NotImplementedError('use Cygwin setup.exe to install CMake, or manual compile')
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
        raise NotImplementedError('unknown platform {}'.format(sys.platform))

    outfile = odir / ofn

    return outfile, url, stem


def latest_cmake_version() -> str:
    """
    get latest CMake version, or returns manually requested version
    """
    git = shutil.which('git')
    if not git:
        raise FileNotFoundError('Git was not found, is it installed?')

    ret = subprocess.check_output(['git', '--version'], universal_newlines=True).split()[2]
    git_version = pkg_resources.parse_version(ret[:6])
    if git_version < pkg_resources.parse_version('2.18'):
        raise RuntimeError('Git >= 2.18 required for auto latest version--'
                           'try specifying version manually like:\n python cmake_setup.py 3.14.0')

    cmd = ['git', 'ls-remote', '--tags', '--sort=v:refname', 'git://github.com/kitware/cmake.git']
    lastrev = subprocess.check_output(cmd, universal_newlines=True).strip().split('\n')[-1]
    pat = r'.*refs/tags/v(\w+\.\w+\.\w+.*)\^\{\}$'

    mat = re.match(pat, lastrev)
    if not mat:
        raise ValueError('Could not determine latest CMake version. Please report this bug.  \nInput: \n {}'.format(lastrev))

    cmake_version = mat.group(1)

    return cmake_version
