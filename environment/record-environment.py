import datetime
import hashlib
import json
import os
import pathlib
import subprocess

os.environ['PATH'] = '/root/.cargo/bin:' + os.environ['PATH']

def command(*args):
    return subprocess.check_output(args, cwd='/mnt', text=True).strip()

release = {}
for line in pathlib.Path('/etc/os-release').read_text().splitlines():
    if '=' in line and not line.startswith('#'):
        key, value = line.split('=', 1)
        release[key] = value.strip('"')
archive = pathlib.Path('/root/qemu-11.0.0.tar.xz')
with archive.open('rb') as source:
    digest = hashlib.file_digest(source, 'sha256').hexdigest()
packages = '''vim-enhanced autoconf automake gcc gcc-c++ kernel-devel curl libmpc-devel mpfr-devel
gmp-devel glib2 glib2-devel make cmake gawk bison flex texinfo gperf libtool
patchutils bc python3 ninja-build wget xz python3-tomli python3-sphinx'''.split()
result = {
    'schema_version': 1,
    'verified_at': datetime.datetime.now(datetime.timezone(datetime.timedelta(hours=8))).isoformat(timespec='seconds'),
    'system': release['PRETTY_NAME'],
    'architecture': command('uname', '-m'),
    'vim': command('vim', '--version').splitlines()[0],
    'gcc': command('gcc', '--version').splitlines()[0],
    'rust_toolchain_file': pathlib.Path('/mnt/rust-toolchain').read_text().strip(),
    'active_toolchain': command('rustup', 'show', 'active-toolchain'),
    'installed_toolchains': command('rustup', 'toolchain', 'list').splitlines(),
    'rustc': command('rustc', '--version'),
    'cargo': command('cargo', '--version'),
    'cargo_binutils': command('cargo', 'size', '--version'),
    'installed_rust_targets': command('rustup', 'target', 'list', '--installed').splitlines(),
    'installed_rust_components': command('rustup', 'component', 'list', '--installed').splitlines(),
    'qemu_system_riscv64': command('qemu-system-riscv64', '--version').splitlines()[0],
    'qemu_riscv64': command('qemu-riscv64', '--version').splitlines()[0],
    'qemu_configure_targets': ['riscv64-softmmu', 'riscv64-linux-user'],
    'qemu_source': {'url': 'https://download.qemu.org/qemu-11.0.0.tar.xz', 'bytes': archive.stat().st_size, 'sha256': digest},
    'required_packages': command('rpm', '-q', *packages).splitlines(),
}
assert result['rust_toolchain_file'] == 'nightly-2026-05-08'
assert result['active_toolchain'].startswith('nightly-2026-05-08-')
assert 'version 11.0.0' in result['qemu_system_riscv64']
assert 'version 11.0.0' in result['qemu_riscv64']
print(json.dumps(result, ensure_ascii=False, indent=2))
