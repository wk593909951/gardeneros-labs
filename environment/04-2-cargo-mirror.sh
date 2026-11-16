#!/usr/bin/env bash
set -euxo pipefail
mkdir -p /root/.cargo
cat > /root/.cargo/config.toml <<'EOF'
[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"

[registries.ustc]
index = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
EOF
cat /root/.cargo/config.toml
