import sys

sys.path.insert(0, "src")

from app import describe_build


def test_describe_build_shape():
    info = describe_build()
    assert info["app"] == "python-app"
    assert "pythonVersion" in info
