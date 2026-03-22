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

## Why not patch the backend?

Adding a `__attribute__((z80_regcall))` to the clang frontend that maps
to CC 103 would be the proper fix.  This requires:

1. Add a new `CC_Z80_RegCall` entry in `Z80CallingConv.td` (or reuse
   `CC_Z80_LC`)
2. Register the attribute in clang's `TargetInfo` for the Z80 target
3. Map the attribute to the CC ID in `CodeGenTypes`

This is approximately 50-100 lines of C++ across 3-4 files.  However,
with the backend stalled and no upstream maintainer responding to
issues, a fork would be required.

## Source references

- [Z80CallingConv.td](https://github.com/jacobly0/llvm-project/blob/z80/llvm/lib/Target/Z80/Z80CallingConv.td) — CC definitions
- [Z80ISelLowering.cpp](https://github.com/jacobly0/llvm-project/blob/z80/llvm/lib/Target/Z80/Z80ISelLowering.cpp) — CC selection
- [Issue #43](https://github.com/jacobly0/llvm-project/issues/43) — unanswered question about calling convention
- Last commit on z80 branch: 2023-12-13
