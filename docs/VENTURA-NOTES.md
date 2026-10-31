# Ventura 兼容处理与已知限制

## CoreGraphics / Finder 非法指令

实机 Ventura 13.7.8 (22H730) 的 25 份 Finder 报告均在 CoreGraphics 的 `resample_horizontal_f16c<half, half, 4, false>` 路径触发 `EXC_BAD_INSTRUCTION / SIGILL`。这里保留故障签名，不公开原始日志、进程环境或设备身份。

Ivy Bridge 支持 F16C，但没有 AVX2；相关系统路径错误使用了 AVX2 指令。此配置用 RestrictEvents 隐藏 F16C 特性报告，避开该路径。RestrictEvents 配置范围为 Darwin `22.4.0–22.99.99`，其余 Ventura 兼容项主要为 `22.0.0–22.99.99`。

参考：[RestrictEvents 1.1.6 说明](https://github.com/acidanthera/RestrictEvents/blob/1.1.6/README.md#boot-arguments)、[OCLP 2.5.1 Ivy Bridge 处理](https://github.com/dortania/OpenCore-Legacy-Patcher/blob/2.5.1/opencore_legacy_patcher/efi_builder/misc.py)、[原问题讨论](https://github.com/dortania/OpenCore-Legacy-Patcher/discussions/1036)。

这项配置已通过静态校验并写入实机使用的启动盘，但发布时没有用户明确的 Finder / 系统设置复测结论，因此不写作“已实机验证全部修复”。

## K420 与根卷补丁

发布者已用 OCLP 安装 NVIDIA Kepler 根卷补丁，并反馈有加速，DP 直连的 macOS 桌面正常 4K。本仓库仅包含 EFI；根卷补丁需要在安装的 macOS 中使用 OCLP 执行。

未加入 NVIDIA Web Driver 专用参数，也未启用 `nv_disable=1`。原核显已通过 `-wegnoigpu` 停用，本分支不使用 MEI 解隐藏 SSDT 或 P4000 注入。

## 第一屏 4K 未完成

同版本 DEBUG 引导取得的模式记录为：

```text
OCC: Mode 0 - 800x600:1
OCC: Mode 1 - 1280x1024:1
OCC: Setting mode 1 with 1280x1024 resolution
```

当前 GOP 没有向 OpenCore 提供 3840×2160。`Resolution=Max` 正常工作，`UIScale=2` 只改变缩放，不能增加物理分辨率。

切换 Video OpROM 到 UEFI First 后，该板曾卡住并无法进入 BIOS。发布者随后恢复到能正常启动的状态，4K 固件研究已停止。本分支只保存 RELEASE 引导，不带临时 DEBUG 核心、显卡固件修改或刷写工具。

该记录不能证明 K420 硬件不支持 4K，也不能单凭它区分 BIOS 初始化方式和显卡 GOP 固件限制。[OpenCore 输出配置说明](https://dortania.github.io/docs/release/Configuration.html)。

## 条件项与未验证项目

- 当前没有独立 SSDT-PM：需要结合主板原生 ACPI 和实际变频状态决定是否生成。
- ASPP-Override、NoAVXFSCompressionTypeZlib、SBVMM 及 PCI 总线修复均未因其他 EFI 包含就直接添加；它们有各自适用条件。
- `AppleXcpmCfgLock` 保留原可启动配置；Ivy Bridge 在这里使用旧 AICPUPM 路径，不据此宣称 XCPM 已启用。
- 内核范围限定为 Ventura；其他系统、主板固件、显卡型号、声音、睡眠、DRM 和 USB 定制均需要重新验证。
