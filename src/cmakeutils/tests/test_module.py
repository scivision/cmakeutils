import pytest
import sys

import cmakeutils.cmake_setup as cm


@pytest.mark.skipif(sys.platform not in ("linux", "win32"), reason="only downloads for Windows and Linux")
def test_files(tmp_path):

    path, file = cm.cmake_files(cm.VERSION, tmp_path)

    if sys.platform == "linux":
        assert file.endswith(".tar.gz")
    elif sys.platform == "win32":
        assert file.endswith(".zip")
