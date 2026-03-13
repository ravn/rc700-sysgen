# Boot Pointer Address Limit Investigation

## Summary

The boot pointer (first word of Track 0) tells the ROM where to jump after
loading Track 0 to address 0x0000.  When `_cboot` is at address **0x47 or
below**, the system boots correctly.  At **0x48 or above**, it fails silently
(blank screen).

## Boot Sector Layout

```
Offset  Content
------  -------
0x00    defw _cboot          ; boot pointer (2 bytes)
0x02    defs 6               ; reserved zeros
0x08    defm " RC702"        ; system signature (6 bytes)
0x0E    <user string>        ; up to 57 bytes
0x47    _cboot:              ; maximum safe address
...     (cold boot code, 53 bytes)
0x7C    defs 128 - ASMPC     ; pad to 128 bytes
0x80    (CONFI block starts)
```

## Bisection Results

Tested by varying string length to push `_cboot` to different addresses:

| _cboot addr | Boot result |
|-------------|-------------|
| 0x0E        | OK          |
| 0x3B        | OK          |
| 0x47        | OK          |
| **0x48**    | **FAIL**    |
| 0x4C        | FAIL        |

The boundary is exact: 0x47 works, 0x48 does not.

## Verified NOT the Cause

- **Stale MFI**: Tested with fresh MFI (rm + floptool convert). Still fails.
- **Binary content**: Hex-dumped bios.cim — boot pointer word and code are correct.
- **IMD sector data**: Extracted Track 0 sectors from IMD, verified data matches .cim.
- **BOOT.bin size**: Exactly 640 bytes (128 boot + 512 CONFI/danish) as expected.
- **Padding**: `defs 128 - ASMPC` with ASMPC=0x7D (for 0x48 case) is well under 128.

## Hypotheses (Untested)

1. **ROM bootstrap limitation**: The boot ROM (ROA375) may have an internal
   limit on the boot pointer value, perhaps checking that it falls within
   the first 72 bytes or similar.

2. **z88dk assembler issue**: The `defs 128 - ASMPC` directive might behave
   unexpectedly near certain boundaries, though ASMPC never reaches 128
   in the failing cases.

3. **MAME emulation artifact**: The RC702 MAME driver may impose constraints
   not present in real hardware.

## Workaround

Keep the boot sector string to **57 bytes or fewer** (starting at offset 0x0E),
ensuring `_cboot` remains at address 0x47 or below.  The cold boot code is
53 bytes, so total boot sector usage is: 14 (header) + string + 53 (code) ≤ 128.

Maximum string length = 128 - 14 - 53 = 61 bytes theoretically, but the
empirical limit is 57 bytes (0x47 - 0x0E).

## Date

2026-03-13
