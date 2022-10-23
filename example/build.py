from __future__ import annotations
import typing as T
from pathlib import Path
import subprocess
import shutil

from . import cmake_exe


def build(
    source_dir: Path,
    build_dir: Path,
    *,
    config_args: list[str] = None,
    build_args: list[str] = None,
    wipe: bool = False,
    env: T.Mapping[str, str] = None,
    run_test: bool = False,
    dryrun: bool = False,
    install: bool = True,
):
    """build and install with CMake"""
    cmake = cmake_exe()

    cache_file = build_dir / "CMakeCache.txt"
    if wipe:
        if cache_file.is_file():
            cache_file.unlink()
    # %% Configure
    cmd = [cmake, f"-B{build_dir}", f"-S{source_dir}"]
    if config_args:
        cmd += config_args
    subprocess.check_call(cmd, env=env)
    # %% Build
    cmd = [cmake, "--build", str(build_dir), "--parallel"]
    if build_args:
        cmd += build_args
    if dryrun:
        print("DRYRUN: would have run\n", " ".join(cmd))
        return None

    subprocess.check_call(cmd)

    if run_test:
        subprocess.check_call(["ctest", "--output-on-failure"], cwd=build_dir)

    if install:
        subprocess.check_call([cmake, "--install", str(build_dir)])


def build_targets(root: Path, targets: list[str], name: str, cmake_args: list[str] = None):
    """
    build targets from program
    """

    if isinstance(targets, str):
        targets = [targets]

    if isinstance(cmake_args, str):
        cmake_args = [cmake_args]
    elif cmake_args is None:
        cmake_args = []

    src_dir = Path(root).expanduser()

    build_dir = src_dir / "build"

    build(
        src_dir,
        build_dir,
        run_test=False,
        install=False,
        config_args=["-DBUILD_TESTING:BOOL=false"] + cmake_args,
        build_args=["--target", *targets],
    )

    for t in targets:
        for n in {"build", "build/Release", "build/Debug"}:
            exe = shutil.which(t, path=str(src_dir / n))
            if exe:
                break
        if not exe:
            raise RuntimeError(f"{t} not found in {build_dir}")
