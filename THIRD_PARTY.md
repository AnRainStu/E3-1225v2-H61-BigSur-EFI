# 第三方来源与许可

本仓库是 EFI 配置与二进制集合，不对其中第三方内容统一套用根目录 MIT 许可。第三方内容保留原作者许可与版权，原始源码 / 构建说明以对应上游为准。

| 内容 | 上游 / 源码 | 许可 / 说明 |
| --- | --- | --- |
| 基础 EFI 配置 | [raywcm](https://github.com/raywcm/OpenCore-EFI-for-e3_1225v2-igpu/tree/597fd19a1f9c91a083568df14a842fbac49ecfe2) | 上游 README 标注 MIT，取用快照未附独立 LICENSE；本仓库保留来源，不将其重新授权为本仓库原创内容 |
| OpenCore、UEFI 工具、OpenRuntime、OpenCanopy、NvmExpressDxe | [OpenCorePkg 1.0.0](https://github.com/acidanthera/OpenCorePkg/tree/1.0.0) | 上游 BSD 风格许可，见 LICENSES/OpenCorePkg.txt；相关组件还可能附带上游第三方版权 |
| HfsPlus、Resources | 基础 EFI 所含资源；相关公开分发项目为 [OcBinaryData](https://github.com/acidanthera/OcBinaryData) | 保留文件；此处不主张它们的原创权或重新授权 |
| SSDT-EC-DESKTOP | [OpenCore ACPI 示例](https://github.com/acidanthera/OpenCorePkg/tree/1.0.0/Docs/AcpiSamples) / 基础 EFI | 按上游许可 |
| Lilu 1.6.7 | [源码](https://github.com/acidanthera/Lilu/tree/1.6.7) | BSD 风格，见 LICENSES/Lilu.txt |
| VirtualSMC 1.3.2 | [源码](https://github.com/acidanthera/VirtualSMC/tree/1.3.2) | BSD 风格，见 LICENSES/VirtualSMC.txt |
| WhateverGreen 1.6.6 | [源码](https://github.com/acidanthera/WhateverGreen/tree/1.6.6) | BSD 风格，见 LICENSES/WhateverGreen.txt |
| AppleALC 1.9.0 | [源码](https://github.com/acidanthera/AppleALC/tree/1.9.0) | BSD 风格，见 LICENSES/AppleALC.txt |
| NVMeFix 1.1.3（未启用） | [源码](https://github.com/acidanthera/NVMeFix/tree/1.1.3) | BSD 风格，见 LICENSES/NVMeFix.txt |
| FakePCIID 1.3.16 | [Big Sur 兼容版本 / 源码](https://github.com/mbarbierato/OS-X-Fake-PCI-ID/tree/v1.3.16)、[原项目](https://github.com/RehabMan/OS-X-Fake-PCI-ID) | GPL-2.0，见 LICENSES/FakePCIID.txt |
| FakePCIID_Intel_HD_Graphics 1.3.15 | [原项目源码](https://github.com/RehabMan/OS-X-Fake-PCI-ID) | GPL-2.0；本包是原项目的 codeless injector |
| RealtekRTL8111 2.4.2 | [Mieze 源码](https://github.com/Mieze/RTL8111_driver_for_OS_X) | GPLv2；上游声明与许可文本见 LICENSES/ |
| RealtekRTL8100 2.0.1 | [Mieze 原项目源码](https://github.com/Mieze/RealtekRTL8100) | 保留上游版权与许可；文件由基础 EFI 继承，未在本仓库重新编译 |
| Innie 1.3.1 | [源码](https://github.com/cdf/Innie) | BSD-3-Clause，见 LICENSES/Innie.txt |

MEI 寄存器含义参考 Intel 数据手册，恢复方法参考 coreboot 4.22 intelmetool 的公开实现；新增 SSDT 代码随仓库提供，未包含刷写 BIOS / ME 的工具。
