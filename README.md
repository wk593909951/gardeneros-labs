# GardenerOS 操作系统开发实验

本仓库用于管理操作系统开发课程实验的代码、环境脚本和说明，公开供课程检查。当前完成实验 0 的开发环境配置，后续实验代码在此继续管理。

## 已验证环境（2026-11-09）

| 项目 | 配置 |
| --- | --- |
| 容器系统 | openEuler 24.03 LTS-SP4，Linux x86_64 |
| Rust 项目工具链 | `nightly-2026-05-08`，rustc 1.97.0-nightly |
| 默认 Rust 工具链 | nightly；进入本仓库后由 `rust-toolchain` 固定日期覆盖 |
| 裸机编译目标 | `riscv64gc-unknown-none-elf` |
| Rust 工具 | cargo-binutils 0.4.0、llvm-tools-preview、rust-src |
| QEMU | 11.0.0，riscv64-softmmu / riscv64-linux-user |

## 本机使用

Windows 代码目录：`D:\OSexperiment\experiment0\GardenerOS`；容器内对应 `/mnt`。

先启动 Docker Desktop 的 Linux 引擎，再在 PowerShell 执行：

```powershell
cd D:\OSexperiment\experiment0\GardenerOS
.\Enter-Lab.ps1
```

脚本只启动专用容器 `gardeneros-exp0-20261109`，并进入 `/mnt` 的 Bash。也可以直接执行：

```powershell
docker start gardeneros-exp0-20261109
docker exec -it -w /mnt gardeneros-exp0-20261109 bash
```

在容器中编辑、编译和运行实验代码；代码文件保存在 `/mnt` 下。在 Windows 宿主机提交与推送 Git。输入 `exit` 可退出当前 Bash 终端。

## 隔离与保存

实验容器使用专属网络 `gardeneros-exp0-net`、6 CPU / 8 GiB 上限，只挂载本仓库目录，不映射宿主机端口。工具链、源码和编译数据存放于 D 盘的 Docker 数据目录。

本机配置后的环境镜像为 `gardeneros-openeuler:exp0-20261109`。镜像保存在本机 Docker 中；GitHub 仓库保存代码和配置脚本。绑定挂载的 `/mnt` 代码不包含在 `docker commit` 镜像中。

## 验证与复现

已验证指定日期工具链及组件、最小 RISC-V 裸机目标程序的交叉编译和 QEMU 用户态执行、QEMU 系统模拟器的 OpenSBI 启动。容器重启后复验通过；配置镜像已在无网络、只读代码挂载的临时容器中验证。

详见 [环境配置说明](environment/README.md)、[环境版本记录](environment/environment.json) 和 `environment/` 中的安装、验证脚本。原始安装日志与本机资源清单保存在本地，不提交到公开仓库。
