# CP/NET SPR (Segments Program Record) Format

## Overview
The SPR format is used by CP/NET CPNETLDR to load relocatable program modules (SNIOS.SPR and NDOS.SPR). This document describes the format as implemented in RC702 CP/NET.

## File Layout

The SPR file is organized as sectors (128 bytes each):

```
Sector 0:     Parameter Record (128 bytes)
              Byte 0:     (reserved)
              Byte 1:     Code length (low byte)
              Byte 2:     Code length (high byte)
              Byte 3:     Data length (low byte)
              Byte 4:     Data length (high byte)
              Byte 5-127: (unused/padding)

Sector 1:     Data Sector (128 bytes, read and discarded by loader)
              Contains initial data values for uninitialized variables.
              CPNETLDR reads this but does not process it.

Sectors 2..N: Code + Relocation Bitmap (packed together)
              Code bytes followed immediately by bitmap bytes, no gaps.
              The combined data is padded to 128-byte sector boundary.
              Total sectors: ceil((code_length + bitmap_length) / 128)
```

## Relocation Bitmap

The relocation bitmap follows the code bytes immediately (no sector alignment).

**Format**:
- 1 bit per code byte (MSB first within each byte)
- bit = 1: the corresponding code byte is the HIGH BYTE of a 16-bit address that needs relocation
- bit = 0: the byte is not relocatable

**Size**: `ceil(code_length / 8)` bytes

**Packing**: Each byte contains 8 bits for the next 8 code bytes:
- Byte N, bit 7: code byte 8*N + 0
- Byte N, bit 6: code byte 8*N + 1
- ...
- Byte N, bit 0: code byte 8*N + 7

## Loading Process (CPNETLDR)

1. Read parameter sector (sector 0)
2. Extract code_length and data_length
3. Read data sector (sector 1) and discard
4. Read ceil(code_length / 128) sectors into memory at LDTOP
5. Read relocation bitmap from LDTOP + code_length
6. For each relocatable byte (bitmap bit = 1):
   - Add load bias (difference between actual load address and assembly ORG)
   - The load bias is typically the page number offset (e.g., if ORG=0x0000 but loaded at 0xC800, bias = 0xC8)

## Generation (zmac Assembly)

The build_snios.py script generates SPR by:

1. Assembling the code at ORG 0x0000
2. Assembling the same code at ORG 0x0100
3. Comparing the two assemblies byte-by-byte
4. Any byte that differs by exactly 1 (the high page byte) is marked as relocatable
5. Bitmap is built with bit = 1 for relocatable bytes
6. Code and bitmap are packaged into SPR format

## References

- CPNETLDR implementation: https://github.com/M3wP/cpnet-z80
- RC702 CP/NET: https://git.datamuseum.dk/rc700/mame-rc700
