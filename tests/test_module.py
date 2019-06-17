#!/usr/bin/env python
import pytest
import pkg_resources
import sys

import cmakeutils as cm

VERSION = '3.14'  # just an existing version of CMake


def test_version():

    vers = cm.latest_cmake_version()
    assert isinstance(vers, str)

    pvers = pkg_resources.parse_version(vers)
    assert pvers >= pkg_resources.parse_version(VERSION)


def test_files(tmp_path):

    path, file, stem = cm.cmake_files(VERSION, tmp_path)

    if sys.platform == 'linux':
        assert file.endswith('.tar.gz')
    elif sys.platform == 'win32':
        assert file.endswith('.msi')
    else:
        pytest.skip('we did not have a test for {}'.format(sys.platform))


if __name__ == '__main__':
    pytest.main([__file__])
