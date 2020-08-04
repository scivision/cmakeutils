import subprocess


def test_version():

    subprocess.check_call(["cmake_setup", "-n"])
