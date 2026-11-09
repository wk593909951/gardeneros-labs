#!/usr/bin/env bash
set -euo pipefail
source /root/.cargo/env
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
cd /mnt
test "$(cat rust-toolchain)" = nightly-2026-05-08
rustup toolchain install nightly-2026-05-08 --profile minimal
rustup target add --toolchain nightly-2026-05-08 riscv64gc-unknown-none-elf
rustup component add --toolchain nightly-2026-05-08 llvm-tools-preview rust-src
rustup show
rustc --version
cargo --version
rustup target list --installed
rustup component list --installed
cargo size --version
