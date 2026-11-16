# GardenerOS 实验1 独立的可执行程序

24301043 王凯

实验代码位于 `os`，固定使用 `nightly-2026-05-08` 和 `riscv64gc-unknown-none-elf`。

在配置好工具链和 QEMU 的容器内运行：

```bash
cd /mnt/os
cargo build
qemu-riscv64 target/riscv64gc-unknown-none-elf/debug/os
```

输出为 `Hello, world!` 和学号，退出状态为0。清理编译产物使用 `cargo clean`。
