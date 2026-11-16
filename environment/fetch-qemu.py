"""Download the official immutable QEMU archive with six verified HTTP ranges."""
import concurrent.futures
import hashlib
import pathlib
import shutil
import time
import urllib.request

URL = 'https://download.qemu.org/qemu-11.0.0.tar.xz'
DEST = pathlib.Path('/root/qemu-11.0.0.tar.xz')
EXPECTED_SIZE = 141387580
PARTS = 6

with urllib.request.urlopen(urllib.request.Request(URL, headers={'Range': 'bytes=0-0'}), timeout=30) as response:
    assert response.status == 206
    assert response.headers.get('Content-Range') == f'bytes 0-0/{EXPECTED_SIZE}'
    etag = response.headers.get('ETag')
    assert response.read() == b'\xfd', 'Expected the first byte of an XZ archive'

def download_part(index):
    start = EXPECTED_SIZE * index // PARTS
    end = EXPECTED_SIZE * (index + 1) // PARTS - 1
    part = DEST.with_suffix(f'.part{index}')
    headers = {'Range': f'bytes={start}-{end}'}
    if etag and not etag.startswith('W/'):
        headers['If-Match'] = etag
    for attempt in range(3):
        try:
            request = urllib.request.Request(URL, headers=headers)
            with urllib.request.urlopen(request, timeout=40) as response, part.open('wb') as output:
                assert response.status == 206
                assert response.headers.get('Content-Range') == f'bytes {start}-{end}/{EXPECTED_SIZE}'
                shutil.copyfileobj(response, output, length=1024 * 1024)
            assert part.stat().st_size == end - start + 1
            print(f'Official QEMU source part {index + 1}/{PARTS} downloaded', flush=True)
            return part
        except Exception:
            if attempt == 2:
                raise
            time.sleep(2)

with concurrent.futures.ThreadPoolExecutor(max_workers=PARTS) as executor:
    paths = list(executor.map(download_part, range(PARTS)))
temporary = DEST.with_suffix('.download')
with temporary.open('wb') as output:
    for part in paths:
        with part.open('rb') as source:
            shutil.copyfileobj(source, output, length=1024 * 1024)
assert temporary.stat().st_size == EXPECTED_SIZE
temporary.replace(DEST)
with DEST.open('rb') as source:
    hasher = hashlib.sha256()
    while block := source.read(1024 * 1024):
        hasher.update(block)
    digest = hasher.hexdigest()
DEST.with_suffix(DEST.suffix + '.sha256').write_text(f'{digest}  {DEST.name}\n')
print(f'QEMU source SHA256: {digest}', flush=True)
for part in paths:
    part.unlink()
