# How sdcc implements `__sfr __at` port I/O

## Summary

sdcc turns `__sfr __at 0x04 fdc_status;` into inline Z80 `IN A,(04h)` /
`OUT (04h),A` instructions — just 2 bytes each, with no function call
overhead. This is NOT a peephole optimization, NOT a macro expansion,
and NOT inline assembly. It is a first-class compiler feature where the
Z80 I/O port address space is treated as a distinct memory space at every
stage of compilation, from parsing through code generation.

The `__sfr` keyword tells sdcc: "this variable lives in the Z80's I/O
port address space, not in RAM." The compiler then knows that every read
of this variable must use an `IN` instruction (not `LD`) and every write
must use an `OUT` instruction (not `LD`). The `__at N` part fixes the
variable to a specific port address, just as `__at` can fix a regular
variable to a specific RAM address.

## Background: the Z80's two address spaces

The Z80 CPU has two completely separate address spaces:

1. **Memory space** (64KB) — accessed by `LD` instructions. This is where
   RAM, ROM, and memory-mapped devices live. A memory read is `LD A,(addr)`;
   a memory write is `LD (addr),A`.

2. **I/O port space** (256 ports in 8-bit mode, 65536 in 16-bit mode) —
   accessed by `IN` and `OUT` instructions. This is where hardware
   controllers (FDC, DMA, CTC, PIO, CRT) are reached. A port read is
   `IN A,(port)`; a port write is `OUT (port),A`.

These two address spaces are electrically separate. The Z80 asserts
different control signals (`MREQ` vs `IORQ`) to distinguish memory
accesses from I/O accesses. Writing `LD A,(04h)` reads memory address
0x04 (in RAM); writing `IN A,(04h)` reads I/O port 0x04 (the FDC status
register on our RC702). They are completely different operations even
though the address value is the same.

Standard C has no concept of separate address spaces — a pointer is a
pointer to memory. sdcc extends C with the `__sfr` storage class to
represent this second address space, allowing port I/O to be expressed
as simple variable reads and writes in C.

## How it works in C

```c
// Declare a port variable: "fdc_status is an 8-bit I/O port at address 0x04"
__sfr __at 0x04 fdc_status;

// Reading the port — compiles to: IN A,(04h)
uint8_t status = fdc_status;

// Writing to the port — compiles to: LD A,42h; OUT (05h),A
__sfr __at 0x05 fdc_data;
fdc_data = 0x42;
```

The C code looks like ordinary variable access. The compiler handles the
distinction between memory and I/O transparently. No inline assembly, no
macros, no function calls. The generated code is optimal — identical to
what a human would write in assembly.

## Compiler internals: the five-stage pipeline

```
C source                    __sfr __at 0x04 fdc_status;
  ↓ parser (SDCC.y)         SFR token → storage class S_SFR
  ↓ memory allocator        S_SFR → REGSP address space (sfr)
  ↓ iCode generator         operand tagged as IN_REGSP
  ↓ Z80 code generator      AOP_SFR → emit "in a,(N)" / "out (N),a"
  ↓ assembler               defc symbol resolved → 2-byte instruction
```

### Stage 1: Parsing (`src/SDCC.y`)

The sdcc parser recognizes `__sfr` as a storage class specifier, just
like `static`, `extern`, or `register`. It is not a type qualifier —
it is a storage class that says "this variable is in I/O port space."

The grammar rule in the yacc parser:

```c
sfr_attributes
  : SFR    {
              SPEC_SCLS($$) = S_SFR;    // storage class = SFR
           }
  | SFR BANKED {
              SPEC_SCLS($$) = S_SFR;
              SPEC_BANKED($$) = 1;       // 16-bit port address (see below)
           }
```

The `__at N` part is parsed separately and stores the absolute address
in the symbol's `SPEC_ABSA` field. This is the same mechanism used for
`__at` with regular variables (e.g., `__at 0x8000 uint8_t flag;` to
place a variable at a fixed RAM address). The combination of `S_SFR`
storage class + absolute address fully describes an I/O port.

The `BANKED` variant (`__sfr __banked __at 0x1FFD`) indicates a 16-bit
port address, which requires the `IN A,(C)` / `OUT (C),A` instruction
form with the full 16-bit address in the BC register pair.

### Stage 2: Memory allocation (`src/SDCCmem.c`)

sdcc has an internal concept of "memory spaces" or "output classes"
(`OCLS`) that track where each symbol lives. When allocating storage
for a symbol with `S_SFR` storage class, the memory allocator places
it in the `sfr` memory space:

```c
switch (SPEC_SCLS(sym->etype)) {
    case S_SFR:
        SPEC_OCLS(sym->etype) = sfr;    // → sfr address space
        break;
    case S_SBIT:
        SPEC_OCLS(sym->etype) = sfrbit; // → sfrbit (for 8051 bit-addressable)
        break;
    case S_CODE:
        // ...
}
```

The `sfr` address space is internally identified as `REGSP` (register
space). This name comes from sdcc's 8051 heritage, where special
function registers were memory-mapped. For the Z80, `REGSP` represents
the I/O port address space — it is the space of addresses that the
`IN` and `OUT` instructions operate on.

The key macro `IN_REGSP(space)` tests whether a symbol lives in this
space. This test is used throughout the code generator to determine
whether a memory access should use `LD` (memory) or `IN`/`OUT` (port).

### Stage 3: Operand allocation (`src/z80/gen.c`, `aopForSym()`)

When the Z80 code generator prepares to emit code for an operation
involving a symbol, it calls `aopForSym()` to determine the "assembly
operand" (`aop`) — a struct that describes how to access the value in
Z80 assembly.

For symbols in `REGSP` space, this function creates an `AOP_SFR`
operand:

```c
if (IN_REGSP(space)) {
    aop = newAsmop(AOP_SFR);
    sym->aop = aop;
    aop->aopu.aop_dir = sym->rname;      // symbol name (emitted as defc)
    aop->size = getSize(sym->type);       // 1 byte for __sfr
    aop->paged = FUNC_REGBANK(sym->type); // nonzero = banked (16-bit port)
    aop->bcInUse = isPairInUse(PAIR_BC, ic); // track BC for banked OUT
    return aop;
}
```

`AOP_SFR` is one of about 15 operand types in sdcc's Z80 backend. Others
include `AOP_REG` (value in a register), `AOP_STK` (value on the stack),
`AOP_HL` (value pointed to by HL), etc. Each operand type has
corresponding code in the `aopGet()` (read) and `aopPut()` (write)
functions that emit the appropriate Z80 instructions.

The `AOP_SFR` type is handled with the same level of generality as any
other operand type. When the code generator needs to, say, add a
constant to a port value and write it back, it uses the same generic
operation framework — it just happens that the "read" operation emits
`IN` instead of `LD`, and the "write" emits `OUT` instead of `LD`.

### Stage 4: Code emission (`src/z80/gen.c`, `aopGet()` / `aopPut()`)

The actual IN/OUT instructions are emitted in the `aopGet()` function
(for reads) and `aopPut()` function (for writes). These are large
switch statements over operand types, and `AOP_SFR` is one of the cases.

#### Reading from a port (`aopGet`, case `AOP_SFR`):

```c
case AOP_SFR:
    if (IS_SM83) {
        // Game Boy: uses LDH instruction (memory-mapped I/O)
        emit2("!rldh", aop->aopu.aop_dir, offset);
    } else if (IS_RAB) {
        // Rabbit 2000: uses IOI prefix for internal I/O
        emit2("ioi");
        emit2("ld a, !mems", aop->aopu.aop_dir);
        emit2("nop");    // hardware bug workaround (TN302)
    } else {
        // Z80 family
        if (aop->paged) {
            // Banked: 16-bit port address, high byte goes to A for the
            // IN A,(n) instruction where A provides bits 15-8 of the port
            emit2("ld a, !msbimmeds", aop->aopu.aop_dir);
            emit2("in a, (!lsbimmeds)", aop->aopu.aop_dir);
        } else if (z80_opts.port_mode == 180) {
            // Z180: uses IN0 instruction (forces high address byte to 0)
            emit2("in0 a, !mems", aop->aopu.aop_dir);
        } else {
            // Standard Z80: 8-bit port address
            emit2("in a, !mems", aop->aopu.aop_dir);
        }
    }
```

For a standard Z80 8-bit port read, this emits a single instruction:
`in a, (__port_fdc_status)`. The `!mems` format string wraps the
symbol name in the assembler's absolute address syntax.

#### Writing to a port (`aopPut`, case `AOP_SFR`):

```c
case AOP_SFR:
    if (IS_SM83) {
        // Game Boy: LDH
        if (strcmp(s, "a"))
            emit2("ld a, %s", s);
        emit2("!lldh", aop->aopu.aop_dir, offset);
    } else if (IS_RAB) {
        // Rabbit 2000: IOI prefix
        if (strcmp(s, "a"))
            emit2("ld a, %s", s);
        emit2("ioi");
        emit2("ld !mems,a", aop->aopu.aop_dir);
        emit2("nop");
    } else {
        // Z80 family
        if (aop->paged) {
            // Banked: 16-bit port, need value in A and address in BC
            if (aop->bcInUse)
                emit2("push bc");
            if (strcmp(s, "a"))
                emit2("ld a, %s", s);
            emit2("ld bc, !hashedstr", aop->aopu.aop_dir);
            emit2("out (c), %s", s);
            if (aop->bcInUse)
                emit2("pop bc");
        } else if (z80_opts.port_mode == 180) {
            // Z180: OUT0
            emit2("ld a, %s", s);
            emit2("out0 (%s), a", aop->aopu.aop_dir);
        } else {
            // Standard Z80: 8-bit port address
            if (strcmp(s, "a"))
                emit2("ld a, %s", s);  // ensure value is in A register
            emit2("out (%s), a", aop->aopu.aop_dir);
        }
    }
```

For a standard Z80 8-bit port write, this emits `out (__port_fdc_data), a`.
If the value to write is not already in the A register, a `ld a, <reg>`
instruction is prepended.

Note how the banked (16-bit) case carefully saves and restores BC if it
is in use by surrounding code, since `OUT (C),A` requires the port
address in the BC register pair.

### Stage 5: Assembly and linking

The sdcc code generator emits the port symbols as `defc` (define
constant) directives in the assembly output:

```asm
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
defc __port_fdc_status = 0x0004
defc __port_fdc_data   = 0x0005
```

The generated instructions reference these symbols by name:

```asm
_read_port:
    in  a, (__port_fdc_status)   ; port read
    ld  l, a                      ; return value in L
    ret

_write_port:
    out (__port_fdc_data), a     ; port write (value already in A)
    ret
```

The z80 assembler (z88dk-z80asm or sdasz80) resolves each `defc` name
to its constant value during assembly. The final machine code is:

```
DB 04    ; IN A,(04h) — 2 bytes, opcode DB, operand 04
D3 05    ; OUT (05h),A — 2 bytes, opcode D3, operand 05
```

These are the standard Z80 opcodes for 8-bit port I/O. No function
call overhead, no register setup, no stack manipulation. The compiled
code is identical to hand-written assembly.

## The three port modes in detail

sdcc supports three I/O instruction modes, selected by the target CPU
and command-line options. All three are accessed through the same
`__sfr __at` C syntax — the compiler selects the appropriate instruction
form automatically.

### 8-bit port mode (standard Z80)

```c
__sfr __at 0x04 fdc_status;     // port address 0x00-0xFF
uint8_t x = fdc_status;          // → IN A,(04h)    — 2 bytes
fdc_status = x;                  // → OUT (04h),A   — 2 bytes
```

Uses `IN A,(n)` / `OUT (n),A` instructions (opcodes DB/D3). The port
address is an 8-bit immediate value. During the `IN A,(n)` instruction,
the Z80 places the contents of the A register on address lines A8-A15
(this is sometimes used for port bank selection, but most hardware
ignores these lines).

This is the mode used by the RC702 and most Z80 systems.

### 16-bit banked port mode (Z80 with 16-bit I/O)

```c
__sfr __banked __at 0x1FFD io;  // full 16-bit port address
uint8_t x = io;                  // → LD A,1Fh; IN A,(FDh) — 4 bytes
io = x;                          // → LD BC,1FFDh; OUT (C),A — 5+ bytes
```

Uses `IN A,(C)` / `OUT (C),r` instructions (opcodes ED 78 / ED 79 etc.)
with the 16-bit address in the BC register pair. The `BANKED` keyword
tells sdcc to use this form instead of the 8-bit form.

For reads, sdcc places the high byte in A (which appears on A8-A15
during the IN instruction) and the low byte in the operand. For writes,
the full 16-bit address is loaded into BC.

### Z180 port mode

```c
// Compile with: --portmode=180
__sfr __at 0x04 fdc_status;     // port address 0x00-0xFF
uint8_t x = fdc_status;          // → IN0 A,(04h)   — 3 bytes
fdc_status = x;                  // → OUT0 (04h),A  — 3 bytes
```

The Z180 has `IN0`/`OUT0` instructions (opcodes ED 38 / ED 39) that
explicitly force address lines A8-A15 to zero during I/O operations.
This avoids the Z80's behavior of placing the A register contents on
the upper address lines, which can cause spurious device selection on
systems with 16-bit I/O decoding.

| Mode | Declaration | Read instruction | Write instruction | Bytes per access |
|------|-------------|-----------------|-------------------|-----------------|
| Z80 8-bit | `__sfr __at N` | `IN A,(N)` | `OUT (N),A` | 2 |
| Z80 banked | `__sfr __banked __at N` | `LD A,hi; IN A,(lo)` | `LD BC,N; OUT (C),A` | 4-5 |
| Z180 | `__sfr __at N` + `--portmode=180` | `IN0 A,(N)` | `OUT0 (N),A` | 3 |

## Comparison with alternative approaches

### `__sfr __at` (sdcc and sccz80)

```c
__sfr __at 0x04 fdc_status;
uint8_t x = fdc_status;          // 2 bytes: IN A,(04h)
fdc_status = 0x42;               // 4 bytes: LD A,42h; OUT (04h),A
```

- Optimal code: 2 bytes per IN/OUT instruction
- Portable across sdcc and sccz80 (both z88dk C backends)
- NOT portable to the clang backend (clang doesn't understand the keyword)
- Inline: no function call overhead

### `z80_inp()` / `z80_outp()` (z88dk library)

```c
#include <z80.h>
uint8_t x = z80_inp(0x04);       // ~8 bytes: push/call/pop
z80_outp(0x05, 0x42);            // ~10 bytes: push args, call, pop
```

- Portable across all z88dk backends (sdcc, sccz80, clang)
- Function call overhead: CALL + RET + register shuffling per access
- sdcc optimizes to `__z88dk_fastcall` / `__z88dk_callee` variants,
  reducing overhead slightly (port in HL, callee pops stack)
- Library implementation: `LD C,L; LD B,H; IN L,(C); LD H,0; RET`

### Inline assembly macros (classic z88dk `stdlib.h`)

```c
M_INP8(0x04)        // → IN A,(04h)      — 2 bytes
M_OUTP8(0x04, 0x42) // → LD A,42h; OUT (04h),A — 4 bytes
```

- Optimal code: same as `__sfr __at`
- Not portable (requires sdcc/sccz80 inline asm syntax)
- Macros defined in classic z88dk `stdlib.h`, not available in newlib
- Returns value via side effect (result left in A register), not as
  a C expression — harder to use in expressions

## Why `__sfr __at` cannot work with the clang backend

The `__sfr __at` mechanism is deeply integrated into sdcc's compiler
at every stage from parsing to code generation. It is NOT something
that can be replicated by:

- **Peephole rules** — the distinction between memory and I/O is
  established at parse time (stage 1) and carried through the
  intermediate representation. By the time peephole rules run, the
  decision to emit `LD` vs `IN`/`OUT` has already been made. You
  cannot peephole-optimize a `LD` into an `IN` because the compiler
  has already committed to memory-space semantics.

- **Macros or typedefs** — `__sfr` is a storage class keyword in the
  grammar, not a type or macro. It cannot be `#define`d in terms of
  other C constructs.

- **Inline assembly** — would work but defeats the purpose of
  portable C code.

The clang backend's pipeline (C → clang → LLVM IR → llvm-cbe → C → sdcc)
cannot preserve `__sfr` semantics because:

1. **clang doesn't understand `__sfr`** — it's an sdcc-specific keyword.
   clang's C parser has no concept of an I/O address space. The variable
   becomes an ordinary `extern uint8_t` in LLVM IR.

2. **LLVM IR has no I/O address space** (for Z80) — the Z80 LLVM backend
   does not model the I/O port space as a distinct address space in IR.
   All memory accesses are in the default address space.

3. **llvm-cbe generates plain C** — the C backend translates LLVM IR
   back to C, which has no way to express "this variable is in I/O
   space." It emits `extern uint8_t _port_fdc_status;` — an ordinary
   memory variable.

4. **sdcc sees a normal variable** — when sdcc compiles the llvm-cbe
   output, it sees a regular `extern uint8_t` and generates `LD`
   instructions. There is no information left to tell it that `IN`/`OUT`
   should be used instead.

The information that a variable is in I/O port space is lost at step 1
and cannot be recovered. The only way to get inline `IN`/`OUT` from the
clang pipeline would be to inject `__sfr __at` declarations into the
generated .cbe.c file before sdcc compiles it — replacing the
`extern uint8_t` declarations with `__sfr __at` equivalents. This is
a viable workaround (the zllvm-cbe wrapper script already patches the
.cbe.c for other issues), but it requires maintaining a port mapping
outside the C source.

## Source references

- Parser: [`src/SDCC.y`](https://github.com/swegener/sdcc/blob/master/src/SDCC.y) — grammar rule at line ~2708, `SFR` token → `S_SFR` storage class
- Memory: [`src/SDCCmem.c`](https://github.com/swegener/sdcc/blob/master/src/SDCCmem.c) — `S_SFR` → `sfr` output class (REGSP space)
- Codegen: [`src/z80/gen.c`](https://github.com/swegener/sdcc/blob/master/src/z80/gen.c) — `aopForSym()` creates `AOP_SFR` at line ~1789; `aopGet()` emits `IN` at line ~3344; `aopPut()` emits `OUT` at line ~3556
- SDCC manual §3.5.2: [sdccman.pdf](https://sdcc.sourceforge.net/doc/sdccman.pdf) — user-facing documentation of `__sfr` and `__at`
- SDCC bug #3160: [Duplicate pointer/SFR issue](https://sourceforge.net/p/sdcc/bugs/3160/) — documents that SFR information is lost when taking the address of an `__sfr` variable, confirming the mechanism is tied to direct variable access
