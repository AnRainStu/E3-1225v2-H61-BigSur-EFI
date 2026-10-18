# H61 MEI 恢复补丁

## 依据

- 原始固件 PCI 报告中存在 P4000 `016A` 与 H61 LPC `1C5C`，没有 MEI `00:16.0`。
- 原始 DSDT 没有 IMEI / HECI 设备定义，包含 `SRCB=FED1C000`，并且只有一个 `_INI`。
- Intel 6 Series / C200 数据手册 **324645-006，第 10.1.49 节，印刷页 411**：FD2 位于 RCBA + 3428h，bit 1 是 R/W 的 MEI1 Disable（0 启用，1 禁用）。
- [coreboot 4.22 intelmetool](https://github.com/coreboot/coreboot/blob/4.22/util/intelmetool/intelmetool.c) 的 `activate_me` 同样使用 `fd2 & ~0x2` 取消隐藏，再扫描 PCI。

[Intel 数据手册](https://www.intel.com/content/dam/www/public/us/en/documents/datasheets/6-chipset-c200-chipset-datasheet.pdf)

## ACPI 配合条件

config 中唯一新增的启用补丁严格限制为：

| 字段 | 值 |
| --- | --- |
| TableSignature | `DSDT` |
| TableLength | `36816` |
| OemTableId（原始字节） | `41 20 4D 20 49 00 00 00` |
| Find / Replace | `_INI` → `XINI` |
| Count | `1` |

该表 ID 含 NUL 填充，不应替换成空格。补丁依赖本机 DSDT 的唯一 `_INI`，相同长度与表 ID 不足以保证另一块板的语义相同，其他主板必须重新检查。

SSDT 仅当 `PCI0.XINI` 存在时定义包装 `_INI`。包装先调用原 `XINI()`，再调用 `IMEI.MEEN()`。如果该精确重命名没有命中，原固件 `_INI` 保留；模拟已检查不会新增冲突初始化方法。

## 运行时保护与状态

SSDT 依次检查 Darwin、LPC 设备 ID `1C5C8086`、RCBA 使能与基址 `FED1C000`。确认 FD2 不是 `FFFFFFFF` 后，仅在 bit 1 被置位时写回 `old & FFFFFFFD`，再读回验证。

`IMEI` 的 `_DSM` 发布：

- `e3-mei-unhide-status`
- `e3-mei-fd2-before`
- `e3-mei-fd2-after`

| 状态 | 含义 |
| --- | --- |
| 0 | 尚未执行 |
| 1 | 非 Darwin，跳过 |
| 2 | LPC ID 不匹配，跳过 |
| 3 | RCBA 基址或使能状态不匹配，跳过 |
| 4 | FD2 读取异常，跳过 |
| 5 | MEI1 禁用位原本已清零 |
| 6 | 本次写回后确认禁用位清零 |
| 7 | 写回后禁用位仍未清零 |

状态 6 只证明该位读回为零；仍需确认实际 MEI PCI 服务、AppleIntelMEIDriver 和 IntelAccelerator。固件 SysReport 没有 FD2 实测值，所以设备隐藏的具体原因在发布前没有由寄存器日志独立证实。

## 编译

使用 ACPICA iASL：

```text
iasl -ve -tc Sources/SSDT-IMEI-H61.dsl
```

将生成 AML 放入 `EFI/OC/ACPI/SSDT-IMEI.aml`，并使用 OpenCore 1.0.0 的 ocvalidate 检查 config。测试使用了 ACPICA 默认的模拟 OperationRegion，没有在准备文件的 Windows 电脑执行这些硬件访问。
