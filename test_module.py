#!/usr/bin/env python
import pytest
import pkg_resources
import sys

import cmake_setup as cm

VERSION = "3.0"  # an old version of CMake


@pytest.mark.skipif(not cm.check_git_version("2.18"), reason="Git < 2.18")
def test_available_version():

    vers = cm.latest_cmake_version()
    assert isinstance(vers, str)

    pvers = pkg_resources.parse_version(vers)
    assert pvers >= pkg_resources.parse_version(VERSION)


def test_existing_version():

    assert cm.check_cmake_version(VERSION)


def test_files(tmp_path):

    path, file, stem = cm.cmake_files(VERSION, tmp_path)

    if sys.platform == "linux":
        assert file.endswith(".tar.gz")
    elif sys.platform == "win32":
        assert file.endswith(".msi")
    else:
        pytest.skip(f"we do not have a test for {sys.platform}")


if __name__ == "__main__":
    pytest.main([__file__])
