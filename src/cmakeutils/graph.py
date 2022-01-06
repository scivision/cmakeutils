"""
CMake dependency graph.
Requires graphviz installed.

Requires user to first invoke "cmake -B build --graphviz=gfx/block.dot"
"""

import shutil
import subprocess
import argparse
from pathlib import Path


def main():
    p = argparse.ArgumentParser(description="convert .dot graph to SVG or PNG")
    p.add_argument(
        "path", help="Path to CMake gfx/ directory from cmake -B build --graphviz=gfx/block.dot"
    )
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
        name_file = next(path.glob("*.dot"))
    except StopIteration:
        raise FileNotFoundError(f"No .dot files in {path}")

    name_pat = name_file.name

    for file in path.glob(name_pat + "*"):
        if file.suffix in (".png", ".svg"):
            continue
        out_name = file.name
        if out_name != name_pat:
            # remove vestigial name from front
            out_name = out_name[len(name_pat) + 1 :]
        cmd = ["dot", f"-T{fmt}", "-o", f"{out_name}.{fmt}", str(file.name)]
        print(" ".join(cmd))
        subprocess.run(cmd, cwd=str(path))


if __name__ == "__main__":
    main()
