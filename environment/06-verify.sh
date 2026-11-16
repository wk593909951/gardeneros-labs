#!/usr/bin/env bash
set -euo pipefail
source /root/.cargo/env
cd /mnt
test "$(cat rust-toolchain)" = nightly-2026-05-08
rustup show active-toolchain | grep '^nightly-2026-05-08-'
rustup target list --installed | grep '^riscv64gc-unknown-none-elf$'
rustup component list --installed | grep '^llvm-tools'
rustup component list --installed | grep '^rust-src$'
rustc --version
cargo --version
cargo size --version
qemu-system-riscv64 --version | grep 'version 11.0.0'
qemu-riscv64 --version | grep 'version 11.0.0'
mkdir -p /tmp/gardeneros-env-check
cat > /tmp/gardeneros-env-check/smoke.rs <<'EOF'
#![no_std]
#![no_main]
use core::arch::asm;
use core::panic::PanicInfo;
#[panic_handler]
fn panic(_: &PanicInfo) -> ! { loop {} }
#[unsafe(no_mangle)]
pub extern "C" fn _start() -> ! {
    unsafe { asm!("li a0, 0", "li a7, 93", "ecall", options(noreturn)) }
}
EOF
rustc --edition=2024 --target riscv64gc-unknown-none-elf \
  -C panic=abort -C relocation-model=static -C link-arg=--entry=_start \
  /tmp/gardeneros-env-check/smoke.rs -o /tmp/gardeneros-env-check/smoke.elf
rust-readobj --file-headers /tmp/gardeneros-env-check/smoke.elf
timeout 10 qemu-riscv64 /tmp/gardeneros-env-check/smoke.elf
echo 'RISC-V cross-compilation and QEMU user execution: PASS'
set +e
timeout 3 qemu-system-riscv64 -machine virt -bios default -nographic -nic none -m 128M -smp 1 > /tmp/gardeneros-env-check/opensbi.log 2>&1
qemu_status=$?
set -e
cat /tmp/gardeneros-env-check/opensbi.log
test "$qemu_status" -eq 124
grep -q OpenSBI /tmp/gardeneros-env-check/opensbi.log
echo 'QEMU system RISC-V virt/OpenSBI startup: PASS'
printf '\nENVIRONMENT VERIFICATION PASSED\n'
