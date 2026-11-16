#!/usr/bin/env bash
set -euo pipefail
cat /etc/os-release
test -d /mnt/.git
dnf --disablerepo=debuginfo,source,update-source install -y curl vim gcc
printf '\nBasic tools ready\n'
curl --version | head -n 1
gcc --version | head -n 1
