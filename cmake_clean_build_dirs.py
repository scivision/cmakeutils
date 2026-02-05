# /// script
# dependencies = [
# "send2trash",
# ]
# ///

"""
Clean all CMake build directories one level under a given root directory.
Puts the contents into Recyle Bin / Trash instead of deleting permanently in case of mistake.
"""

import argparse
from pathlib import Path

import send2trash


def recycle_build_dirs(root_dir: Path, recursive: bool, dryrun: bool) -> None:
    """Find all CMake build directories under the given root directory."""

    if recursive:
        search_dirs = (p.parent for p in root_dir.rglob("CMakeCache.txt"))
    else:
        search_dirs = (x for x in root_dir.iterdir() if x.is_dir())

    for path in search_dirs:
        # is this a CMake project directory?
        if (path / "CMakeLists.txt").is_file():
            # heuristic to determine if this is an out-of-source CMake build directory
            for b in path.iterdir():
                if (
                    b.is_dir()
                    and (b / "CMakeCache.txt").is_file()
                    and not (b / "CMakeLists.txt").is_file()
                ):
                    print(b)
                    if not dryrun:
                        send2trash.send2trash(b)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Recycle CMake build directories.")
    parser.add_argument(
        "root_dir",
        type=Path,
        help="Root directory to search for CMake build directories.",
    )
    parser.add_argument(
        "-n",
        "--dryrun",
        action="store_true",
        help="Show what would be deleted without actually deleting.",
    )
    parser.add_argument(
        "-r", "--recursive", action="store_true", help="Recursively search directories."
    )
    args = parser.parse_args()

    root_dir = Path(args.root_dir).expanduser().resolve(strict=True)

    recycle_build_dirs(root_dir, args.recursive, args.dryrun)
