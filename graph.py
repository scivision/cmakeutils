"""
CMake dependency graph.
Requires graphviz installed.

Requires user to first invoke "cmake -B build --graphviz=gfx/block.dot"
"""

import shutil
import subprocess
import argparse
from pathlib import Path
import webbrowser


p = argparse.ArgumentParser(description="convert .dot graph to SVG or PNG")
p.add_argument(
    "path",
    help="Project gfx/ directory from cmake -B build --graphviz=gfx/block.dot",
)
p.add_argument(
    "format", help="output format", choices=["svg", "png"],
    default="svg", nargs="?"
)
P = p.parse_args()

fmt = P.format

if not (dot := shutil.which("dot")):
    raise FileNotFoundError("GraphViz Dot program not available.")

path = Path(P.path).expanduser().resolve(strict=True)
if not path.is_dir():
    raise NotADirectoryError(path)

try:
    name_file = next(path.glob("*.dot"))
except StopIteration:
    raise FileNotFoundError(f"No .dot files in {path}")

name_pat = name_file.name

# %% write HTML file to display all graphs
html = f"""
<!DOCTYPE html>
<html>
<head>
<title>{path} CMake Graphs</title>
<style>
img {{
    display: block;
    margin-left: auto;
    margin-right: auto;
    }}
</style>
</head>
<body>
<figure>
<img src="{name_file.name}.{fmt}" alt="graph legend and top-level diagram">
<figcaption>Graph legend and top-level project diagram</figcaption>
</figure>
"""


for file in path.glob(name_pat + "*"):
    if file.suffix in (".png", ".svg"):
        continue
    out_name = file.name
    if out_name != name_pat:
        # remove vestigial name from front
        out_name = out_name[len(name_pat) + 1:]
    out_file = f"{out_name}.{fmt}"

    cmd = ["dot", f"-T{fmt}", f"-o{out_file}", str(file.name)]
    print(" ".join(cmd))
    subprocess.run(cmd, cwd=path)

    html += f"""
<figure>
<img src="{out_file}" alt="{out_name}">
<figcaption>{out_name}</figcaption>
</figure>
"""

html += """
</body>
</html>
"""

html_path = path / "index.html"
html_path.write_text(html)

webbrowser.open(html_path.as_uri())
