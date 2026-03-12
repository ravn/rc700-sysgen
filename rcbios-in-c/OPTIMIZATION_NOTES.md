# Optimization Notes for BIOS-in-C

Findings and ideas for future optimization, recorded for reference.

## z88dk Relocatable Binary Support

z88dk can generate relocatable binaries via two mechanisms:

### `-R` flag (z80asm): Self-relocating binary
- Prepends a 73-byte relocation routine + fixup table to the binary.
- At load time, the routine patches all absolute addresses before executing.
- RAM-only (self-modifying code).
- Uses IY as base register, preserves alternate register set.
- ORG directives are ignored when `-R` is active.

### `-reloc-info` flag (zcc): External relocation table
- Generates a separate `.reloc` file with the fixup table.
- The table can be processed by a custom loader.
- Can be used with or without `-R`.

### Relocation table format
- Header: 2-byte entry count + 2-byte table size.
- Entries: delta-encoded offsets (1 byte if 1-255, 3 bytes otherwise).
- Each entry marks a 16-bit address in the binary that needs patching.

### Key files
- Relocation routine source: `z88dk/download/z88dk/src/z80asm/dev/reloc_code.asm`
- Test suite: `z88dk/download/z88dk/src/z80asm/t/option_reloc.t`

### Assessment
Not useful for the current BIOS.  The existing approach (compile at runtime
address 0xD480+, LDIR copies verbatim) is simpler and has zero runtime
overhead.  The `-R` routine would add 73+ bytes and relocation time.

Could be useful if the BIOS needed to run at different addresses (e.g.,
multiple memory configurations), but CP/M 56K is fixed.

---

## OTIR for SIO Initialization (saves ~58 bytes)

The SIO init currently uses C loops (~70 bytes compiled):
```c
for (i = 0; i < 9; i++)
    _port_sio_a_ctrl = CFG.sioa[i];
for (i = 0; i < 11; i++)
    _port_sio_b_ctrl = CFG.siob[i];
```

The original BIOS used OTIR (block output), which is much smaller (12 bytes):
```asm
ld hl, #0xD508    ; &CFG.sioa (runtime address of sioa[0])
ld b, #9
ld c, #0x0A       ; SIO-A control port
otir
ld hl, #0xD511    ; &CFG.siob (runtime address of siob[0])
ld b, #11
ld c, #0x0B       ; SIO-B control port
otir
```

### Why it was removed
The original inline asm referenced assembly labels (`_psioa`, `_psiob`).
When those labels were removed (CONFI block converted to C struct), the
OTIR was replaced with C loops to avoid depending on assembly symbols.

### How to restore
Use hardcoded struct member addresses.  The ConfiBlock is at 0xD500,
`sioa` is at offset +0x08 = 0xD508, `siob` is at offset +0x11 = 0xD511.
These addresses are ABI-stable (CONFI.COM depends on them).

```c
__asm__("ld hl, #0xD508\n ld b, #9\n ld c, #0x0A\n otir\n"
        "ld hl, #0xD511\n ld b, #11\n ld c, #0x0B\n otir\n");
```

### Savings
~58 bytes (70 → 12).  Runs once at boot, so cycle count is irrelevant.

### Why not yet
Keeping C loops for now — clearer, no magic addresses.  Apply when
size pressure requires it.

---

## `out (c), reg` — Z80 Indirect I/O

sdcc's `__sfr __at(port)` only generates the 8080-compatible `out (N), a`
form (immediate port number, A register only).  It cannot generate:

- `out (c), r` — output any register via port in C register
- `otir` / `otdr` — block output (repeated `out (c), (hl)`)
- `ini` / `ind` / `inir` / `indr` — block input

These require inline assembly.  The `out (c), r` form could optimize
any code that loads a value into A just to output it, if the value is
already in another register.  However, sdcc's register allocator would
need to cooperate, which it can't for inline asm operands — so the
practical benefit is limited to hand-written asm blocks.

---

## Using z88dk Standard CRT (dropping `--no-crt`)

Currently the build uses `--no-crt` with a custom `crt0.asm`.  The
z88dk standard CRT (`z80_crt0.asm`) provides BSS zeroing, stack setup,
IM2 configuration, initialized data copy, and calls `_main()`.

### What the standard CRT offers

The `+z80` target CRT is configurable via pragmas:
- `CRT_ORG_CODE=addr` — set code origin (our 0xD700 for code-only binary)
- `CRT_REGISTER_SP=addr` — set initial SP (our 0x0080 = BUFF)
- `CRT_INTERRUPT_MODE=2` — configure IM2 at startup
- `CRT_ORG_BSS=addr` — place BSS at a specific address (optional)

### Customization hooks

- **`__MMAP=-1`**: Tells the CRT to include `./mmap.inc` instead of the
  standard section layout.  This is where we'd define a custom section
  at 0xDA00 for the JP table.

- **`CRT_INCLUDE_PREAMBLE`**: Includes `crt_preamble.asm` right before
  the `start:` label.  This is where the LDIR relocation code could go.

- **Custom `mmap.inc`**: Full control over section ordering and ORG
  placement.  Can define arbitrary sections at fixed addresses.

### What we'd gain

- stdlib functions: `memcpy`, `memset` (currently hand-rolled or inline asm)
- BSS zeroing handled by CRT (remove from _cboot)
- IM2 setup handled by CRT (remove from setup_ivt)
- Standard section ordering without manual declarations

### What still needs assembly

The JP table at 0xDA00 is irreducible — 17 `jp _bios_xxx` instructions
referencing C function symbols.  No C construct can emit these.  The
JTVARS (0xDA33), extended JP table (0xDA49+), and `_pchsav` (0xDA6F)
also need assembly for fixed-address placement with initialized data.

The LDIR relocation in `_cboot` must run before the CRT, so it would
go in `crt_preamble.asm` (or we'd use `-crt0` to supply a custom CRT
that includes the LDIR before the standard startup sequence).

### What we'd replace crt0.asm with

Two smaller files:
1. `mmap.inc` — custom section layout defining the JP table section
   at 0xDA00 with the 17 JP entries, JTVARS, extended JP table, and
   `_pchsav`.  Essentially the 0xDA00-0xDA70 region of current crt0.asm.
2. `crt_preamble.asm` — LDIR relocation code (the _cboot block minus
   BSS zeroing and SP setup, which the CRT handles).

### Assessment

Net effect: replace one 287-line file with two smaller files (~80 lines
total) plus gain stdlib access.  The JP table assembly is irreducible.
The main benefit is stdlib functions and cleaner separation of concerns.
Risk is moderate — section ordering conflicts between our custom layout
and the CRT's expectations could cause subtle binary layout bugs.

### Key files in z88dk

- Standard CRT: `z88dk/lib/target/z80/classic/z80_crt0.asm`
- Section ordering: `z88dk/lib/crt/classic/crt_section_standard.inc`
- CRT init (BSS zero + data copy): `z88dk/lib/crt/classic/crt_section.inc`
- IM2 setup: `z88dk/lib/crt/classic/crt_init_interrupt_mode.inc`
