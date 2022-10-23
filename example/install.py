"""
installs Gemini3D prerequisite libraries
"""

from __future__ import annotations
import tempfile
import subprocess
import json
from pathlib import Path
import argparse
import importlib.resources

from .web import git_download
from .cmake import cmake_exe

P = argparse.ArgumentParser(description="Install prereqs")
P.add_argument("-sudo", action="store_true", help="run as root")
a = P.parse_args()

src_dir = Path(tempfile.gettempdir()) / "my-libs"

if not (src_dir / "CMakeLists.txt").is_file():
    jmeta = json.loads(importlib.resources.read_text(__name__, "libraries.json"))
    git_download(src_dir, repo=jmeta["external"]["git"], tag=jmeta["external"]["tag"])

script = src_dir / "scripts/requirements.cmake"
if not script.is_file():
    raise FileNotFoundError(script)

cmake_cmd = [cmake_exe(), "-P", str(script)]

print(" ".join(cmake_cmd))
pkg_cmd = subprocess.check_output(cmake_cmd, text=True).strip().split(" ")

if a.sudo:
    pkg_cmd.insert(0, "sudo")

print(" ".join(pkg_cmd))
ret = subprocess.run(pkg_cmd)

if ret.returncode != 0:
    if not a.sudo:
        raise SystemExit(
            "if failure is due to permissions, "
            "add -sudo option like \n python -m gemini3d.install -sudo"
        )
    else:
        raise SystemExit(f"failed to install packages with {pkg_cmd}")
