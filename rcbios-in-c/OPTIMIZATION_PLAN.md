# Optimization Plan: C Idioms and Compiler Exploitation

Three investigations into making the C BIOS generate better Z80 code:
accepting BC as a parameter, stack switching from C, and triggering
block instructions (LDIR, OTIR) from C source.

## 1. Accepting BC as a Function Parameter

### Problem

CP/M passes BIOS parameters in BC. sdcccall(1) accepts parameters in
A, HL, DE — never BC. Every BIOS entry that receives BC needs an asm
wrapper to move it into a sdcccall register.

### Findings

**No mechanism exists** in sdcc or z88dk to declare "this function
receives a parameter in BC". The register allocation is hardcoded in
the sdcc compiler source (not in the z88dk tree — z88dk patches sdcc
but doesn't change the parameter register set).

Available calling conventions:
- `sdcccall(1)`: A, HL, DE only
- `__z88dk_fastcall`: single param in HL (or L for 8-bit)
- `__z88dk_callee`: callee cleans stack, same registers as sdcccall
- `__naked`: no prologue/epilogue, full manual control

**Workaround options:**

a) **`__naked` + static variable** (current approach): asm stores BC
   to a static, C body reads the static. Cost: `ld (var),bc` (4 bytes)
   per entry point.

b) **`__naked` + inline asm preamble** (current approach for 8-bit):
   `ld a,c` then C body receives in A. Cost: 1 byte per entry.

c) **Custom sdcc patch**: Add BC to the sdcccall(1) register set.
   Would require modifying `src/z80/ralloc.c` in the sdcc source.
   The z88dk patches are at `z88dk/src/zsdcc/sdcc-*-z88dk.patch`.
   **High risk** — could break library ABI and register allocator
   assumptions. Not recommended without deep sdcc expertise.

### Affected functions (4)

| Function | Current asm | Pure C if BC were a param |
|---|---|---|
| `bios_settrk` | `ld (sektrk),bc; ret` | `{ sektrk = track; }` |
| `bios_setsec` | `ld (seksec),bc; ret` | `{ seksec = sector; }` |
| `bios_setdma` | `ld (dmaadr),bc; ret` | `{ dmaadr = addr; }` |
| `bios_sectran` | `ld h,b; ld l,c; ret` | `{ return sector; }` |

### Verdict

No clean solution within current z88dk/sdcc. The `__naked` wrappers
are the smallest possible bridge.

### Deep analysis of ralloc.c

The register allocator (`sdcc/src/z80/ralloc.c`, 1330 lines) **already
knows about BC**. The `z80_regs[]` table (line 102) lists all GPRs
including B and C as `REG_GPR`. ralloc.c is now mostly a front-end for
the modern allocator `z80_ralloc2_cc()` (in `ralloc2.cc`).

**The BC parameter restriction is NOT in ralloc.c.** It's in:
- `gen.c` — `genReceive()` maps incoming params to registers
- `SDCCsymt.c` — ABI tables define sdcccall(1) register assignments
- The z88dk patch (`sdcc-15248-z88dk.patch`) modifies `gen.c`/`main.c`

Adding BC as a 3rd parameter register would require:
1. Extending the ABI table in `SDCCsymt.c` to include BC positions
2. Modifying `genReceive()` in `gen.c` to load from BC
3. Modifying call-site code generation to place values in BC
4. Adding a z88dk patch entry (or a new `sdcccall(2)` variant)

The register allocator would handle BC for internal variable
allocation automatically — no changes needed in ralloc.c itself.

**Risk assessment**: Medium-high. The ABI change could break library
interoperability. A safer approach would be a new calling convention
attribute (`__z88dk_bccall` or similar) rather than modifying
sdcccall(1).

Not recommended for 4 trivial wrapper functions.

## 2. Stack Switching from C

### Problem

Five BIOS entries (conout, home, seldsk, read, write) must run on the
BIOS stack (0xF500) instead of the caller's stack. Each has a ~20-byte
asm wrapper that saves SP, switches, calls the C body, and restores.

### Findings

**No stack-switch library function exists** in z88dk. The z88dk
library has ISR helpers but no generic "call function on alternate
stack" facility.

**Workaround options:**

a) **Current approach**: Each function has its own asm wrapper that
   does the SP switch manually. ~100 bytes total for 5 functions.

b) **Shared asm trampoline**: Write a single `call_on_bios_stack`
   function in asm that takes a function pointer and calls it on the
   BIOS stack. Each BIOS entry becomes a thin wrapper that passes the
   C body address. Saves ~40-60 bytes by eliminating duplicated
   switch code, but adds call overhead.

   ```c
   /* In crt0.asm or hal.h */
   extern void call_on_bios_stack(void (*fn)(void));

   /* In bios.c */
   void bios_home(void) __naked {
       call_on_bios_stack(bios_home_c);
   }
   ```

   The trampoline in asm (~20 bytes, written once):
   ```asm
   _call_on_bios_stack:
       ; HL = function pointer (sdcccall 1st param)
       di
       push bc
       push de
       ex de, hl           ; DE = function
       ld hl, #0
       add hl, sp          ; HL = caller SP
       ld sp, #0xF500
       ei
       push hl             ; save caller SP on BIOS stack
       ex de, hl           ; HL = function
       call _call_hl       ; call via JP (HL)
       pop hl              ; caller SP
       di
       ld sp, hl
       pop de
       pop bc
       ei
       ret
   _call_hl:
       jp (hl)
   ```

c) **setjmp/longjmp trick**: Not applicable — these save/restore
   context but don't switch stacks cleanly.

d) **Compiler extension**: Would need a `__stack(addr)` attribute.
   Does not exist in sdcc or z88dk.

### Verdict

Option (b) — shared trampoline — is the best practical approach.
Reduces ~100 bytes of duplicated asm to ~25 bytes of trampoline +
5 × ~5 bytes of thin wrappers = ~50 bytes total. Net saving ~50 bytes
and each BIOS entry becomes a one-liner. The trampoline needs
variants for different register save sets and return value handling.

## 3. Generating LDIR, LDDR, OTIR from C

### Problem

The original asm BIOS uses OTIR to output SIO/CTC init blocks to
sequential ports. The C version uses `for` loops that compile to
individual `out` instructions. LDIR is used by memcpy but the
compiler doesn't generate it from hand-written loops.

### Findings

z88dk provides **three mechanisms** for block instructions:

### 3a. Library functions (simplest)

`#include <z80.h>` (path: `_DEVELOPMENT/sdcc/z80.h`)

```c
void *z80_otir(void *src, uint8_t port, uint8_t num);
void *z80_inir(void *dst, uint8_t port, uint8_t num);
```

These are thin wrappers around the Z80 OTIR/INIR instructions.
The `_callee` variants save a few bytes at call sites:

```c
#define z80_otir(a,b,c) z80_otir_callee(a,b,c)  /* auto-redirected */
```

**Usage for SIO init:**
```c
#include <z80.h>
z80_otir(psioa, 0x0A, sizeof(psioa));   /* → OTIR to port 0x0A */
z80_otir(psiob, 0x0B, sizeof(psiob));   /* → OTIR to port 0x0B */
```

**Caveat**: OTIR outputs B bytes from (HL) to port C, **incrementing
HL and decrementing B**. It writes to a **single port**. The CTC init
pattern writes to **sequential ports** (0x04, 0x05, 0x06, 0x07) — this
is NOT an OTIR pattern. OTIR only applies to SIO init (9 or 11 bytes
to the same port) and FDC SPECIFY (3 bytes to the same port).

### 3b. Compiler intrinsics (zero-overhead, compile-time constants)

`#include <intrinsic.h>`

```c
intrinsic_outi(src, port, num);
intrinsic_ini(dst, port, num);
```

**How it works**: The macro expands to three fake function calls:
```c
intrinsic_outi(psioa, 0x0A, 9);
/* expands to: */
{ intrinsic_outi(psioa);           /* → ld hl, psioa */
  intrinsic_outi_port_0x0A();      /* → ld c, #0x0A  */
  intrinsic_outi_num_9(); }        /* → call ____sdcc_outi-18 */
```

The peephole optimizer (in `sdcc_peeph.0`) recognizes these fake
calls and replaces them with inline Z80 instructions. Port and count
must be **compile-time constants** (they become part of the function
name via token pasting).

**Advantage**: Zero call overhead — the peephole optimizer replaces
the entire sequence with inline OTIR (or unrolled OUTI for small
counts). No library function call needed.

**Limitation**: Requires `-clib=sdcc_iy` or `-clib=sdcc_ix` to get
the peephole rules. The `--no-crt` build used here may not load them
automatically. Need to verify the peephole file is being used.

### 3c. memcpy/memset → LDIR (already working)

The z88dk `memcpy` implementation uses LDIR internally. The compiler
already emits `call _memcpy` for `memcpy()` calls, and the library
function executes LDIR. No source changes needed.

For **hand-written copy loops**, sdcc does **not** automatically
recognize the pattern and replace with LDIR. The loop:
```c
while (n--) *dst++ = *src++;
```
compiles to individual LD instructions, not LDIR. Use `memcpy()`
explicitly to get LDIR.

For **backward copies** (overlapping regions), `memmove()` should use
LDDR but the z88dk implementation may not work correctly in all cases
(existing comment in bios.c says memmove hangs). The manual
`*dst-- = *src--` loop is the safe alternative.

### 3d. What C patterns trigger block instructions?

| C pattern | Generated code | Block instruction? |
|---|---|---|
| `memcpy(dst, src, n)` | `call _memcpy` → LDIR | **Yes** |
| `memset(dst, val, n)` | `call _memset` → LDIR | **Yes** |
| `while(n--) *d++ = *s++` | individual LD loop | **No** |
| `for(i=0;i<n;i++) port = arr[i]` | individual OUT loop | **No** |
| `z80_otir(src, port, n)` | `call _z80_otir` → OTIR | **Yes** |
| `intrinsic_outi(src, port, n)` | inline OTIR (peephole) | **Yes** |

## Action Items

### Immediate (low risk, high value)

1. **Replace SIO init loops with `z80_otir`**:
   ```c
   z80_otir(psioa, 0x0A, sizeof(psioa));  /* was: for loop */
   z80_otir(psiob, 0x0B, sizeof(psiob));
   ```
   Saves ~20 bytes (loop overhead → single OTIR) and is faster.

2. **Replace FDC SPECIFY loop** (if it exists as a loop) with
   `z80_otir` to the FDC data port.

3. **Verify `intrinsic_outi` works** with our build flags. If the
   peephole rules load correctly, switch from `z80_otir` to
   `intrinsic_outi` for zero call overhead.

### Medium term (moderate effort)

4. **Implement shared stack-switch trampoline** in crt0.asm. Convert
   5 BIOS wrappers to use it. Estimated saving: ~50 bytes of asm.

5. **Try `z80_otir` for CTC init** — but CTC uses 4 different ports,
   so OTIR doesn't apply. Keep the current approach or restructure
   as 4 × 2-byte OTIR calls (one per channel).

### Future (requires compiler work)

6. **Investigate sdcc patch for BC parameter**: Look at the sdcc
   patches in `z88dk/src/zsdcc/sdcc-*-z88dk.patch` to understand
   if adding BC is feasible. The register allocator changes would
   be in `src/z80/ralloc.c` and `src/z80/gen.c` in the sdcc source.

## References

- z88dk z80 library headers: `z88dk/include/_DEVELOPMENT/sdcc/z80.h`
- Intrinsics header: `z88dk/include/intrinsic.h`
- Peephole rules (OTIR): `z88dk/libsrc/_DEVELOPMENT/sdcc_peeph.0`
- OTIR library impl: `z88dk/libsrc/_DEVELOPMENT/z80/z80/asm_z80_otir.asm`
- sdcc patches: `z88dk/src/zsdcc/sdcc-*-z88dk.patch`
- sdcc calling convention: `SDCCCALL.md` in this directory
