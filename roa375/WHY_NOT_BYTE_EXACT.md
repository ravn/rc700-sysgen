# Why roa375_new.asm is Not Byte-Exact

## Overview
The file `roa375_new.asm` was an attempt to convert more of the DB byte statements into readable Z80 assembly instructions. While it provides much better readability and structure, it fails to assemble to a byte-exact match with the original ROM for several reasons.

## Specific Issues

### 1. **Phase Error in Boot Code (Line 30)**

**Error:**
```
Phase error - $0010 changed from $00 to $13
JP	Z,FOUND
```

**Cause:**
The label structure in the boot section doesn't match the original. In the ROM:
- Address 0x000F: `JP Z,0x0013` (3 bytes: C3 13 00)
- This jumps to address 0x0013

In roa375_new.asm, the labels `FOUND` and `SKIP` are used differently than in the working version, causing zmac to calculate different addresses during the two-pass assembly. On the first pass, zmac assumes a placeholder address for `FOUND`, but on the second pass when it knows the actual address, it's different, causing the phase error.

**Why This Matters:**
Phase errors mean the assembler couldn't resolve addresses consistently, which would produce incorrect jump/call targets.

### 2. **Invalid Label Syntax (Lines 1247, 1266)**

**Errors:**
```
Syntax error: FLPRST+9:
Syntax error: FLPRST+38:
```

**Cause:**
Labels like `FLPRST+9` use arithmetic notation that zmac doesn't support. These represent positions offset from a base label (9 bytes after FLPRST, 38 bytes after FLPRST).

**Original ROM Context:**
```asm
; At 0x77A9 (example address):
FLPRST:     ; Main routine entry
    LD  HL,08010H
    LD  B,007H
    ; ... (9 bytes of code)
FLPRST1:    ; What was attempted as "FLPRST+9"
    CALL FDCIN
    ; ... (29 more bytes)
FLPRST2:    ; What was attempted as "FLPRST+38"
    IN  A,(0F8H)
```

**Fix Required:**
These need unique label names like `FLPRST1`, `FLPRST2`, etc., which requires careful analysis of the code flow to ensure they're placed at exactly the right byte positions.

### 3. **Undeclared Labels (Lines 447, 1130, 1191)**

**Errors:**
```
'FLDSK2' Undeclared
'DISKIO35' Undeclared  
'FDCWT2' Undeclared
```

**Cause:**
During conversion, I created labels for code sections but didn't define all the jump/call targets. The raw disassembly from z80dasm uses generic labels like `l7xxx`, but I tried to create meaningful names. However, I missed defining some of them or called them by the wrong name.

**Example:**
```asm
CALL FLDSK2    ; I created this call
; But never defined:
FLDSK2:
    LD  A,001H
    ; ...
```

### 4. **The Fundamental Problem: Address Sensitivity**

The core issue is that Z80 machine code is **position-sensitive**:

```
DB bytes version (working):
    db  0C3h,0DAh,73h    ; JP 073DAh - 3 bytes, encodes exact address

Instruction version (can fail):
    JP  ERRDSP           ; zmac must calculate where ERRDSP is
                         ; If ERRDSP is at wrong address, bytes differ
```

**Why DB Bytes Work:**
- DB statements encode the exact bytes from the ROM
- No address calculation needed - it's literal data
- Guaranteed byte-exact because we're directly specifying bytes

**Why Instructions Can Fail:**
- Every `JP`, `CALL`, `JR` instruction encodes a target address
- If a label is even 1 byte off from where it should be, the instruction encodes wrong
- One wrong label cascades - everything after it shifts

### 5. **Missing Data Bytes in Code**

The ROM contains data bytes embedded within code sections:

```asm
; At 0x716A - this is DATA, not code:
L716A:  DB  03h,71h      ; FDC command data

; But code references it:
    LD  HL,0716AH        ; Load address of data
    LD  B,(HL)           ; Get first byte (03h)
    INC HL
    ; ... uses second byte (71h)
```

If I mistakenly converted these data bytes to instructions (like thinking `03 71` is `INC BC` or something), the binary would be wrong.

## Size Discrepancy

When I attempted to assemble an earlier version:
- **Expected size:** 2048 bytes
- **Actual size:** 2052 bytes  
- **Difference:** +4 bytes

This suggests that some instructions assembled to longer forms than the original, likely due to:
- Using absolute addressing where relative addressing was intended
- Label placement errors causing different instruction encoding
- Extra padding or alignment issues

## Why the Working Version Succeeds

The current `roa375.asm` only converts ~100 bytes of the phase block:
- Error vectors (addresses known and fixed)
- Utility routines (self-contained, addresses calculable)
- Everything else stays as DB bytes

This hybrid approach provides:
- ✓ Byte-exact output (DB bytes are literal)
- ✓ Readable code for important sections
- ✓ Guaranteed assembly success

## To Make roa375_new.asm Byte-Exact

Would require:

1. **Fix all label definitions** - Every jump/call target must be defined
2. **Use correct label names** - Match the structure of the original
3. **Verify address placement** - Each label must be at exactly the right byte offset
4. **Identify all data sections** - Keep embedded data as DB bytes
5. **Test incrementally** - Convert small sections, verify byte-exact after each
6. **Handle special cases** - Self-modifying code, computed jumps, overlays

This is extremely time-consuming and error-prone, which is why the hybrid approach (partially converted) was chosen as the practical solution.

## Conclusion

`roa375_new.asm` serves as:
- **Reference documentation** - Shows what the code does in readable form
- **Learning tool** - Demonstrates Z80 instruction structure
- **Analysis aid** - Easier to understand logic flow

But `roa375.asm` is the **build source** because:
- **Byte-exact match** guaranteed
- **Reliable assembly** - no errors
- **Production ready** - suitable for burning to ROM

The trade-off is between readability (roa375_new.asm) and reliability (roa375.asm).
