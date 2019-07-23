import urllib.request
from pathlib import Path
import hashlib


def url_retrieve(url: str, outfile: Path):
    outfile = Path(outfile).expanduser().resolve()
    if outfile.is_dir():
        raise ValueError("Please specify full filepath, including filename")
    outfile.parent.mkdir(parents=True, exist_ok=True)

    urllib.request.urlretrieve(url, str(outfile))


def file_checksum(fn: Path, hashfn: Path, mode: str) -> bool:
    h = hashlib.new(mode)
    h.update(fn.read_bytes())
    digest = h.hexdigest()

    with hashfn.open("r") as f:
        for line in f:
            if line.startswith(digest):
                if line.split()[-1] == fn.name:
                    return True

    return False
