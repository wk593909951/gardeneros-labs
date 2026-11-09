# 实验 0 环境配置说明

按课程指导依次准备 Docker、建立宿主机 Git 开发目录、创建 openEuler 容器、配置 Rust、源码安装 QEMU，最后验证并保存环境镜像。

开发代码在宿主机保存，并绑定到容器 `/mnt`。Rust 的用户配置和工具链位于容器 `/root/.cargo`、`/root/.rustup`；QEMU 安装在容器 `/usr/local`。这些容器文件由宿主机的 Docker 数据盘保存。

## 版本要求

- openEuler 容器环境。
- 默认 Rust 工具链为 nightly；项目通过 `rust-toolchain` 固定到 `nightly-2026-05-08`。
- `riscv64gc-unknown-none-elf` 目标、`cargo-binutils`、`llvm-tools-preview`、`rust-src`。
- QEMU `11.0.0`，编译目标为 `riscv64-softmmu,riscv64-linux-user`。

## 执行位置和顺序

`03-basic.sh`、`04-rust.sh`、`05-qemu.sh` 应在专用 openEuler 容器内以 root 身份依次执行。运行前，必须把本 Git 仓库根目录绑定到 `/mnt`。这些脚本会安装软件，请勿在其他项目容器中运行。

`06-verify.sh` 在相同环境中执行，检查版本与组件，并验证最小 RISC-V 程序的交叉编译、QEMU 用户态执行，以及 QEMU 系统模拟器的 OpenSBI 启动。它只验证开发环境，不代表后续操作系统实验已经完成。

`04-complete-pinned.sh` 是已有 Rust 安装的固定日期工具链补齐脚本。`prefetch-pinned-rust.py` 可选地从 Rust 官方地址预取该固定版本，逐项校验清单中的 SHA-256 后交给 rustup 使用，不会切换默认工具链。`record-environment.py` 用于读取当前版本、组件和必需软件包，生成环境记录。

## 与指导命令的适配

1. Windows 使用 PowerShell 创建目录、文件及绑定挂载；容器内仍使用 Bash、dnf 和 Linux 路径。
2. 指导的 Cargo 配置实际指向中科大 USTC。采用其当前支持的 `sparse+https://mirrors.ustc.edu.cn/crates.io-index/`，保留相同镜像站。
3. Rust 使用 minimal 配置，再安装全部必需目标与组件；不额外安装 stable 工具链。
4. 按指导先配置默认 nightly，再创建固定日期文件；随后为固定日期工具链补齐 RISC-V 目标与组件。
5. dnf 命令临时跳过源码和调试仓库索引，保留正常软件源和 GPG 校验；不修改仓库配置文件。
6. QEMU 构建使用 6 个并行任务，适配本实验容器的 CPU 和内存限制。
7. QEMU 源码仍来自指导指定的官方 HTTPS 地址；下载辅助脚本使用 6 个范围请求缩短慢速连接的等待，检查响应范围、版本文件大小和 ETag，并记录完整文件 SHA-256。执行 `05-qemu.sh` 前需将 `fetch-qemu.py` 复制到容器 `/tmp/fetch-qemu.py`。
8. 容器 `/usr/local/bin` 提供指向已安装 Rust 命令的入口链接，供非交互式构建使用；Bash 终端仍通过 `/root/.cargo/env` 加载完整工具路径。

本机的 Git 提交和推送在 Windows 宿主机执行；容器用于编辑、编译和运行实验代码。容器未挂载宿主机 SSH 凭据。

## 环境保存与代码保存

Docker 镜像保存容器内安装的工具及配置，绑定挂载目录 `/mnt` 中的代码由本 Git 仓库独立管理。`docker commit` 不会把绑定挂载的代码打包进镜像。

参考：[USTC Cargo 镜像说明](https://mirrors.ustc.edu.cn/help/crates.io-index.html)、[rustup 工具链文件](https://rust-lang.github.io/rustup/overrides.html)、[Docker commit](https://docs.docker.com/reference/cli/docker/container/commit/)。
