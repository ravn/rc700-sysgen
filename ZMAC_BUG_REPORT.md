# zmac Assembler Bug Report

**Status**: RESOLVED - Not a bug, user error (wrong command-line flag)
**Solution**: Use `-z` flag for Z80 assembly, not `-8` flag
**Date**: 2026-02-08

## Summary

**RESOLVED**: This was not a zmac bug. The issue was using the wrong command-line flag.

The `-8` flag sets **8080 mode**, which doesn't support Z80-specific instructions like RETN. For Z80 assembly, use the `-z` flag instead.

### Original Issue

When using `zmac -8 --dri`, the assembler would either crash or report "Invalid 8080 instruction" errors when processing Z80-specific opcodes like `RETN` (ED 45).

**Root Cause**: The `-8` flag enables 8080 mode, which lacks ED-prefixed instructions. The disassembler in 8080 mode doesn't properly handle the ED prefix, leading to undefined behavior.

## Environment

- **Tool**: zmac (Z80 macro assembler)
- **Platform**: macOS (Darwin 25.2.0)
- **zmac Location**: `zmac/bin/zmac` (MacOS binary)
- **Discovery Date**: 2026-02-08
- **Discovered While**: Attempting to assemble z80dasm output of RC702 boot ROM

## Bug Description

When zmac processes Z80 assembly code where `RST 38H` immediately follows a `RETN` instruction, the assembler crashes with a segmentation fault instead of successfully assembling the code.

## Solution

**For Z80 assembly, use the `-z` flag:**
```bash
zmac -z --dri yourfile.asm  # Correct for Z80 code
```

**NOT the `-8` flag:**
```bash
zmac -8 --dri yourfile.asm  # WRONG - this is for 8080 mode!
```

## Original Reproduction (with wrong flag)

### Test Case

Create a file `test_crash.asm`:

```asm
	org 00000h
	di
	retn
	rst 38h
	end
```

Assemble with **wrong flag**:
```bash
zmac -8 --dri test_crash.asm
```

**Result**: "Invalid 8080 instruction" error (because RETN is Z80-only)

Assemble with **correct flag**:
```bash
zmac -z --dri test_crash.asm
```

**Result**: Exit code 0 (success)

### Expanded Test Case

From `roa375_raw.asm` lines 66-71:

```asm
	ld a,005h		;005e
	ld (08062h),a		;0060
	jp 07218h		;0063
	retn			;0066
l0068h:
	rst 38h			;0068
```

This also crashes zmac.

## Test Results

### Crashes (Exit 139)

1. **RETN followed by RST 38H**:
   ```asm
   retn
   rst 38h
   ```

2. **DI followed by RST 38H** (at certain positions):
   ```asm
   di
   rst 38h
   ```

3. **Any "problematic" instruction followed by RST 38H**:
   ```asm
   org 00000h
   di
   ld sp,0bfffh
   ; ... more code ...
   retn
   rst 38h
   ```

### Works Fine (Exit 0)

1. **RST 38H by itself**:
   ```asm
   .Z80
   org 00000h
   di
   rst 38h
   end
   ```

2. **Label with different name before RST 38H**:
   ```asm
   org 00000h
   OTHER:
   rst 38h
   end
   ```

3. **DB followed by RST 38H**:
   ```asm
   org 00000h
   di
   db 0FFH
   rst 38h
   end
   ```

4. **Other instructions before RST 38H** (in most cases):
   ```asm
   org 00000h
   ld a,05h
   rst 38h
   end
   ```

## Analysis

### Pattern

The crash appears to be related to:

1. **Specific instruction sequences** where certain instructions (particularly `RETN`) precede `RST 38H`
2. **Context-dependent**: The crash doesn't occur with all instruction/RST combinations
3. **Possibly related to**:
   - Internal assembler state after processing `RETN`
   - Code path for handling `RST` instructions when certain flags are set
   - Pointer/buffer handling in instruction encoding

### Hypothesis

The `RETN` instruction may leave zmac's internal state in a condition that causes a null pointer dereference or buffer overflow when processing the subsequent `RST 38H` instruction.

Alternative hypothesis: The issue may be related to how zmac handles:
- Address calculation after instructions that affect the program counter
- Two-pass assembly resolution when `RST` follows certain instructions
- Label resolution in specific contexts

## Workarounds

1. **Use DB bytes instead of RST instruction**:
   ```asm
   retn
   db 0FFH  ; RST 38H opcode
   ```

2. **Add padding between instructions**:
   ```asm
   retn
   nop
   rst 38h
   ```

3. **Use a label with different naming**:
   ```asm
   retn
   LABEL:
   rst 38h
   ```

## Files Affected

- **Original problem**: `roa375_raw.asm` (z80dasm output)
- **Workaround file**: `roa375_full_disasm.asm` (manually structured to avoid the bug)
- **Test files**: `/tmp/test_*.asm` (various minimal reproductions)

## Impact

- **Severity**: High - prevents assembly of valid Z80 code
- **Frequency**: Low - specific instruction sequence required
- **Workaround**: Available (restructure code or use DB bytes)

## Investigation Results (2026-02-08)

### Phase 1: Initial Fix Attempt
Attempted to fix by adding NULL checks in the RST instruction handler (zmac.y line 3022-3045):
- Added checks for NULL `$1` (RST token) and `$2` (expression)
- When `$1` is NULL, the error message "internal error: NULL RST token" is printed
- Even with NOP emission as fallback, zmac still crashes with segfault

**Initial Finding**: The RST token `$1` becomes NULL after processing RETN.

### Phase 2: Core Dump Analysis (lldb backtrace)

Used lldb to capture the crash backtrace:

```
* thread #1, stop reason = EXC_BAD_ACCESS (code=1, address=0x0)
  * frame #0: Zi80dis::Disassemble (NULL pointer dereference)
    frame #1: zi_tstates
    frame #2: get_tstates
    frame #3: emit (line 901: get_tstates(emitbuf, ...))
    frame #4: emit1
    frame #5: yyparse
```

**Key Discovery**: The crash is **NOT in the parser**, it's in the **disassembler** (`Zi80dis::Disassemble` in zi80dis.cpp).

**Actual Root Cause**:
1. After RETN is processed, the parser correctly emits the instruction
2. When RST is parsed, `$1` (the RST token) is NULL due to parser state corruption
3. The NULL check triggers and attempts to emit NOP: `emit(1, E_CODE, 0, 0)`
4. `emit()` calls `get_tstates(emitbuf, ...)` to calculate instruction timing
5. `get_tstates()` calls `zi_tstates()` which calls `Zi80dis::Disassemble()`
6. **The disassembler crashes** trying to read from a NULL or corrupted pointer

The bug has **two components**:
1. Parser state corruption causing `$1` to be NULL (parser bug)
2. Disassembler not handling corrupted input gracefully (disassembler bug)

## Suggested Fix Areas

Based on core dump analysis, there are multiple potential fixes:

### Option 1: Fix the Disassembler (Defensive)
**File**: `zi80dis.cpp` - Add NULL pointer checks in `Zi80dis::Disassemble()`
- **Pros**: Prevents crashes from any corrupted input, not just this bug
- **Cons**: Doesn't fix the underlying parser issue
- **Difficulty**: Easy
- **Impact**: Would prevent the segfault but not fix why $1 is NULL

### Option 2: Skip get_tstates When in Error State (Workaround)
**File**: `zmac.y` line 901 in `emit()` function
- Before calling `get_tstates(emitbuf, ...)`, check if we're in an error state
- Skip timing calculation if error flags are set
- **Pros**: Simple fix in one location
- **Cons**: Masks the underlying parser bug
- **Difficulty**: Easy

### Option 3: Fix Parser State Management (Root Cause)
**File**: `zmac.y` + generated parser code
- Investigate why NOOPERAND instructions corrupt the symbol stack
- Line 2986: NOOPERAND handler calls `emit1($1->i_value, 0, 0, ET_NOARG);`
- Check if symbol stack pop/push operations are balanced
- Verify that all grammar actions properly manage semantic values
- **Pros**: Fixes root cause
- **Cons**: Very complex, requires deep bison/yacc knowledge
- **Difficulty**: Hard

### Option 4: Workaround in Assembly Source (Recommended)
**No code changes needed**:
- Use DB bytes: `db 0EDH, 045H ; RETN` instead of `retn`
- Add padding: insert `nop` between `retn` and `rst 38h`
- Restructure code to avoid this specific sequence
- **Pros**: Works immediately, no zmac changes needed
- **Cons**: Requires manual source code changes
- **Difficulty**: Trivial

## Additional Notes

- The z80dasm tool generates syntactically valid Z80 assembly
- The instruction sequence `RETN` followed by `RST 38H` is valid Z80 machine code
- Other Z80 assemblers (e.g., TASM, ZASM) may not have this bug
- The bug prevents automatic assembly of z80dasm output without manual intervention

## Core Dump Analysis Commands

To reproduce the analysis with lldb:

```bash
# Create test file
cat > /tmp/test_retn_rst.asm << 'EOF'
	org 00000h
	di
	retn
	rst 38h
	end
EOF

# Run in debugger and get backtrace
lldb -b \
  -o "run -8 --dri /tmp/test_retn_rst.asm" \
  -o "bt all" \
  -o "quit" \
  /path/to/zmac
```

Output shows crash at:
- **Address**: 0x0 (NULL pointer dereference)
- **Instruction**: `ldrsb w8, [x8]` where x8 = 0
- **Function**: `Zi80dis::Disassemble()` in zi80dis.cpp
- **Called from**: `get_tstates()` at zmac.y line 901

## Test Script

```bash
#!/bin/bash
# Test zmac crash bug

echo "Test 1: RETN followed by RST 38H"
cat > /tmp/test1.asm << 'EOF'
	org 00000h
	retn
	rst 38h
	end
EOF
zmac -8 --dri /tmp/test1.asm 2>&1
echo "Exit code: $?"
echo ""

echo "Test 2: DB followed by RST 38H (should work)"
cat > /tmp/test2.asm << 'EOF'
	org 00000h
	db 0FFH
	rst 38h
	end
EOF
zmac -8 --dri /tmp/test2.asm 2>&1
echo "Exit code: $?"
echo ""

echo "Test 3: Label before RST 38H (should work)"
cat > /tmp/test3.asm << 'EOF'
	org 00000h
OTHER:
	rst 38h
	end
EOF
zmac -8 --dri /tmp/test3.asm 2>&1
echo "Exit code: $?"
```

## Debugging Process (2026-02-08)

During investigation, the following was discovered:

1. **Initial assumption**: The crash was caused by a parser bug when processing `RETN` followed by `RST 38H`
2. **First discovery**: Using `-8` flag, zmac was running in 8080 mode (not Z80 mode)
3. **Root cause identified**: In 8080 mode, the disassembler doesn't recognize ED-prefixed instructions
   - z_major[0xED] has name=NULL and args=2
   - In 8080 mode (`m_processor=0`), the code doesn't update `code` pointer to point to z_minor[2][0x45]
   - This leaves `code->name` as NULL, causing undefined behavior
4. **Solution confirmed**: Using `-z` flag sets m_processor=1 (Z80 mode), which correctly processes ED opcodes

### Flag Reference

- **`-8`**: Use 8080 timings and interpretation of mnemonics (8080 mode)
- **`-z`**: Use Z-80 timings and interpretation of mnemonics (Z80 mode)

For Z80 code (RC700, RC702, etc.), always use `-z` flag.

## References

- **zmac source repository**: https://github.com/pulkomandy/zmac (or other fork)
- **Related files**:
  - `roa375_raw.asm` - Original z80dasm output
  - `roa375_full_disasm.asm` - Working disassembly
  - `ZMAC_BUG_REPORT.md` - This document
- **zmac help**: Run `zmac --help` to see all command-line options
