# TODO: Extend sdcccall register convention for CP/M BIOS ABI

## Goal

Extend z88dk's sdcccall(1) calling convention so that CP/M BIOS entry
points can be expressed directly in C, without `__naked` assembly shims.

### Current Problem

CP/M passes parameters and expects return values in specific registers
that don't match sdcccall(1):

| BIOS call | CP/M passes | sdcccall(1) expects | Current workaround |
|-----------|-------------|--------------------|--------------------|
| `SELDSK(C)` | drive in C | 8-bit param in A | `__naked` shim: `ld a,c` |
| `SETTRK(BC)` | track in BC | 16-bit param in HL | `__naked` shim: `ld (_sektrk),bc; ret` |
| `SETSEC(BC)` | sector in BC | 16-bit param in HL | `__naked` shim |
| `SETDMA(BC)` | address in BC | 16-bit param in HL | `__naked` shim |
| `SECTRAN(BC,DE)` | sec in BC, table in DE | HL, DE | `__naked` shim |
| `CONOUT(C)` | char in C | 8-bit param in A | `__naked` shim: `ld a,c` |
| `SELDSK` return | CP/M expects HL | sdcccall(1) returns DE (16-bit) | `__naked` shim: `ex de,hl; ret` |

Each shim is 3-5 bytes and obscures the C function signature.

### Desired Extension

Two features in zsdcc (the z88dk fork of sdcc):

1. **BC as parameter register**: Allow declaring that a function receives
   its first 16-bit parameter in BC (or first 8-bit parameter in C).
   This would let `bios_seldsk(byte drv)` receive `drv` directly in C
   register without a shim.

   Possible syntax (strawman):
   ```c
   word bios_seldsk(byte drv __reg("c"));
   word bios_settrk(word track __reg("bc"));
   ```

2. **Return value in specific register**: Allow declaring that a function
   returns its value in a specific register pair (e.g., HL instead of DE).
   CP/M expects SELDSK to return DPH pointer in HL.

   Possible syntax:
   ```c
   __returns("hl") word bios_seldsk(byte drv __reg("c"));
   ```

### Impact on C BIOS

If both features were available, most `__naked` BIOS entry shims could
become normal C functions.  The 13 shims in crt0.asm / bios.c that
exist solely for register bridging could be eliminated (~50-80 bytes
saved, cleaner code).

### Investigation Areas

- **zsdcc source**: z88dk's fork of sdcc, handles Z80 code generation.
  Key files: `src/z80/gen.c` (code generator), `src/z80/ralloc.c`
  (register allocator), `src/SDCCsymt.h` (symbol/type system).
- **sdcccall(1) implementation**: How are the current register assignments
  (A for 8-bit, HL for 16-bit first param, DE for second) implemented?
  Can they be overridden per-function or per-parameter?
- **`__z88dk_fastcall`**: Already passes single parameter in HL.  Could
  this be generalized to other registers?
- **ABI compatibility**: Any extension must not break existing sdcccall(1)
  code.  Per-function annotation (not global) is essential.
- **Callee-saved registers**: BC is callee-saved in sdcccall(1).  If BC
  is used for parameter passing, the function prologue must not save/
  restore BC before the parameter is consumed.

### Related Work

- sdcc `__naked` functions already bypass the calling convention entirely
- sdcc `__z88dk_fastcall` is a precedent for alternative calling conventions
- GCC/Clang have `__attribute__((regparm))` for x86 — similar concept
- The Z80 has so few registers that per-function ABI overrides may be
  more practical than a general-purpose extension

### Priority

Low — the current `__naked` shims work and are well-understood.  This is
an experiment to explore whether the toolchain can be extended to make
the BIOS code more idiomatic C.
