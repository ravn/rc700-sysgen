# How sdcc implements `__sfr __at` port I/O

This documents how sdcc turns `__sfr __at` declarations into inline
Z80 IN/OUT instructions. This is NOT a peephole optimization — it is
a first-class language feature handled at every stage of the compiler.

## The pipeline

```
C source                    __sfr __at 0x04 fdc_status;
  ↓ parser (SDCC.y)         SFR token → storage class S_SFR
  ↓ memory allocator        S_SFR → REGSP address space (sfr)
  ↓ iCode generator         operand type: IN_REGSP → AOP_SFR
  ↓ Z80 code generator      AOP_SFR → emit "in a,(N)" / "out (N),a"
  ↓ assembler               resolves defc symbol → 2-byte instruction
```

## Stage 1: Parser (`src/SDCC.y`)

The `__sfr` keyword is tokenized as `SFR` and parsed as a storage
class specifier:

```c
sfr_attributes
  : SFR    {
              SPEC_SCLS($$) = S_SFR;    // storage class = SFR
           }
  | SFR BANKED {
              SPEC_SCLS($$) = S_SFR;
              SPEC_BANKED($$) = 1;       // 16-bit port address
           }
```

The `__at N` part stores the absolute address via `SPEC_ABSA`.

## Stage 2: Memory allocation (`src/SDCCmem.c`)

The `S_SFR` storage class maps the symbol to the `sfr` memory space
(called `REGSP` — register space, the Z80 I/O address space):

```c
case S_SFR:
    SPEC_OCLS(sym->etype) = sfr;    // → IN_REGSP address space
    break;
```

This is separate from `data`, `code`, or `xdata` — it represents the
Z80 I/O port address space accessed by IN/OUT instructions.

## Stage 3: Operand allocation (`src/z80/gen.c`, `aopForSym()`)

When the code generator encounters a symbol in `REGSP` space, it
creates an `AOP_SFR` operand:

```c
if (IN_REGSP(space)) {
    aop = newAsmop(AOP_SFR);
    aop->aopu.aop_dir = sym->rname;      // symbol name (becomes defc)
    aop->size = getSize(sym->type);       // 1 byte for __sfr
    aop->paged = FUNC_REGBANK(sym->type); // banked = 16-bit port
    return aop;
}
```

## Stage 4: Code emission (`src/z80/gen.c`, `aopGet()` / `aopPut()`)

### Reading from a port (`aopGet`, case `AOP_SFR`):

```c
case AOP_SFR:
    if (aop->paged) {
        // banked: 16-bit port via BC register
        emit2("ld a, !msbimmeds", aop->aopu.aop_dir);  // A = high byte
        emit2("in a, (!lsbimmeds)", aop->aopu.aop_dir); // IN A,(low)
    } else if (z80_opts.port_mode == 180) {
        emit2("in0 a, !mems", aop->aopu.aop_dir);       // Z180: IN0 A,(N)
    } else {
        emit2("in a, !mems", aop->aopu.aop_dir);         // Z80: IN A,(N)
    }
```

### Writing to a port (`aopPut`, case `AOP_SFR`):

```c
case AOP_SFR:
    if (aop->paged) {
        // banked: 16-bit port via BC register
        emit2("ld bc, !hashedstr", aop->aopu.aop_dir);
        emit2("out (c), %s", s);
    } else if (z80_opts.port_mode == 180) {
        emit2("ld a, %s", s);
        emit2("out0 (%s), a", aop->aopu.aop_dir);       // Z180: OUT0 (N),A
    } else {
        if (strcmp(s, "a"))
            emit2("ld a, %s", s);                         // ensure value in A
        emit2("out (%s), a", aop->aopu.aop_dir);         // Z80: OUT (N),A
    }
```

## Stage 5: Assembly output

The symbol is emitted as a `defc` constant equate:

```asm
; special function registers
defc __port_fdc_status = 0x0004
defc __port_fdc_data   = 0x0005
```

And the instructions reference it by name:

```asm
in  a, (__port_fdc_status)   ; assembles to: DB 04  (2 bytes)
out (__port_fdc_data), a     ; assembles to: D3 05  (2 bytes)
```

The assembler resolves the `defc` name to the constant value, producing
the final 2-byte `IN A,(N)` / `OUT (N),A` instructions.

## Three port modes

sdcc supports three I/O modes depending on the target CPU:

| Mode | Instruction | Size | Port width |
|------|-------------|------|------------|
| Z80 8-bit (`__sfr __at N`) | `IN A,(N)` / `OUT (N),A` | 2 bytes | 8-bit |
| Z80 banked (`__sfr __banked __at N`) | `LD BC,N; IN A,(C)` / `OUT (C),A` | 4 bytes | 16-bit |
| Z180 (`--portmode=180`) | `IN0 A,(N)` / `OUT0 (N),A` | 3 bytes | 8-bit, high byte forced 0 |

## Why this matters for the clang backend

The `__sfr __at` mechanism is deeply integrated into sdcc's code
generator. It is not a peephole optimization or a macro trick — the
compiler treats SFR variables as a distinct address space and emits
IN/OUT instructions at code generation time, just as it emits LD
instructions for regular memory variables.

The clang backend cannot use this because clang's C frontend doesn't
understand `__sfr __at`. The keyword is parsed by sdcc's own parser
(stage 1), and the clang→LLVM IR→llvm-cbe→C round-trip has no way to
preserve or reconstruct SFR semantics in the generated C code.

## Source references

- Parser: [`src/SDCC.y`](https://github.com/swegener/sdcc/blob/master/src/SDCC.y) (line ~2708)
- Memory: [`src/SDCCmem.c`](https://github.com/swegener/sdcc/blob/master/src/SDCCmem.c) (S_SFR case)
- Codegen: [`src/z80/gen.c`](https://github.com/swegener/sdcc/blob/master/src/z80/gen.c) (AOP_SFR in aopGet/aopPut)
- SDCC manual §3.5.2: [sdccman.pdf](https://sdcc.sourceforge.net/doc/sdccman.pdf)
