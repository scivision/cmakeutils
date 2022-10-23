from __future__ import annotations
import typing as T
import tempfile
import importlib.resources
from pathlib import Path
import subprocess

from . import cmake_exe


def find_library(lib_name: str, lib_path: list[str], env: T.Mapping[str, str]) -> bool:
    """
    check if library exists with CMake

    lib_name must have the appropriate upper and lower case letter as would be used
    directly in CMake.
    """

    cmake = cmake_exe()

    with importlib.resources.path(__name__, "FindLAPACK.cmake") as f:
        mod_path = Path(f).parent

    cmake_template = """
cmake_minimum_required(VERSION 3.15)
project(dummy LANGUAGES C Fortran)

"""

    if mod_path.is_dir():
        cmake_template += f'list(APPEND CMAKE_MODULE_PATH "{mod_path.as_posix()}")\n'

    cmake_template += f"find_package({lib_name} REQUIRED)\n"

    build_dir = f"find-{lib_name.split(' ', 1)[0]}"

    # not context_manager to avoid Windows PermissionError on context exit for Git subdirs
    d = tempfile.TemporaryDirectory()
    r = Path(d.name)
    (r / "CMakeLists.txt").write_text(cmake_template)

    cmd = [cmake, "-S", str(r), "-B", str(r / build_dir)] + lib_path
    # use cwd= to avoid spilling temporary files into current directory if ancient CMake used
    # also avoids bugs if there is a CMakeLists.txt in the current directory
    ret = subprocess.run(cmd, env=env, cwd=r)

    try:
        d.cleanup()
    except PermissionError:
        pass

    return ret.returncode == 0
