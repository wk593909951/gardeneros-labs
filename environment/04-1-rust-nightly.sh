#!/usr/bin/env bash
set -euxo pipefail
cd /root
if ! grep -q '^# GardenerOS Rust mirror' .bashrc; then
cat >> .bashrc <<'EOF'

# GardenerOS Rust mirror
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
EOF
fi
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
curl --fail --location --retry 3 https://sh.rustup.rs -o rustup-install.sh
sh rustup-install.sh -y --default-toolchain none --profile minimal
source /root/.cargo/env
rustup toolchain install nightly --profile minimal
rustup default nightly
rustup toolchain list
rustc --version
