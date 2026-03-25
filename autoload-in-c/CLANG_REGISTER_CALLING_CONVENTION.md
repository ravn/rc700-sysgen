# Clang Z80 Backend: Register Calling Convention Workaround

Investigated 2026-03-22. The ez80-clang Z80 backend has a fully functional
register-passing calling convention (`CC_Z80_LC`, LLVM CC ID 103) but it is
only used for internal runtime library calls, not user-defined functions.

This document describes a workaround to enable register parameter passing
for user code by post-processing the LLVM IR.

## Background

The Z80 LLVM backend (jacobly0/llvm-project) defines two calling conventions
for 16-bit Z80 mode in `Z80CallingConv.td`:

- **`CC_Z80_C`** (default): ALL parameters on stack.  Every function sets up
  an IX or IY frame pointer and reads parameters via `(ix+N)`.

- **`CC_Z80_LC`** (ID 103): Parameters in registers.  First i8 values in L
  and C, first i16 values in HL and BC, pointers in HL.  Remaining parameters
  spill to stack.

The default CC is hardcoded for all user functions.  CC 103 is only applied
to compiler-generated runtime library calls (multiply, divide, shift helpers).
No C-level attribute exists to select CC 103 for user functions — `regcall`,
`fastcall`, `preserve_most` are all rejected with "not supported for this
target."

## The workaround

### Pipeline

```
C source
  → ez80-clang -emit-llvm -S     (compile to LLVM IR text)
  → sed 's/define/define cc 103/' (inject register CC)
  → ez80-clang -cc1 -S           (compile IR to Z80 assembly)
  → z88dk-copt clang_rules.1     (fix section syntax, labels)
  → z88dk-z80asm                  (assemble)
```

### Step 1: Compile C to LLVM IR

```sh
ez80-clang --target=z80 -fno-signed-char -O2 -emit-llvm -S \
    -isystem "$Z88DK/include/_DEVELOPMENT/clang" \
    -o output.ll input.c
```

This produces LLVM IR with default calling convention:
```llvm
define dso_local i8 @add(i8 noundef %0, i8 noundef %1) {
  %3 = add i8 %1, %0
  ret i8 %3
}
```

### Step 2: Inject CC 103

Replace `define` with `define cc 103` on function definitions, and
`call` with `call cc 103` on call sites:

```sh
sed -e 's/define dso_local/define cc 103/g' \
    -e 's/call i8 @/call cc 103 i8 @/g' \
    -e 's/call i16 @/call cc 103 i16 @/g' \
    -e 's/call i32 @/call cc 103 i32 @/g' \
    -e 's/call void @/call cc 103 void @/g' \
    output.ll > output_cc103.ll
```

Note: `dso_local` must be removed (CC number and `dso_local` can't coexist
in this LLVM version's IR parser).

Functions that must keep the default CC (e.g., `main`, or functions called
from sdcc-compiled code) should be excluded from the sed replacement.

### Step 3: Compile IR to Z80 assembly

```sh
ez80-clang -cc1 -triple z80 -S -O2 -o output.s output_cc103.ll
```

### Steps 4-5: Fix syntax and assemble

Apply z88dk's `clang_rules.1` peephole rules and assemble normally.

## Register allocation: CC 103 (Z80_LibCall)

### Parameter passing

| Parameter type | 1st param | 2nd param | 3rd+ |
|---------------|-----------|-----------|------|
| i8 (uint8_t)  | **L**     | **C**     | stack |
| i16 (uint16_t)| **HL**    | **BC**    | stack |
| i32 (uint32_t)| **DEHL**  | —         | stack |
| ptr           | **HL**    | **BC**    | stack |

Mixed parameter types are also supported.  For example,
`mixed(uint8_t a, uint16_t b, uint8_t c)` passes a in L, b in DE, c in C
— all three in registers, no stack access at all.

### Return values

| Return type   | Register |
|--------------|----------|
| i8 (uint8_t) | **A**    |
| i16 (uint16_t)| **HL**  |
| i32 (uint32_t)| **DEHL** |
| ptr           | **HL**  |

Note: CC 103 appears to push/pop the return register as part of the
callee-save protocol.  This adds 2 bytes per function but may be an
artifact of the LibCall convention's expectations.

### Code size comparison (from clang_calling_test.c)

| Function | Default CC (bytes) | CC 103 (bytes) | sdcccall(1) (bytes) |
|----------|--------------------|----------------|---------------------|
| pass1_u8(u8) | 14 | 5 | 2 |
| pass2_u8(u8,u8) | 18 | 5 | 2 |
| pass_ptr(ptr) | 19 | 2 | 2 |
| read_ptr(ptr) | 18 | 3 | 2 |
| mixed(u8,u16,u8) | 29 | ~20 | ~10 |
| pass3_u8(u8,u8,u8) | 21 | 10 | ~14 |
| pass7_u8(7×u8) | 30 | 18 | ~22 |

CC 103 is dramatically better than the default CC for 1-2 parameter
functions (the most common case).  For 3+ parameters, some spill to
stack.  sdcccall(1) is still more compact due to simpler prologue
(no IX frame pointer push/pop).

## Limitations

1. **No C-level attribute**: There is no `__attribute__` to select CC 103
   from C source code.  The workaround requires LLVM IR post-processing.

2. **ABI incompatibility**: CC 103 functions cannot be called from sdcc
   or sccz80 compiled code (different register assignments).  All code in
   a binary must use the same CC, or explicit wrappers are needed at
   boundaries.

3. **Callee-save push/pop**: CC 103 generates push/pop of the return
   register, adding 2 bytes per function.  This appears to be part of
   the LibCall protocol and may not be eliminable without backend changes.

4. **sed fragility**: The `sed` replacement is textual and may break on
   complex IR (e.g., function pointers, indirect calls, varargs).

5. **Backend is stalled**: The jacobly0/llvm-project z80 branch has not
   been updated since 2023-12-13.  No improvements to the calling
   convention are expected upstream.

6. **`push a` / `pop a`**: CC 103 generates `push a` / `pop a` which are
   eZ80 instructions, not valid Z80.  Must be post-processed to `push af` /
   `pop af`.

7. **`delay()` eliminated**: LLVM's optimizer recognizes empty delay loops
   and removes them entirely (`ret` only).  Timing-critical delay functions
   need `volatile` or inline asm to survive optimization.

8. **Code size**: rom.c compiles to 4440 bytes with CC 103 (vs 1734 bytes
   with sdcc).  The 2.5× increase comes from callee-save push/pop overhead,
   less efficient register allocation for complex functions, and different
   instruction selection.  Too large for the PROM (4096 byte limit) but
   demonstrates the approach works.

## Full rom.c compilation test

Successfully compiled rom.c through the complete pipeline:

```
C → clang -emit-llvm → sed cc 103 → clang -cc1 -S → copt → z80asm
```

Result: 3972 bytes code, 130 bytes rodata, 35 bytes BSS.
67 IN + 119 OUT inline port I/O instructions (address_space(2) works).
Assembled with zero errors after `push a` → `push af` fixup.

delay() preserved via `__asm__ volatile("")` barrier (clang) /
`__asm__("")` (sdcc).  Inner loop timing differs between compilers
(clang: add a,1; jr nc ~20T vs sdcc: djnz ~13T) — delay arguments
need recalibration when switching compilers.

## Stack-indexed local analysis (ix-N spills)

Of 30 code functions, only 5 use IX/IY for stack-indexed locals:

| Function | Spills | Cause |
|----------|--------|-------|
| `main` | 3 | LLVM inlined 4 functions, too many live values |
| `fdc_select_drive_cylinder_head` | 2 | One value live across function call |
| `fdc_detect_sector_size_and_density` | 6 | Genuinely complex, many live values |
| `fdc_read_data_from_current_location` | 7+1 | Loop var + stack param |
| `lookup_sectors_and_gap3_for_current_track` | 2 | Array indexing |

Total: 26 spill accesses (~78 bytes overhead).  Two other functions
(`floppy_boot`, `syscall`) use IY only as a scratch register for
constants, not for stack indexing — this is fine.

Note: `{...}` scoping of locals does NOT help reduce spills with LLVM.
LLVM's SSA-based register allocator computes liveness from data flow,
not lexical scope.  A variable is dead after its last use regardless
of where the `}` is.

## Missing Z80-specific optimizations

The backend calls library functions for operations sdcc inlines:

| Operation | clang | sdcc | Optimal |
|-----------|-------|------|---------|
| `x << 1` | `call __sshl` | `add hl,hl` | 1 byte |
| `x << 2` | `call __sshl` | 2× `add hl,hl` | 2 bytes |
| `x * 3` | `call __smulu` | `add hl,hl; add hl,bc` | 3 bytes |
| `x * 5` | `call __smulu` | strength-reduce | 4 bytes |
| `x >> 1` | `call __sshru` | `srl h; rr l` | 4 bytes |
| `u8 * 3` | `call __bmulu` | `add a,a; add a,r` | 2 bytes |
| `x * 256` | `ld d,l; ld e,0` | same | **optimal** |
| `x / 256` | `ld e,h; ld d,0` | same | **optimal** |

Root cause: the Z80 backend registers ALL shifts and multiplies as
`RTLIB` library calls.  A DAG pattern for `(shl A16, (i8 1))` →
`ADD16aa` EXISTS in Z80InstrInfo.td but GlobalISel doesn't reach it
because the operation is lowered to a library call first.

## Potential backend patches (~200-300 lines C++)

1. **Shift by constant 1** → `add hl,hl` (~20 lines)
   Pattern exists but GlobalISel bypasses it.  Need GISelLegalizer rule.

2. **Shift by small constants 2-4** → N × `add hl,hl` (~30 lines)

3. **Multiply by small constants** → strength-reduce (~50-100 lines)
   ×2=shl, ×3=x+x+x, ×4=shl2, ×5=x*4+x, ×7=x*8-x, ×8=shl3, ×10=x*8+x*2

4. **Right shift by constant 1** → `srl h; rr l` (~20 lines)

5. **Remove CC 103 callee-save push/pop af** (~50 lines)
   Saves 2 bytes per function (27 functions = ~54 bytes)

6. **Add `__attribute__((z80_regcall))`** (~50-100 lines)
   Expose CC 103 from C without the sed workaround.

Estimated savings: ~500-800 bytes, bringing rom.c from 3972 to ~3200-3400.
Backend is stalled (last commit 2023-12-13), requires fork to patch.

## Source references

- [Z80CallingConv.td](https://github.com/jacobly0/llvm-project/blob/z80/llvm/lib/Target/Z80/Z80CallingConv.td) — CC definitions
- [Z80ISelLowering.cpp](https://github.com/jacobly0/llvm-project/blob/z80/llvm/lib/Target/Z80/Z80ISelLowering.cpp) — CC selection, libcall table
- [Z80InstrInfo.td](https://github.com/jacobly0/llvm-project/blob/z80/llvm/lib/Target/Z80/Z80InstrInfo.td) — instruction patterns (line 1013: shl→add pattern)
- [Issue #43](https://github.com/jacobly0/llvm-project/issues/43) — unanswered question about calling convention
- Last commit on z80 branch: 2023-12-13
