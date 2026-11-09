"""Prefetch only the course-pinned toolchain into rustup's verified cache."""
import concurrent.futures
import hashlib
import pathlib
import re
import time
import tomllib
import urllib.request

BASE = 'https://static.rust-lang.org'
MANIFEST_URL = BASE + '/dist/2026-05-08/channel-rust-nightly.toml'
CACHE = pathlib.Path('/root/.rustup/downloads')
CACHE.mkdir(parents=True, exist_ok=True)
with urllib.request.urlopen(MANIFEST_URL, timeout=40) as response:
    manifest = tomllib.loads(response.read().decode())
host = 'x86_64-unknown-linux-gnu'
packages = [('cargo', host), ('rustc', host), ('rust-std', host),
            ('rust-std', 'riscv64gc-unknown-none-elf'),
            ('llvm-tools-preview', host), ('rust-src', '*')]
archives = []
jobs = []
for package, target in packages:
    item = manifest['pkg'][package]['target'][target]
    assert item['available']
    digest = item['xz_hash']
    output = CACHE / digest
    if output.exists():
        with output.open('rb') as source:
            if hashlib.file_digest(source, 'sha256').hexdigest() == digest:
                print(f'Already verified: {package}/{target}', flush=True)
                continue
    upstream = item['xz_url']
    assert upstream.startswith('https://static.rust-lang.org/')
    url = upstream.replace('https://static.rust-lang.org', BASE, 1)
    with urllib.request.urlopen(urllib.request.Request(url, headers={'Range': 'bytes=0-0'}), timeout=40) as response:
        assert response.status == 206, 'Range transfer not supported'
        match = re.fullmatch(r'bytes 0-0/(\d+)', response.headers.get('Content-Range', ''))
        assert match
        size = int(match[1])
        etag = response.headers.get('ETag')
        response.read()
    temporary = CACHE / (digest + '.prefetch')
    with temporary.open('wb') as destination:
        destination.truncate(size)
    archives.append((package, target, digest, output, temporary))
    chunk_size = 16 * 1024 * 1024
    for start in range(0, size, chunk_size):
        jobs.append((url, temporary, start, min(size - 1, start + chunk_size - 1), size, etag))
    print(f'Prefetching pinned {package}/{target}: {size} bytes', flush=True)

def fetch(job):
    url, output, start, end, total, etag = job
    headers = {'Range': f'bytes={start}-{end}'}
    if etag and not etag.startswith('W/'):
        headers['If-Match'] = etag
    for attempt in range(3):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=headers), timeout=45) as response:
                assert response.status == 206
                assert response.headers.get('Content-Range') == f'bytes {start}-{end}/{total}'
                read = 0
                with output.open('r+b') as destination:
                    destination.seek(start)
                    while block := response.read(1024 * 1024):
                        read += len(block)
                        assert read <= end - start + 1
                        destination.write(block)
                assert read == end - start + 1
            return
        except Exception:
            if attempt == 2:
                raise
            time.sleep(2)

with concurrent.futures.ThreadPoolExecutor(max_workers=3) as executor:
    list(executor.map(fetch, jobs))
for package, target, digest, output, temporary in archives:
    with temporary.open('rb') as source:
        assert hashlib.file_digest(source, 'sha256').hexdigest() == digest, 'Rust component SHA256 mismatch'
    temporary.replace(output)
    print(f'Pinned component SHA256 verified: {package}/{target}', flush=True)
