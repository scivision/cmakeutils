import shutil
import pkg_resources
import subprocess
import re


def check_git_version(min_version: str) -> bool:
    """
    checks that Git of a minimum required version is available
    """
    git = shutil.which('git')
    if not git:
        return False

    ret = subprocess.check_output([git, '--version'], universal_newlines=True).split()[2]
    git_version = pkg_resources.parse_version(ret[:6])
    return git_version >= pkg_resources.parse_version(min_version)


def latest_cmake_version() -> str:
    """
    get latest CMake version
    """

    if not check_git_version('2.18'):
        raise RuntimeError('Git >= 2.18 required for auto latest version--'
                           'try specifying version manually like:\n python cmake_setup.py 3.14.0')

    cmd = ['git', 'ls-remote', '--tags', '--sort=v:refname', 'git://github.com/kitware/cmake.git']
    lastrev = subprocess.check_output(cmd, universal_newlines=True).strip().split('\n')[-1]
    pat = r'.*refs/tags/v(\w+\.\w+\.\w+.*)\^\{\}$'

    mat = re.match(pat, lastrev)
    if not mat:
        raise ValueError('Could not determine latest CMake version. Please report this bug.  \nInput: \n {}'.format(lastrev))

    latest_version = mat.group(1)

    return latest_version
