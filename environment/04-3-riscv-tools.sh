#!/usr/bin/env bash
set -euxo pipefail
source /root/.cargo/env
cd /root
rustup target add --toolchain nightly riscv64gc-unknown-none-elf
cargo +nightly install cargo-binutils --version 0.4.0 --locked
rustup component add --toolchain nightly llvm-tools-preview rust-src
rustup target list --toolchain nightly --installed
rustup component list --toolchain nightly --installed
cargo +nightly size --version
