/* H61 X7-VB V3.2, BIOS 4.6.5 2025-05-20.
 * Target evidence: original DSDT SHA256 is recorded in the package report.
 * Intel 324645-006 section 10.1.49: RCBA+3428h, bit 1, R/W MEI1 Disable.
 * The matching DSDT patch renames only PCI0._INI to XINI. Preserve it first.
 * This is a guarded boot-time unhide attempt, not a flash/ME firmware repair.
 */
DefinitionBlock ("", "SSDT", 2, "E3FIX", "H61MEI", 0x00000001)
{
    External (_SB_.PCI0, DeviceObj)
    External (_SB_.PCI0.LPCB, DeviceObj)
    External (_SB_.PCI0.XINI, MethodObj)

    Scope (\_SB.PCI0.LPCB)
    {
        OperationRegion (E3PC, PCI_Config, Zero, 0x0100)
        Field (E3PC, DWordAcc, NoLock, Preserve)
        {
            E3ID, 32,
            Offset (0xF0),
            E3RB, 32
        }
    }

    Scope (\_SB.PCI0)
    {
        Device (IMEI)
        {
            Name (_ADR, 0x00160000)
            Name (BFD2, 0xFFFFFFFF)
            Name (AFD2, 0xFFFFFFFF)
            Name (MEST, Zero)
            OperationRegion (E3RC, SystemMemory, 0xFED1F428, 0x04)
            Field (E3RC, DWordAcc, NoLock, Preserve)
            {
                FDR2, 32
            }

            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin")) { Return (0x0F) }
                Return (Zero)
            }

            Method (MEEN, 0, Serialized)
            {
                MEST = One
                If (!_OSI ("Darwin")) { Return (Zero) }
                MEST = 0x02
                If (\_SB.PCI0.LPCB.E3ID != 0x1C5C8086) { Return (Zero) }
                MEST = 0x03
                If ((\_SB.PCI0.LPCB.E3RB & 0xFFFFC001) != 0xFED1C001) { Return (Zero) }
                MEST = 0x04
                BFD2 = FDR2
                AFD2 = BFD2
                If (BFD2 == 0xFFFFFFFF) { Return (Zero) }
                MEST = 0x05
                If (!(BFD2 & 0x02)) { Return (One) }
                FDR2 = (BFD2 & 0xFFFFFFFD)
                AFD2 = FDR2
                MEST = 0x07
                If ((AFD2 & 0x02)) { Return (Zero) }
                MEST = 0x06
                Return (One)
            }

            Method (_DSM, 4, NotSerialized)
            {
                If (!Arg2) { Return (Buffer (One) { 0x03 }) }
                Return (Package ()
                {
                    "e3-mei-unhide-status", MEST,
                    "e3-mei-fd2-before", BFD2,
                    "e3-mei-fd2-after", AFD2
                })
            }
        }
    }

    // If the exact original-method rename is inapplicable, leave the original
    // firmware initialization alone instead of defining a duplicate _INI.
    If (CondRefOf (\_SB.PCI0.XINI))
    {
        Scope (\_SB.PCI0)
        {
            Method (_INI, 0, NotSerialized)
            {
                XINI ()
                \_SB.PCI0.IMEI.MEEN ()
            }
        }
    }
}
