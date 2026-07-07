#!/usr/bin/env python3

from pathlib import Path
import os

spec = Path("windows.txt").read_text().strip()  # Remove trailing newline in input files
if not os.name == "nt":
    spec += Path("unix.txt").read_text().strip()

test = Path() / spec

print(f"Testing path with special characters: {test}")

test.touch()

if not test.exists():
    raise OSError(f"Failed to create file with special characters: {test}")
