import requests
from pathlib import Path
import hashlib


def url_retrieve(url: str, outfile: Path):
    print('downloading', url, '=>', outfile)
    R = requests.get(url, allow_redirects=True)
    if R.status_code != 200:
        raise ConnectionError('could not download {}   error {}'.format(url, R.status_code))

    outfile.write_bytes(R.content)


def file_checksum(fn: Path, hashfn: Path, mode: str) -> bool:
    h = hashlib.new(mode)
    with fn.open('rb') as f:
        data = f.read()
    h.update(data)
    digest = h.hexdigest()

    with hashfn.open('r') as f:
        for line in f:
            if line.startswith(digest):
                if line.split()[-1] == fn.name:
                    return True

    return False
