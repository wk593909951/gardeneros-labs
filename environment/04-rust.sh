#!/usr/bin/env bash
set -euo pipefail
cd /root
if ! grep -q '^# GardenerOS Rust mirror' /root/.bashrc; then
cat >> /root/.bashrc <<'EOF'

# GardenerOS Rust mirror
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
EOF
fi
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
curl --fail --location --retry 3 https://sh.rustup.rs -o /root/rustup-install.sh
sh /root/rustup-install.sh -y --default-toolchain none --profile minimal
source /root/.cargo/env
rustup install nightly --profile minimal
rustup default nightly
mkdir -p /root/.cargo
cat > /root/.cargo/config.toml <<'EOF'
[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"

[registries.ustc]
index = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
EOF
rustup target add riscv64gc-unknown-none-elf
CARGO_BUILD_JOBS=6 cargo install cargo-binutils --locked
rustup component add llvm-tools-preview
rustup component add rust-src
printf 'nightly-2026-05-08\n' > /mnt/rust-toolchain
cd /mnt
rustup toolchain install nightly-2026-05-08 --profile minimal
rustup target add --toolchain nightly-2026-05-08 riscv64gc-unknown-none-elf
rustup component add --toolchain nightly-2026-05-08 llvm-tools-preview rust-src
rustup show
rustc --version
cargo --version
rustup target list --installed
rustup component list --installed
cargo size --version
for tool in rustup rustc cargo; do
  if [ ! -e "/usr/local/bin/$tool" ]; then
    ln -s "/root/.cargo/bin/$tool" "/usr/local/bin/$tool"
  fi
done
