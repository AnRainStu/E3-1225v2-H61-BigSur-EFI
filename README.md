# E3-1225 v2 / H61 X7-VB / Quadro K420 / Ventura EFI

用于 **Xeon E3-1225 v2 + H61 X7-VB V3.2 + Quadro K420 + SATA 系统盘** 的 OpenCore 配置，目标系统为 **macOS Ventura 13.7.8 (22H730)**。

当前仓库仅维护 `ventura-k420` 分支的 Ventura / Quadro K420 配置。

这是特定实机的配置与第三方组件集合。公开版已清空机器身份，使用前必须自行填写 SMBIOS；第三方组件遵循各自许可。

## 硬件与验证范围

| 项目 | 配置 / 状态 |
| --- | --- |
| CPU | Intel Xeon E3-1225 v2，Ivy Bridge，4 核；支持 AVX / F16C，不支持 AVX2 |
| 主板 | H61 X7-VB V3.2，AMI BIOS 4.6.5，日期 2025-05-20 |
| 内存 | 8 GB DDR3 |
| 显卡 | NVIDIA Quadro K420，显示器接独显 DP |
| 核显 | 通过 `-wegnoigpu` 停用，未使用旧 P4000 注入和 MEI 恢复补丁 |
| 系统盘 | SATA SSD；旧 E2M2 PCIe 存储模块曾在磁盘操作时冻结，不作为安装目标 |
| 系统 | Ventura 13.7.8 (22H730) |
| OpenCore | 1.0.8 RELEASE；苹果标志与进度条，未启用 `-v` |
| SMBIOS | iMac18,2；公开版序列号、MLB、UUID 为空，ROM 为 6 字节零值占位 |
| 系统启动 | 发布者已进入 Ventura 桌面 |
| K420 图形 | 发布者反馈 OCLP 补丁后有加速，DP 直连桌面正常 4K |
| Finder | 根据 25 份同一签名的报告加入 F16C 官方兼容修复；发布时尚无用户明确的修复后复测反馈 |
| OpenCore 第一屏 | DEBUG 诊断确认可选模式仅 800×600、1280×1024；最高选中 1280×1024 |
| 声音、睡眠、DRM、CPU 变频 | 未完成独立实机验证，不据此声称全功能正常 |

## 下载与使用

1. 在 [Ventura v1.0.0 Release](https://github.com/AnRainStu/E3-1225v2-H61-EFI/releases/tag/ventura-k420-v1.0.0) 下载 EFI 压缩包，或[下载本分支 ZIP](https://github.com/AnRainStu/E3-1225v2-H61-EFI/archive/refs/heads/ventura-k420.zip)。先备份现有可启动 EFI。
2. 使用 [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) 为 **iMac18,2** 生成自己的身份，在 `EFI/OC/config.plist → PlatformInfo → Generic` 填写：

   | 字段 | 内容 |
   | --- | --- |
   | `SystemSerialNumber` | 自己生成的系统序列号 |
   | `MLB` | 自己生成的主板序列号 |
   | `SystemUUID` | 自己生成的 SmUUID |
   | `ROM` | 自己设置的 6 字节设备 ROM 数据 |

3. 使用 **OpenCore 1.0.8** 配套的 `ocvalidate` 检查修改后的配置。
4. 将 `EFI` 文件夹复制到启动盘 ESP 根目录，从该盘的 UEFI 入口启动；显示器接 K420。
5. 安装 / 启动 Ventura 后，使用 [OCLP 2.5.1](https://github.com/dortania/OpenCore-Legacy-Patcher/releases/tag/2.5.1) 的 **Post-Install Root Patch** 安装 NVIDIA Kepler 补丁，按提示重启。这里的 EFI 不能替代系统根卷显卡补丁。

OCLP 在这里用于根卷补丁；引导继续使用本分支 EFI。配置只针对 Ventura，相关兼容组件限定在 Darwin 22 内核范围，不据此支持 Sonoma、Sequoia 或更新系统。

## Ventura / Ivy Bridge 兼容项

- **CryptexFixup 1.0.5**：用于此非 AVX2 CPU 的 Ventura 兼容。
- **AppleIntelCPUPowerManagement + Client**：从 OCLP 2.5.1 payload 继承的旧 CPU 电源管理组件；`AppleCpuPmCfgLock=true`，`DummyPowerManagement=false`。
- **AMFIPass 1.4.1**、SIP `0x803`（`03080000`）、`SecureBootModel=Disabled` 及两项 Library Validation 补丁：与 OCLP 根卷补丁配套。
- **RestrictEvents 1.1.6 + `revpatch=f16c`**：避免 Ivy Bridge 在 macOS 13.3+ 的 CoreGraphics `resample_horizontal_f16c` 路径触发非法指令。
- `revblock=none`，不默认屏蔽照片分析等进程；`ipc_control_port_options=0` 保留在当前配置中。
- NVRAM Delete 已覆盖相应启动参数，便于配置更新生效。

F16C 修复不会改写 CPU 固件。更多依据、限定范围和已知问题见 [Ventura 说明](docs/VENTURA-NOTES.md)。

## BIOS 与第一屏分辨率

保留这块板已经能启动的 BIOS 设置。**本机将 Video OpROM 改为 UEFI First 后曾卡在开机画面，连 BIOS 都无法进入；本分支不要求为提升分辨率而修改该项或关闭 CSM。** SATA 模式使用 AHCI，主板 Secure Boot 关闭，启动盘仍走 UEFI 入口。

`Resolution=Max`、`UIScale=0`、`ProvideConsoleGop=true` 已配置。诊断确认当前固件提供的最高模式为 **1280×1024**；桌面正常 4K 不代表引导第一屏具备 4K 模式。此分支没有完成 GOP / VBIOS 4K 改造，也没有刷写 BIOS、ME 或显卡固件。

系统更新可能移除 OCLP 根卷补丁，更新后需要重新检查并按 OCLP 提示补丁。当前没有单独的 `SSDT-PM`，CPU 变频是否需要定制表仍需本机数据验证；不能直接复制其他 CPU 的表。

## 组件与校验

完整版本与来源见 [components.json](components.json)，EFI 文件的 SHA-256 见 [checksums.sha256](checksums.sha256)。公开配置通过 OpenCore 1.0.8 `ocvalidate`，并检查了配置引用、内核范围、正式版核心文件以及机器身份清除情况，见 [发布校验记录](docs/validation.json)。

本分支不包含安装镜像、OCLP 安装包、原始诊断报告、VBIOS、NVFlash 工具或机器身份。使用者填写身份后的 config 和原始日志应保留在自己的设备上。

## 来源与许可

基础配置继承自 [raywcm 的 E3-1225v2 核显 EFI](https://github.com/raywcm/OpenCore-EFI-for-e3_1225v2-igpu/tree/597fd19a1f9c91a083568df14a842fbac49ecfe2)，Ventura 兼容处理参考 [OCLP 2.5.1](https://github.com/dortania/OpenCore-Legacy-Patcher/tree/2.5.1) 及 [Ivy Bridge 专项指南](https://github.com/5T33Z0/OCLP4Hackintosh/blob/main/Guides/Ivy_Bridge.md)。

This product includes software developed by Dortania and OpenCore Legacy Patcher contributors.

原创文档与脚本适用根目录 [LICENSE](LICENSE)。第三方程序、驱动、资源和继承的配置仍适用各自许可，不因仓库公开而统一改为 MIT，详见 [THIRD_PARTY.md](THIRD_PARTY.md) 与 `LICENSES/`。
