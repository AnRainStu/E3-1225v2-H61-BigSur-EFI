# 第三方来源与许可

本仓库是特定硬件的 EFI 配置与第三方组件集合。根目录 MIT 许可只覆盖原创文档、脚本与原创修改，不重新授权继承的配置、第三方二进制或资源。

| 内容 | 来源 | 许可 / 说明 |
| --- | --- | --- |
| 基础配置 | [raywcm](https://github.com/raywcm/OpenCore-EFI-for-e3_1225v2-igpu/tree/597fd19a1f9c91a083568df14a842fbac49ecfe2) | 继承 main 分支的来源记录；上游 README 标注 MIT，快照未附独立 LICENSE |
| OpenCore、OpenRuntime、OpenCanopy | [OpenCorePkg 1.0.8](https://github.com/acidanthera/OpenCorePkg/tree/1.0.8) | BSD-3-Clause；LICENSES/OpenCorePkg.txt |
| NvmExpressDxe、HfsPlus、Resources、SSDT-EC-DESKTOP | 基础 EFI 继承；相关上游为 [OpenCorePkg](https://github.com/acidanthera/OpenCorePkg)、[OcBinaryData](https://github.com/acidanthera/OcBinaryData) | 保留继承文件和上游版权；未将这些资源重新授权 |
| Lilu 1.7.2 | [源码](https://github.com/acidanthera/Lilu/tree/1.7.2) | BSD-3-Clause；LICENSES/Lilu.txt |
| VirtualSMC 1.3.8 | [源码](https://github.com/acidanthera/VirtualSMC/tree/1.3.8) | BSD-3-Clause；LICENSES/VirtualSMC.txt |
| WhateverGreen 1.7.1 | [源码](https://github.com/acidanthera/WhateverGreen/tree/1.7.1) | BSD-3-Clause；LICENSES/WhateverGreen.txt |
| CryptexFixup 1.0.5 | [源码](https://github.com/acidanthera/CryptexFixup/tree/1.0.5) | BSD-3-Clause；LICENSES/CryptexFixup.txt |
| RestrictEvents 1.1.6 | [源码](https://github.com/acidanthera/RestrictEvents/tree/1.1.6) | BSD-3-Clause；LICENSES/RestrictEvents.txt |
| AppleALC 1.9.0 | [源码](https://github.com/acidanthera/AppleALC/tree/1.9.0) | BSD 风格；LICENSES/AppleALC.txt |
| RealtekRTL8111 2.4.2 | [Mieze 源码](https://github.com/Mieze/RTL8111_driver_for_OS_X) | GPLv2；保留上游 README 和 GPL-2.0 文本 |
| RealtekRTL8100 2.0.1 | [Mieze 原项目](https://github.com/Mieze/RealtekRTL8100) | 由基础配置继承；保留上游 README 与版权，未在此重新编译 |
| AMFIPass 1.4.1 | [OCLP 2.5.1 payload](https://github.com/dortania/OpenCore-Legacy-Patcher/blob/2.5.1/payloads/Kexts/Acidanthera/AMFIPass-v1.4.1-RELEASE.zip) | 从该 payload 继承的组件；不将其重新授权为本仓库原创代码 |
| AppleIntelCPUPowerManagement / Client 222.0.0 | [OCLP 2.5.1 Misc payload](https://github.com/dortania/OpenCore-Legacy-Patcher/tree/2.5.1/payloads/Kexts/Misc) | 使用上游 v1.0.0 分发包，包内 CFBundleVersion 为 222.0.0；Apple 派生二进制保留原版权，不适用根目录 MIT |
| Library Validation 补丁配置与兼容处理依据 | [OCLP 2.5.1](https://github.com/dortania/OpenCore-Legacy-Patcher/tree/2.5.1) | 上游完整许可见 LICENSES/OpenCore-Legacy-Patcher.txt |

This product includes software developed by Dortania and OpenCore Legacy Patcher contributors.

来源、版本、下载摘要及内核范围见 [components.json](components.json)。许可文本按对应标签获取，来源摘要见 `LICENSES/upstream-licenses.json`。Apple 二进制、AMFIPass 等组件的来源说明不等于主张其源码已公开或获得根目录 MIT 授权。
