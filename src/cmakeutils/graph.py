"""
CMake dependency graph.
Requires graphviz installed

Requires user to first invoke "cmake -B build --graphviz=gfx/block.dot"
"""

import shutil
import subprocess
import argparse
from pathlib import Path


def main():
    p = argparse.ArgumentParser(description="convert .dot graph to SVG or PNG")
    p.add_argument("path", help="Path to CMake gfx/ directory from cmake -B build --graphviz=gfx/block.dot")
    p.add_argument("format", help="output format", choices=["svg", "png"], default="svg", nargs="?")
    P = p.parse_args()

    fmt = P.format

    dot = shutil.which("dot")
    if not dot:
        raise FileNotFoundError("GraphViz Dot program not available.")

    path = Path(P.path).expanduser()
    if not path.is_dir():
        raise NotADirectoryError(path)

    try:
        name_pat = next(path.glob("*.dot"))
    except StopIteration:
        raise FileNotFoundError(f"No .dot files in {path}")

    for file in path.glob(name_pat.name + "*"):
        if file.suffix in (".png", ".svg"):
            continue
        cmd = ["dot", f"-T{fmt}", "-o", f"{file.name}.{fmt}", str(file.name)]
        print(" ".join(cmd))
        subprocess.run(cmd, cwd=str(path))


if __name__ == "__main__":
    main()
