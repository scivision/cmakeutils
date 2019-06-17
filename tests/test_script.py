#!/usr/bin/env python
import pytest
import subprocess

import cmakeutils as cm

VERSION = '3.14'  # just an existing version of CMake


@pytest.mark.skipif(not cm.check_git_version('2.18'), reason='Git < 2.18')
def test_version():

    subprocess.check_call(['cmake_setup', '-n'])


if __name__ == '__main__':
    pytest.main([__file__])
