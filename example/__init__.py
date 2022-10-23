from __future__ import annotations
import subprocess
import shutil
import sys

__all__ = ["cmake_exe"]


def cmake_exe() -> str:

    cmake = shutil.which("cmake")
    if not cmake:
        # try to help if Homebrew or Ports is not on PATH
        if sys.platform == "darwin":
            paths = ["/opt/homebrew/bin", "/usr/local/bin", "/opt/local/bin"]
            for path in paths:
                cmake = shutil.which("cmake", path=path)
                if cmake:
                    break

    if not cmake:
        raise FileNotFoundError("CMake not found.  Try:\n    pip install cmake")

    cmake_version = (
        subprocess.check_output([cmake, "--version"], text=True).split("\n")[0].split(" ")[2]
    )

    print("Using CMake", cmake_version)

    return cmake
