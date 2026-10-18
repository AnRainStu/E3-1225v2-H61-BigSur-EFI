# E3-1225v2 / H61 X7-VB / Big Sur EFI

用于 **Xeon E3-1225 v2 + H61 X7-VB V3.2 + Intel HD Graphics P4000** 的 OpenCore EFI。
目标系统为 **macOS Big Sur 11.7.10 (20G1427)**，使用 SATA 系统盘、主板 HDMI 直连。

这份配置针对“能显示核显型号和 1536 MB 显存，但窗口动画卡顿、加速服务没有启动”的问题，增加了带硬件条件检查的 **H61 MEI 恢复 SSDT**。发布者在这台机器上反馈修复后已可用。

> 适用范围是下表中的实机配置，不是通用 H61 EFI。公开配置已清空机器身份信息，使用前必须自行生成 SMBIOS。

## 实机环境与验证范围

| 项目 | 配置 / 结果 |
| --- | --- |
| CPU | Intel Xeon E3-1225 v2，Ivy Bridge，4 核 4 线程 |
| 主板 | H61 X7-VB，V3.2，非品牌整机主板 |
| BIOS | American Megatrends 4.6.5，日期 2025-05-20 |
| 内存 | 8 GB DDR3 |
| 核显 | Intel HD Graphics P4000，原生 PCI ID 8086:016A |
| 显示连接 | 主板 HDMI 直连；VGA 不在本次成功配置的验证范围 |
| 系统 | macOS Big Sur 11.7.10，安装在 SATA 盘 |
| OpenCore | 1.0.0 RELEASE，苹果标志与进度条，保留文件日志 |
| SMBIOS | iMac15,1；序列号、MLB、UUID、ROM 由使用者填写 |
| 启动 / 图形 | 发布者实机反馈修复后可用；尚未附修复后的 Metal / IORegistry 复测报告 |
| 声音 / 睡眠 / DRM | 未单独完成验证，不据此宣称全部功能正常 |

此前使用的 64 GB E2M2 PCIe 存储模块在格式化、APFS 转换时出现冻结，因此改用 SATA。包中保留 NVMeFix 1.1.3 文件，但**当前 config 没有启用 NVMeFix**；不将它描述为该存储模块的兼容性修复。

## 下载与使用

1. 在 [Releases](https://github.com/AnRainStu/E3-1225v2-H61-BigSur-EFI/releases) 下载发布压缩包，或下载仓库 ZIP。
2. 备份自己目前能启动的 EFI。确认主板、BIOS、显示连接与本仓库的适用范围。
3. 使用 [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) 为 **iMac15,1** 生成独立身份，并使用 plist 编辑器填写 `EFI/OC/config.plist` 的 `PlatformInfo → Generic`：

   | 字段 | 填写内容 |
   | --- | --- |
   | `SystemSerialNumber` | 自己生成的系统序列号 |
   | `MLB` | 自己生成的 Board Serial |
   | `SystemUUID` | 自己生成的 SmUUID |
   | `ROM` | 自己设备对应的 6 字节 ROM 数据 |

4. 使用与本配置匹配的 **OpenCore 1.0.0 ocvalidate** 检查修改后的 plist。
5. 将 `EFI` 文件夹放到启动盘 ESP 分区根目录，从该盘的 UEFI 入口启动。建议先在启动盘上验证，再迁移到系统盘。

仓库不包含 macOS 安装镜像、个人身份信息、原始 SysReport、IORegistry 或启动日志。请勿把填入身份信息后的 config 或未脱敏日志提交到公开仓库。

## 核显与 MEI 修复

修复前日志显示 Capri 和 HD4000 驱动存在，但没有真正的 `IntelAccelerator` 服务；IMEI 只有 ACPI 占位。随后 SysReport 显示，固件 PCI 列表里也没有 `00:16.0` MEI。

本版没有仅靠改显卡名称判断加速，而是尝试在 macOS 启动时恢复 MEI 接口：

- 对精确匹配的 DSDT，将原 `PCI0._INI` 重命名为 `XINI`，新方法先执行原初始化。
- 仅在 Darwin、LPC ID `1C5C8086`、启用的 RCBA 基址 `FED1C000` 匹配时继续。
- 读取 RCBA + `0x3428`（FD2）；如果读值有效且 bit 1 为 1，则只清除这个 MEI1 禁用位。
- 保留其他寄存器位，并提供读取结果与状态属性，供后续验证。

完整条件、状态码、限制和上游依据见 [MEI 修复说明](docs/MEI-FIX.md)。源代码位于 [SSDT-IMEI-H61.dsl](Sources/SSDT-IMEI-H61.dsl)。

这项修改不是 BIOS / ME 固件刷写。若板子不同、ME 固件本身异常或隐藏位原本没有置位，不能假定同一补丁会有效。移除本版补丁并恢复原 EFI 后，应完整断电冷启动再比较结果。

保留的图形配置包括 `device-id=0166`、`igfxframe=0x0166000B`、WhateverGreen 和 FakePCIID。不要直接用这份 Big Sur 配置升级系统；Monterey 及以上的 Ivy Bridge 核显支持需要另外处理。

## 组件版本

| 组件 | 版本 | 本配置状态 |
| --- | --- | --- |
| OpenCore / OpenRuntime / OpenCanopy | 1.0.0 RELEASE | 启用 |
| Lilu | 1.6.7 | 启用 |
| VirtualSMC | 1.3.2 | 启用 |
| WhateverGreen | 1.6.6 | 启用 |
| FakePCIID | 1.3.16 | Big Sur 20.4.0–20.99.99 启用 |
| FakePCIID_Intel_HD_Graphics | 1.3.15 | Big Sur 20.4.0–20.99.99 启用 |
| AppleALC | 1.9.0 | 启用；板载音频未单独验证 |
| RealtekRTL8111 | 2.4.2 | 启用 |
| RealtekRTL8100 | 2.0.1 | 启用 |
| Innie | 1.3.1 | 启用 |
| NVMeFix | 1.1.3 | 文件保留，未启用 |
| HfsPlus / NvmExpressDxe | 基础 EFI 所含版本 | 启用 |

## 验证与诊断

- 公共 config 通过 OpenCore 1.0.0 `ocvalidate`。
- 定制 AML 编译通过；9 项 ACPICA 模拟检查覆盖目标分支、错误芯片 / 地址保护、原初始化保留等情况。模拟结果见 `docs/mei-simulation-results.json`，模拟不等于实机寄存器或 Metal 验证。
- `checksums.sha256` 记录发布 EFI 和定制 SSDT 源码的 SHA-256。
- 在已安装的 macOS 上运行 `tools/CollectGraphics.command` 可收集显示、驱动和 MEI 状态。工具只读取状态，输出的日志包含设备信息，请检查并脱敏后再分享。

显卡名称或 1536 MB 显存本身不能证明加速。应结合“系统信息 → 图形卡 / 显示器”中的 Metal 状态、`IntelAccelerator` 服务和实际窗口动画判断。

## 来源与许可

基础配置来自 [raywcm/OpenCore-EFI-for-e3_1225v2-igpu](https://github.com/raywcm/OpenCore-EFI-for-e3_1225v2-igpu)，快照提交 `597fd19a1f9c91a083568df14a842fbac49ecfe2`；在其基础上保留已能启动的设置，加入 P4000 兼容组件和本机 MEI 修复。

第三方 OpenCore、驱动和资源继续遵循各自许可，详见 [第三方来源](THIRD_PARTY.md) 与 `LICENSES/`。本仓库的原创文档和新增脚本 / SSDT 源码按根目录 [LICENSE](LICENSE) 许可；该许可不重新授权第三方二进制、资源或上游配置。
