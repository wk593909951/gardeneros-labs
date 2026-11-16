#!/usr/bin/env bash
set -euo pipefail
source /root/.cargo/env
cd /root
dnf --disablerepo=debuginfo,source,update-source --setopt=max_parallel_downloads=6 groupinstall -y "Development Tools"
dnf --disablerepo=debuginfo,source,update-source --setopt=max_parallel_downloads=6 install -y autoconf automake gcc gcc-c++ kernel-devel curl libmpc-devel mpfr-devel gmp-devel \
  glib2 glib2-devel make cmake gawk bison flex texinfo gperf libtool patchutils bc \
  python3 ninja-build wget xz python3-tomli python3-sphinx
python3 /tmp/fetch-qemu.py
sha256sum qemu-11.0.0.tar.xz
tar xJf qemu-11.0.0.tar.xz
cd /root/qemu-11.0.0
./configure --target-list=riscv64-softmmu,riscv64-linux-user
make -j6 install
qemu-system-riscv64 --version
qemu-riscv64 --version
