#!/usr/bin/env bash
set -euxo pipefail
source /root/.cargo/env
cd /mnt
test "$(cat rust-toolchain)" = nightly-2026-05-08
rustup toolchain install nightly-2026-05-08 --profile minimal
rustup target add --toolchain nightly-2026-05-08 riscv64gc-unknown-none-elf
rustup component add --toolchain nightly-2026-05-08 llvm-tools-preview rust-src
for tool in rustup rustc cargo; do
  test -e "/usr/local/bin/$tool" || ln -s "/root/.cargo/bin/$tool" "/usr/local/bin/$tool"
done
rustup show active-toolchain
rustc --version
cargo --version
rustup target list --installed
rustup component list --installed
cargo size --version
