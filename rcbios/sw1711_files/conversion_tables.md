# RC702 Character Conversion Tables

Extracted from CONFI.COM (SW1711-I8 disk image).

## Overview

The RC702 CRT controller uses a character ROM (ROA296) with Danish national
characters as the native character set. The keyboard also produces Danish
codes natively. For other languages, CONFI.COM installs conversion tables
into the BIOS at address 0xF680 (3 × 128 = 384 bytes).

Each table has three 128-byte sub-tables:

| Offset | Purpose | Direction |
|--------|---------|-----------|
| +0x00  | Output conversion | Application char → CRT ROM position |
| +0x80  | Input conversion  | Keyboard code → application char |
| +0x100 | Semigraphic map   | Semigraphic character mapping (ROA327) |

The Danish table is the identity map (no conversion needed).

## Summary

| # | Language | Output diffs | Input diffs | Semigfx diffs |
|---|----------|-------------|-------------|---------------|
| 0 | Danish | 0 | 0 | 95 |
| 1 | Swedish | 8 | 19 | 95 |
| 2 | German | 9 | 27 | 96 |
| 3 | UK_ASCII | 10 | 0 | 96 |
| 4 | US_ASCII | 9 | 0 | 95 |
| 5 | French | 9 | 16 | 95 |
| 6 | Library | 6 | 15 | 105 |

## RC702 National Character Positions

The following ASCII positions are used for national characters in the
RC702 CRT ROM (ROA296). These are the positions that differ between
language tables:

| Hex  | ASCII | Danish (ROM) | Notes |
|------|-------|-------------|-------|
| 0x23 | # | # | |
| 0x40 | @ | @→Ä (strstreg-A) | |
| 0x5B | [ | [→Æ | |
| 0x5C | \ | \→Ø | |
| 0x5D | ] | ]→Å | |
| 0x5E | ^ | ^ | |
| 0x60 | ` | `→ä | |
| 0x7B | { | {→æ | |
| 0x7C | | | |→ø | |
| 0x7D | } | }→å | |
| 0x7E | ~ | ~→ü | |

## 0. Danish

### Output conversion (0 differences)

Identity map — no conversion.

### Input conversion (0 differences)

Identity map — no conversion.

### Semigraphic map (95 differences)

Maps character codes to semigraphic ROM (ROA327) positions.
95 positions differ from identity (semigraphic ROM
has its own character layout). See `conversion_tables.bin` for raw data.

## 1. Swedish

### Output conversion (8 differences)

Maps application character codes to CRT ROM positions.

| Position | Identity | Mapped to | Notes |
|----------|----------|-----------|-------|
| 0x40 (@) | 0x40 | 0x0A (0x0A) | |
| 0x5B ([) | 0x5B | 0x06 (0x06) | |
| 0x5C (\) | 0x5C | 0x0E (0x0E) | |
| 0x5E (^) | 0x5E | 0x00 (0x00) | |
| 0x60 (`) | 0x60 | 0x1A (0x1A) | |
| 0x7B ({) | 0x7B | 0x60 (`) | |
| 0x7C (|) | 0x7C | 0x7E (~) | |
| 0x7E (~) | 0x7E | 0x40 (@) | |

### Input conversion (19 differences)

Maps keyboard scan codes to application character codes.

| Position | Identity | Mapped to | Notes |
|----------|----------|-----------|-------|
| 0x27 (') | 0x27 | 0x2F (/) | |
| 0x2B (+) | 0x2B | 0x5E (^) | |
| 0x2D (-) | 0x2D | 0x2B (+) | |
| 0x2F (/) | 0x2F | 0x2D (-) | |
| 0x3A (:) | 0x3A | 0x27 (') | |
| 0x3B (;) | 0x3B | 0x7E (~) | |
| 0x3C (<) | 0x3C | 0x3B (;) | |
| 0x3D (=) | 0x3D | 0x3F (?) | |
| 0x3E (>) | 0x3E | 0x3A (:) | |
| 0x3F (?) | 0x3F | 0x5F (_) | |
| 0x40 (@) | 0x40 | 0x3C (<) | |
| 0x5B ([) | 0x5B | 0x5C (\) | |
| 0x5C (\) | 0x5C | 0x5B ([) | |
| 0x5E (^) | 0x5E | 0x60 (`) | |
| 0x5F (_) | 0x5F | 0x3D (=) | |
| 0x60 (`) | 0x60 | 0x3E (>) | |
| 0x7B ({) | 0x7B | 0x7C (|) | |
| 0x7C (|) | 0x7C | 0x7B ({) | |
| 0x7E (~) | 0x7E | 0x40 (@) | |

### Semigraphic map (95 differences)

Maps character codes to semigraphic ROM (ROA327) positions.
95 positions differ from identity (semigraphic ROM
has its own character layout). See `conversion_tables.bin` for raw data.

## 2. German

### Output conversion (9 differences)

Maps application character codes to CRT ROM positions.

| Position | Identity | Mapped to | Notes |
|----------|----------|-----------|-------|
| 0x40 (@) | 0x40 | 0x13 (0x13) | |
| 0x5B ([) | 0x5B | 0x06 (0x06) | |
| 0x5C (\) | 0x5C | 0x0E (0x0E) | |
| 0x5D (]) | 0x5D | 0x00 (0x00) | |
| 0x60 (`) | 0x60 | 0x16 (0x16) | |
| 0x7B ({) | 0x7B | 0x60 (`) | |
| 0x7C (|) | 0x7C | 0x7E (~) | |
| 0x7D (}) | 0x7D | 0x40 (@) | |
| 0x7E (~) | 0x7E | 0x11 (0x11) | |

### Input conversion (27 differences)

Maps keyboard scan codes to application character codes.

| Position | Identity | Mapped to | Notes |
|----------|----------|-----------|-------|
| 0x19 (0x19) | 0x19 | 0x1A (0x1A) | |
| 0x1A (0x1A) | 0x1A | 0x19 (0x19) | |
| 0x23 (#) | 0x23 | 0x40 (@) | |
| 0x27 (') | 0x27 | 0x2F (/) | |
| 0x2A (*) | 0x2A | 0x5E (^) | |
| 0x2B (+) | 0x2B | 0x2A (*) | |
| 0x2D (-) | 0x2D | 0x7E (~) | |
| 0x2F (/) | 0x2F | 0x2D (-) | |
| 0x3A (:) | 0x3A | 0x23 (#) | |
| 0x3B (;) | 0x3B | 0x2B (+) | |
| 0x3C (<) | 0x3C | 0x3B (;) | |
| 0x3D (=) | 0x3D | 0x3F (?) | |
| 0x3E (>) | 0x3E | 0x3A (:) | |
| 0x3F (?) | 0x3F | 0x5F (_) | |
| 0x40 (@) | 0x40 | 0x3C (<) | |
| 0x59 (Y) | 0x59 | 0x5A (Z) | |
| 0x5A (Z) | 0x5A | 0x59 (Y) | |
| 0x5B ([) | 0x5B | 0x5C (\) | |
| 0x5C (\) | 0x5C | 0x5B ([) | |
| 0x5E (^) | 0x5E | 0x27 (') | |
| 0x5F (_) | 0x5F | 0x3D (=) | |
| 0x60 (`) | 0x60 | 0x3E (>) | |
| 0x79 (y) | 0x79 | 0x7A (z) | |
| 0x7A (z) | 0x7A | 0x79 (y) | |
| 0x7B ({) | 0x7B | 0x7C (|) | |
| 0x7C (|) | 0x7C | 0x7B ({) | |
| 0x7E (~) | 0x7E | 0x60 (`) | |

### Semigraphic map (96 differences)

Maps character codes to semigraphic ROM (ROA327) positions.
96 positions differ from identity (semigraphic ROM
has its own character layout). See `conversion_tables.bin` for raw data.

## 3. UK_ASCII

### Output conversion (10 differences)

Maps application character codes to CRT ROM positions.

| Position | Identity | Mapped to | Notes |
|----------|----------|-----------|-------|
| 0x23 (#) | 0x23 | 0x03 (0x03) | |
| 0x40 (@) | 0x40 | 0x05 (0x05) | |
| 0x5B ([) | 0x5B | 0x0B (0x0B) | |
| 0x5C (\) | 0x5C | 0x0C (0x0C) | |
| 0x5D (]) | 0x5D | 0x0D (0x0D) | |
| 0x60 (`) | 0x60 | 0x16 (0x16) | |
| 0x7B ({) | 0x7B | 0x1B (0x1B) | |
| 0x7C (|) | 0x7C | 0x1C (0x1C) | |
| 0x7D (}) | 0x7D | 0x1D (0x1D) | |
| 0x7E (~) | 0x7E | 0x0F (0x0F) | |

### Input conversion (0 differences)

Identity map — no conversion.

### Semigraphic map (96 differences)

Maps character codes to semigraphic ROM (ROA327) positions.
96 positions differ from identity (semigraphic ROM
has its own character layout). See `conversion_tables.bin` for raw data.

## 4. US_ASCII

### Output conversion (9 differences)

Maps application character codes to CRT ROM positions.

| Position | Identity | Mapped to | Notes |
|----------|----------|-----------|-------|
| 0x40 (@) | 0x40 | 0x05 (0x05) | |
| 0x5B ([) | 0x5B | 0x0B (0x0B) | |
| 0x5C (\) | 0x5C | 0x0C (0x0C) | |
| 0x5D (]) | 0x5D | 0x0D (0x0D) | |
| 0x60 (`) | 0x60 | 0x16 (0x16) | |
| 0x7B ({) | 0x7B | 0x1B (0x1B) | |
| 0x7C (|) | 0x7C | 0x1C (0x1C) | |
| 0x7D (}) | 0x7D | 0x1D (0x1D) | |
| 0x7E (~) | 0x7E | 0x0F (0x0F) | |

### Input conversion (0 differences)

Identity map — no conversion.

### Semigraphic map (95 differences)

Maps character codes to semigraphic ROM (ROA327) positions.
95 positions differ from identity (semigraphic ROM
has its own character layout). See `conversion_tables.bin` for raw data.

## 5. French

### Output conversion (9 differences)

Maps application character codes to CRT ROM positions.

| Position | Identity | Mapped to | Notes |
|----------|----------|-----------|-------|
| 0x40 (@) | 0x40 | 0x05 (0x05) | |
| 0x5B ([) | 0x5B | 0x0B (0x0B) | |
| 0x5C (\) | 0x5C | 0x0C (0x0C) | |
| 0x5D (]) | 0x5D | 0x0D (0x0D) | |
| 0x60 (`) | 0x60 | 0x16 (0x16) | |
| 0x7B ({) | 0x7B | 0x1B (0x1B) | |
| 0x7C (|) | 0x7C | 0x1C (0x1C) | |
| 0x7D (}) | 0x7D | 0x1D (0x1D) | |
| 0x7E (~) | 0x7E | 0x0F (0x0F) | |

### Input conversion (16 differences)

Maps keyboard scan codes to application character codes.

| Position | Identity | Mapped to | Notes |
|----------|----------|-----------|-------|
| 0x01 (0x01) | 0x01 | 0x11 (0x11) | |
| 0x11 (0x11) | 0x11 | 0x01 (0x01) | |
| 0x17 (0x17) | 0x17 | 0x1A (0x1A) | |
| 0x1A (0x1A) | 0x1A | 0x17 (0x17) | |
| 0x41 (A) | 0x41 | 0x51 (Q) | |
| 0x4D (M) | 0x4D | 0x5B ([) | |
| 0x51 (Q) | 0x51 | 0x41 (A) | |
| 0x57 (W) | 0x57 | 0x5A (Z) | |
| 0x5A (Z) | 0x5A | 0x57 (W) | |
| 0x5B ([) | 0x5B | 0x4D (M) | |
| 0x61 (a) | 0x61 | 0x71 (q) | |
| 0x6D (m) | 0x6D | 0x7B ({) | |
| 0x71 (q) | 0x71 | 0x61 (a) | |
| 0x77 (w) | 0x77 | 0x7A (z) | |
| 0x7A (z) | 0x7A | 0x77 (w) | |
| 0x7B ({) | 0x7B | 0x6D (m) | |

### Semigraphic map (95 differences)

Maps character codes to semigraphic ROM (ROA327) positions.
95 positions differ from identity (semigraphic ROM
has its own character layout). See `conversion_tables.bin` for raw data.

## 6. Library

### Output conversion (6 differences)

Maps application character codes to CRT ROM positions.

| Position | Identity | Mapped to | Notes |
|----------|----------|-----------|-------|
| 0x24 ($) | 0x24 | 0x04 (0x04) | |
| 0x3C (<) | 0x3C | 0x0B (0x0B) | |
| 0x3E (>) | 0x3E | 0x0D (0x0D) | |
| 0x40 (@) | 0x40 | 0x05 (0x05) | |
| 0x60 (`) | 0x60 | 0x16 (0x16) | |
| 0x7E (~) | 0x7E | 0x10 (0x10) | |

### Input conversion (15 differences)

Maps keyboard scan codes to application character codes.

| Position | Identity | Mapped to | Notes |
|----------|----------|-----------|-------|
| 0x2A (*) | 0x2A | 0x5E (^) | |
| 0x2B (+) | 0x2B | 0x7E (~) | |
| 0x2D (-) | 0x2D | 0x2B (+) | |
| 0x2F (/) | 0x2F | 0x2D (-) | |
| 0x3A (:) | 0x3A | 0x2A (*) | |
| 0x3B (;) | 0x3B | 0x2F (/) | |
| 0x3C (<) | 0x3C | 0x3B (;) | |
| 0x3D (=) | 0x3D | 0x3F (?) | |
| 0x3E (>) | 0x3E | 0x3A (:) | |
| 0x3F (?) | 0x3F | 0x5F (_) | |
| 0x40 (@) | 0x40 | 0x3C (<) | |
| 0x5E (^) | 0x5E | 0x40 (@) | |
| 0x5F (_) | 0x5F | 0x3D (=) | |
| 0x60 (`) | 0x60 | 0x3E (>) | |
| 0x7E (~) | 0x7E | 0x60 (`) | |

### Semigraphic map (105 differences)

Maps character codes to semigraphic ROM (ROA327) positions.
105 positions differ from identity (semigraphic ROM
has its own character layout). See `conversion_tables.bin` for raw data.

## Raw Table Data

Full hex dump of each table (384 bytes = 3 × 128).

### Danish

**Output** (+0x00):
```
  0000: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F  ................
  0010: 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F  ................
  0020: 20 21 22 23 24 25 26 27 28 29 2A 2B 2C 2D 2E 2F   !"#$%&'()*+,-./
  0030: 30 31 32 33 34 35 36 37 38 39 3A 3B 3C 3D 3E 3F  0123456789:;<=>?
  0040: 40 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F  @ABCDEFGHIJKLMNO
  0050: 50 51 52 53 54 55 56 57 58 59 5A 5B 5C 5D 5E 5F  PQRSTUVWXYZ[\]^_
  0060: 60 61 62 63 64 65 66 67 68 69 6A 6B 6C 6D 6E 6F  `abcdefghijklmno
  0070: 70 71 72 73 74 75 76 77 78 79 7A 7B 7C 7D 7E 7F  pqrstuvwxyz{|}~.
```

**Input** (+0x80):
```
  0080: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F  ................
  0090: 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F  ................
  00A0: 20 21 22 23 24 25 26 27 28 29 2A 2B 2C 2D 2E 2F   !"#$%&'()*+,-./
  00B0: 30 31 32 33 34 35 36 37 38 39 3A 3B 3C 3D 3E 3F  0123456789:;<=>?
  00C0: 40 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F  @ABCDEFGHIJKLMNO
  00D0: 50 51 52 53 54 55 56 57 58 59 5A 5B 5C 5D 5E 5F  PQRSTUVWXYZ[\]^_
  00E0: 60 61 62 63 64 65 66 67 68 69 6A 6B 6C 6D 6E 6F  `abcdefghijklmno
  00F0: 70 71 72 73 74 75 76 77 78 79 7A 7B 7C 7D 7E 7F  pqrstuvwxyz{|}~.
```

**Semigraphic** (+0x100):
```
  0100: 80 01 82 03 04 05 86 87 08 09 0A 0B 0C 0D 0E 8F  ................
  0110: 10 91 92 93 14 15 96 97 18 19 1A 1B 1C 9D 1E 9F  ................
  0120: 20 31 32 33 34 35 36 37 38 39 AA 30 2D AD 2E 8B   123456789.0-...
  0130: 30 31 32 33 34 35 36 37 38 39 BA 30 2D BD 2E 83  0123456789.0-...
  0140: 12 86 C2 C3 C4 05 82 C7 08 C9 0A 84 85 CD CE CF  ................
  0150: 81 D1 87 D3 D4 D5 80 D7 18 D9 1A DB DC DD DE 30  ...............0
  0160: E0 8E E2 E3 E4 E5 8A E7 E8 E9 EA 8C 8D ED EE EF  ................
  0170: 89 F1 8F F3 F4 F5 88 F7 F8 F9 FA FB FC FD FE 7F  ................
```

### Swedish

**Output** (+0x00):
```
  0000: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F  ................
  0010: 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F  ................
  0020: 20 21 22 23 24 25 26 27 28 29 2A 2B 2C 2D 2E 2F   !"#$%&'()*+,-./
  0030: 30 31 32 33 34 35 36 37 38 39 3A 3B 3C 3D 3E 3F  0123456789:;<=>?
  0040: 0A 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F  .ABCDEFGHIJKLMNO
  0050: 50 51 52 53 54 55 56 57 58 59 5A 06 0E 5D 00 5F  PQRSTUVWXYZ..]._
  0060: 1A 61 62 63 64 65 66 67 68 69 6A 6B 6C 6D 6E 6F  .abcdefghijklmno
  0070: 70 71 72 73 74 75 76 77 78 79 7A 60 7E 7D 40 7F  pqrstuvwxyz`~}@.
```

**Input** (+0x80):
```
  0080: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F  ................
  0090: 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F  ................
  00A0: 20 21 22 23 24 25 26 2F 28 29 2A 5E 2C 2B 2E 2D   !"#$%&/()*^,+.-
  00B0: 30 31 32 33 34 35 36 37 38 39 27 7E 3B 3F 3A 5F  0123456789'~;?:_
  00C0: 3C 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F  <ABCDEFGHIJKLMNO
  00D0: 50 51 52 53 54 55 56 57 58 59 5A 5C 5B 5D 60 3D  PQRSTUVWXYZ\[]`=
  00E0: 3E 61 62 63 64 65 66 67 68 69 6A 6B 6C 6D 6E 6F  >abcdefghijklmno
  00F0: 70 71 72 73 74 75 76 77 78 79 7A 7C 7B 7D 40 7F  pqrstuvwxyz|{}@.
```

**Semigraphic** (+0x100):
```
  0100: 80 01 82 03 04 05 86 87 08 09 0A 0B 0C 0D 0E 8F  ................
  0110: 10 91 92 93 14 15 96 97 18 19 1A 1B 1C 9D 1E 9F  ................
  0120: 20 31 32 33 34 35 36 37 38 39 AA 30 2D AD 2E 8B   123456789.0-...
  0130: 30 31 32 33 34 35 36 37 38 39 BA 30 2D BD 2E 83  0123456789.0-...
  0140: 12 86 C2 C3 C4 05 82 C7 08 C9 0A 84 85 CD CE CF  ................
  0150: 81 D1 87 D3 D4 D5 80 D7 18 D9 1A DB DC DD DE 30  ...............0
  0160: E0 8E E2 E3 E4 E5 8A E7 E8 E9 EA 8C 8D ED EE EF  ................
  0170: 89 F1 8F F3 F4 F5 88 F7 F8 F9 FA FB FC FD FE 7F  ................
```

### German

**Output** (+0x00):
```
  0000: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F  ................
  0010: 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F  ................
  0020: 20 21 22 23 24 25 26 27 28 29 2A 2B 2C 2D 2E 2F   !"#$%&'()*+,-./
  0030: 30 31 32 33 34 35 36 37 38 39 3A 3B 3C 3D 3E 3F  0123456789:;<=>?
  0040: 13 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F  .ABCDEFGHIJKLMNO
  0050: 50 51 52 53 54 55 56 57 58 59 5A 06 0E 00 5E 5F  PQRSTUVWXYZ...^_
  0060: 16 61 62 63 64 65 66 67 68 69 6A 6B 6C 6D 6E 6F  .abcdefghijklmno
  0070: 70 71 72 73 74 75 76 77 78 79 7A 60 7E 40 11 7F  pqrstuvwxyz`~@..
```

**Input** (+0x80):
```
  0080: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F  ................
  0090: 10 11 12 13 14 15 16 17 18 1A 19 1B 1C 1D 1E 1F  ................
  00A0: 20 21 22 40 24 25 26 2F 28 29 5E 2A 2C 7E 2E 2D   !"@$%&/()^*,~.-
  00B0: 30 31 32 33 34 35 36 37 38 39 23 2B 3B 3F 3A 5F  0123456789#+;?:_
  00C0: 3C 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F  <ABCDEFGHIJKLMNO
  00D0: 50 51 52 53 54 55 56 57 58 5A 59 5C 5B 5D 27 3D  PQRSTUVWXZY\[]'=
  00E0: 3E 61 62 63 64 65 66 67 68 69 6A 6B 6C 6D 6E 6F  >abcdefghijklmno
  00F0: 70 71 72 73 74 75 76 77 78 7A 79 7C 7B 7D 60 7F  pqrstuvwxzy|{}`.
```

**Semigraphic** (+0x100):
```
  0100: 80 01 82 03 04 05 86 87 08 09 0A 0B 0C 0D 0E 8F  ................
  0110: 10 91 92 93 14 15 96 97 18 19 1A 1B 9C 9D 1E 9F  ................
  0120: 20 31 32 33 34 35 36 37 38 39 AA 30 2D AD 2E 8B   123456789.0-...
  0130: 30 31 32 33 34 35 36 37 38 39 BA 30 2D BD 2E 83  0123456789.0-...
  0140: 12 86 C2 C3 C4 05 82 C7 08 C9 0A 84 85 CD CE CF  ................
  0150: 81 D1 87 D3 D4 D5 80 D7 18 D9 1A DB DC DD DE 30  ...............0
  0160: E0 8E E2 E3 E4 E5 8A E7 E8 E9 EA 8C 8D ED EE EF  ................
  0170: 89 F1 8F F3 F4 F5 88 F7 F8 F9 FA FB FC FD FE 7F  ................
```

### UK_ASCII

**Output** (+0x00):
```
  0000: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F  ................
  0010: 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F  ................
  0020: 20 21 22 03 24 25 26 27 28 29 2A 2B 2C 2D 2E 2F   !".$%&'()*+,-./
  0030: 30 31 32 33 34 35 36 37 38 39 3A 3B 3C 3D 3E 3F  0123456789:;<=>?
  0040: 05 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F  .ABCDEFGHIJKLMNO
  0050: 50 51 52 53 54 55 56 57 58 59 5A 0B 0C 0D 5E 5F  PQRSTUVWXYZ...^_
  0060: 16 61 62 63 64 65 66 67 68 69 6A 6B 6C 6D 6E 6F  .abcdefghijklmno
  0070: 70 71 72 73 74 75 76 77 78 79 7A 1B 1C 1D 0F 7F  pqrstuvwxyz.....
```

**Input** (+0x80):
```
  0080: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F  ................
  0090: 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F  ................
  00A0: 20 21 22 23 24 25 26 27 28 29 2A 2B 2C 2D 2E 2F   !"#$%&'()*+,-./
  00B0: 30 31 32 33 34 35 36 37 38 39 3A 3B 3C 3D 3E 3F  0123456789:;<=>?
  00C0: 40 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F  @ABCDEFGHIJKLMNO
  00D0: 50 51 52 53 54 55 56 57 58 59 5A 5B 5C 5D 5E 5F  PQRSTUVWXYZ[\]^_
  00E0: 60 61 62 63 64 65 66 67 68 69 6A 6B 6C 6D 6E 6F  `abcdefghijklmno
  00F0: 70 71 72 73 74 75 76 77 78 79 7A 7B 7C 7D 7E 7F  pqrstuvwxyz{|}~.
```

**Semigraphic** (+0x100):
```
  0100: 80 01 82 03 04 05 86 87 08 09 0A 0B 0C 0D 0E 8F  ................
  0110: 10 91 92 93 14 15 96 97 18 19 1A 1B 1C 9D 1D 9F  ................
  0120: 20 31 32 33 34 35 36 37 38 39 AA 30 2D AD 2E 8B   123456789.0-...
  0130: 30 31 32 33 34 35 36 37 38 39 BA 30 2D BD 2E 83  0123456789.0-...
  0140: 12 86 C2 C3 C4 05 82 C7 08 C9 0A 84 85 CD CE CF  ................
  0150: 81 D1 87 D3 D4 D5 80 D7 18 D9 1A DB DC DD DE 30  ...............0
  0160: E0 8E E2 E3 E4 E5 8A E7 E8 E9 EA 8C 8D ED EE EF  ................
  0170: 89 F1 8F F3 F4 F5 88 F7 F8 F9 FA FB FC FD FE 7F  ................
```

### US_ASCII

**Output** (+0x00):
```
  0000: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F  ................
  0010: 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F  ................
  0020: 20 21 22 23 24 25 26 27 28 29 2A 2B 2C 2D 2E 2F   !"#$%&'()*+,-./
  0030: 30 31 32 33 34 35 36 37 38 39 3A 3B 3C 3D 3E 3F  0123456789:;<=>?
  0040: 05 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F  .ABCDEFGHIJKLMNO
  0050: 50 51 52 53 54 55 56 57 58 59 5A 0B 0C 0D 5E 5F  PQRSTUVWXYZ...^_
  0060: 16 61 62 63 64 65 66 67 68 69 6A 6B 6C 6D 6E 6F  .abcdefghijklmno
  0070: 70 71 72 73 74 75 76 77 78 79 7A 1B 1C 1D 0F 7F  pqrstuvwxyz.....
```

**Input** (+0x80):
```
  0080: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F  ................
  0090: 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F  ................
  00A0: 20 21 22 23 24 25 26 27 28 29 2A 2B 2C 2D 2E 2F   !"#$%&'()*+,-./
  00B0: 30 31 32 33 34 35 36 37 38 39 3A 3B 3C 3D 3E 3F  0123456789:;<=>?
  00C0: 40 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F  @ABCDEFGHIJKLMNO
  00D0: 50 51 52 53 54 55 56 57 58 59 5A 5B 5C 5D 5E 5F  PQRSTUVWXYZ[\]^_
  00E0: 60 61 62 63 64 65 66 67 68 69 6A 6B 6C 6D 6E 6F  `abcdefghijklmno
  00F0: 70 71 72 73 74 75 76 77 78 79 7A 7B 7C 7D 7E 7F  pqrstuvwxyz{|}~.
```

**Semigraphic** (+0x100):
```
  0100: 80 01 82 03 04 05 86 87 08 09 0A 0B 0C 0D 0E 8F  ................
  0110: 10 91 92 93 14 15 96 97 18 19 1A 1B 1C 9D 1E 9F  ................
  0120: 20 31 32 33 34 35 36 37 38 39 AA 30 2D AD 2E 8B   123456789.0-...
  0130: 30 31 32 33 34 35 36 37 38 39 BA 30 2D BD 2E 83  0123456789.0-...
  0140: 12 86 C2 C3 C4 05 82 C7 08 09 0A 84 85 CD CE CF  ................
  0150: 81 D1 87 D3 D4 D5 80 D7 18 D9 1A DB DC DD DE 30  ...............0
  0160: E0 8E E2 E3 E4 E5 8A E7 E8 E9 EA 8C 8D ED EE EF  ................
  0170: 89 F1 8F F3 F4 F5 88 F7 F8 F9 FA FB FC FD FE 7F  ................
```

### French

**Output** (+0x00):
```
  0000: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F  ................
  0010: 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F  ................
  0020: 20 21 22 23 24 25 26 27 28 29 2A 2B 2C 2D 2E 2F   !"#$%&'()*+,-./
  0030: 30 31 32 33 34 35 36 37 38 39 3A 3B 3C 3D 3E 3F  0123456789:;<=>?
  0040: 05 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F  .ABCDEFGHIJKLMNO
  0050: 50 51 52 53 54 55 56 57 58 59 5A 0B 0C 0D 5E 5F  PQRSTUVWXYZ...^_
  0060: 16 61 62 63 64 65 66 67 68 69 6A 6B 6C 6D 6E 6F  .abcdefghijklmno
  0070: 70 71 72 73 74 75 76 77 78 79 7A 1B 1C 1D 0F 7F  pqrstuvwxyz.....
```

**Input** (+0x80):
```
  0080: 00 11 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F  ................
  0090: 10 01 12 13 14 15 16 1A 18 19 17 1B 1C 1D 1E 1F  ................
  00A0: 20 21 22 23 24 25 26 27 28 29 2A 2B 2C 2D 2E 2F   !"#$%&'()*+,-./
  00B0: 30 31 32 33 34 35 36 37 38 39 3A 3B 3C 3D 3E 3F  0123456789:;<=>?
  00C0: 40 51 42 43 44 45 46 47 48 49 4A 4B 4C 5B 4E 4F  @QBCDEFGHIJKL[NO
  00D0: 50 41 52 53 54 55 56 5A 58 59 57 4D 5C 5D 5E 5F  PARSTUVZXYWM\]^_
  00E0: 60 71 62 63 64 65 66 67 68 69 6A 6B 6C 7B 6E 6F  `qbcdefghijkl{no
  00F0: 70 61 72 73 74 75 76 7A 78 79 77 6D 7C 7D 7E 7F  parstuvzxywm|}~.
```

**Semigraphic** (+0x100):
```
  0100: 80 01 82 03 04 05 86 87 08 09 0A 0B 0C 0D 0E 8F  ................
  0110: 10 91 92 93 14 15 96 97 18 19 1A 1B 1C 9D 1E 9F  ................
  0120: 20 31 32 33 34 35 36 37 38 39 AA 30 2D AD 2E 8B   123456789.0-...
  0130: 30 31 32 33 34 35 36 37 38 39 BA 30 2D BD 2E 83  0123456789.0-...
  0140: 12 86 C2 C3 C4 05 82 C7 08 C9 0A 84 85 CD CE CF  ................
  0150: 81 D1 87 D3 D4 D5 80 D7 18 D9 1A DB DC DD DE 30  ...............0
  0160: E0 8E E2 E3 E4 E5 8A E7 E8 E9 EA 8C 8D ED EE EF  ................
  0170: 89 F1 8F F3 F4 F5 88 F7 F8 F9 FA FB FC FD FE 7F  ................
```

### Library

**Output** (+0x00):
```
  0000: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F  ................
  0010: 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F  ................
  0020: 20 21 22 23 04 25 26 27 28 29 2A 2B 2C 2D 2E 2F   !"#.%&'()*+,-./
  0030: 30 31 32 33 34 35 36 37 38 39 3A 3B 0B 3D 0D 3F  0123456789:;.=.?
  0040: 05 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F  .ABCDEFGHIJKLMNO
  0050: 50 51 52 53 54 55 56 57 58 59 5A 5B 5C 5D 5E 5F  PQRSTUVWXYZ[\]^_
  0060: 16 61 62 63 64 65 66 67 68 69 6A 6B 6C 6D 6E 6F  .abcdefghijklmno
  0070: 70 71 72 73 74 75 76 77 78 79 7A 7B 7C 7D 10 7F  pqrstuvwxyz{|}..
```

**Input** (+0x80):
```
  0080: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F  ................
  0090: 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F  ................
  00A0: 20 21 22 23 24 25 26 27 28 29 5E 7E 2C 2B 2E 2D   !"#$%&'()^~,+.-
  00B0: 30 31 32 33 34 35 36 37 38 39 2A 2F 3B 3F 3A 5F  0123456789*/;?:_
  00C0: 3C 41 42 43 44 45 46 47 48 49 4A 4B 4C 4D 4E 4F  <ABCDEFGHIJKLMNO
  00D0: 50 51 52 53 54 55 56 57 58 59 5A 5B 5C 5D 40 3D  PQRSTUVWXYZ[\]@=
  00E0: 3E 61 62 63 64 65 66 67 68 69 6A 6B 6C 6D 6E 6F  >abcdefghijklmno
  00F0: 70 71 72 73 74 75 76 77 78 79 7A 7B 7C 7D 60 7F  pqrstuvwxyz{|}`.
```

**Semigraphic** (+0x100):
```
  0100: 80 1D 82 0C 12 05 86 87 08 09 0A 15 0C 0D 13 8F  ................
  0110: 10 91 92 93 94 95 96 97 18 99 1A 1B 9C 9D 9E 9F  ................
  0120: 20 31 32 33 34 35 36 37 38 39 AA 30 2D AD 2E 8B   123456789.0-...
  0130: 30 31 32 33 34 35 36 37 38 39 BA 30 2D BD 2E 83  0123456789.0-...
  0140: C0 86 C2 C3 C4 C5 82 C7 C8 C9 CA 84 85 CD CE CF  ................
  0150: 81 D1 87 D3 D4 D5 80 D7 D8 D9 DA DB DC DD DE 30  ...............0
  0160: E0 8E E2 E3 E4 E5 8A E7 E8 E9 EA 8C 8D ED EE EF  ................
  0170: 89 F1 8F F3 F4 F5 88 F7 F8 F9 FA FB FC FD FE 7F  ................
```

