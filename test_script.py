#!/usr/bin/env python
import pytest
import subprocess
import sys

import cmake_setup as cm

VERSION = "3.14"  # just an existing version of CMake


@pytest.mark.skipif(not cm.check_git_version("2.18"), reason="Git < 2.18")
def test_version():

    subprocess.check_call([sys.executable, "cmake_setup.py", "-n"])


if __name__ == "__main__":
    pytest.main([__file__])
