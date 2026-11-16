# GardenerOS 实验0 环境配置

姓名：王凯；学号：24301043。

本分支 `lab0-environment` 是实验0的提交分支。按照课程指导顺序配置 Docker/openEuler、宿主机 Git 目录、独立容器、Rust/RISC-V 工具链和源码构建的 QEMU 11.0.0。已有真实实验历史按指导的五个主要阶段整理，提交说明包含学号和姓名。

宿主机目录：`D:\OSexperiment\experiment0\Submission\GardenerOS`；容器目录：`/mnt`。

专用容器：`gardeneros-lab0-submit-20261116`；网络：`gardeneros-lab0-submit-net`；环境镜像：`gardeneros-openeuler:lab0-24301043`。

项目固定 Rust `nightly-2026-05-08`，目标为 `riscv64gc-unknown-none-elf`；QEMU 构建目标为 `riscv64-softmmu,riscv64-linux-user`。

进入环境：`docker start gardeneros-lab0-submit-20261116`，再执行 `docker exec -it -w /mnt gardeneros-lab0-submit-20261116 bash`。

`target/` 忽略所有层级的 Cargo 编译产物。实验0最终提交材料为实验报告，后续实验代码继续由 Git 管理。

`environment/` 保留安装脚本及必要下载适配。交叉编译、断网恢复和材料核查记录在宿主机本地工作记录中保存。Cargo 使用指导具体配置中的 USTC 源，并采用 sparse 索引访问。
