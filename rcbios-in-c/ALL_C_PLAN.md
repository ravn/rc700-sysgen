# Plan: Convert BIOS to Pure C

Goal: a pure C program with no assembly files.  Minimal inline asm is
acceptable where the compiler cannot express the intent (DI/EI, SP
manipulation, LDIR, port I/O).

## Current Assembly in crt0.asm (~450 lines)

| Block | Lines | Bytes | Purpose |
|-------|-------|-------|---------|
| BOOT header | 46-55 | 14 | Boot pointer, signature, timestamp |
| _cboot | 56-98 | ~60 | DI, 3×LDIR, zero BSS, SP, call, JP |
| CONFI defaults | 100-196 | 128 | defb data block |
| Conversion tables | 198-240 | 384 | include of .inc file |
| BIOSAD JP table | 268-284 | 51 | 17 × `jp _func` |
| JTVARS | 303-345 | 22 | defb/defs data |
| Extended JP table | 355-390 | 39 | 7 × `jp _func` + reserved |
| Fixed addresses | 396-397 | 0 | defc symbols |
| ISR shims | 407-444 | ~30 | 4 calling convention wrappers |
| Section ordering | 446-449 | 0 | SECTION declarations |

## Conversion Strategy

### 1. BIOSAD + JTVARS + Extended JP → Initialized C struct

The jump table and JTVARS are a contiguous block at 0xDA00-0xDA70.
This can be expressed as a single C struct with initial values:

```c
typedef struct {
    /* 0xDA00: Standard CP/M 2.2 BIOS jump table (17 entries) */
    byte jt_boot[3];     /* jp _bios_boot */
    byte jt_wboot[3];    /* jp _bios_wboot */
    ...
    byte jt_sectran[3];  /* jp _bios_sectran */

    /* 0xDA33: JTVARS (runtime configuration) */
    JTVars jtvars;

    /* 0xDA49: Extended jump table */
    byte resv0;
    byte jt_wfitr[3];
    ...
    byte reserved[19];
    word pchsav;
} BiosPage;
```

**Problem**: C cannot express `jp _func` as a 3-byte initializer without
knowing the target address at compile time.  Two approaches:

**(a) Runtime initialization**: Declare `BiosPage` with zero-initialized
JP entries.  `bios_hw_init()` fills in the JP opcodes (0xC3) and addresses
at boot.  This costs ~100 bytes of init code but is clean C.

**(b) Linker-resolved initializers**: Use z88dk `__at()` to place the
struct, and hand-write the JP bytes as `{ 0xC3, lo, hi }`.  But sdcc
cannot resolve extern function addresses in static initializers.

**Recommendation**: Approach (a).  The JP table is written once at boot
and the init code is straightforward:

```c
static void init_jp(byte *entry, void (*func)(void)) {
    entry[0] = 0xC3;  /* JP opcode */
    entry[1] = (word)func & 0xFF;
    entry[2] = (word)func >> 8;
}
```

**Risk**: External programs (CONFI, FORMAT) call BIOS by `CALL BIOSAD+N`.
The JP table MUST be at exactly 0xDA00 and each entry MUST be exactly
3 bytes.  A C struct with `__at(0xDA00)` guarantees placement, and
`byte[3]` fields guarantee sizing.

### 2. _cboot → `__naked __critical` C function

The cold boot routine performs:
1. DI (implicit from `__critical`)
2. memcpy: `__BOOT_tail` → `__BIOS_head` (BIOS relocation)
3. memcpy: `_confi_defaults` → `CFG_ADDR` (128 bytes)
4. memcpy: `_conv_tables` → `0xF680` (384 bytes)
5. memset: `__bss_compiler_head` → 0 (BSS zeroing)
6. SP = 0x80
7. call `bios_hw_init()`
8. JP `BIOSAD`

In C:

```c
void cboot(void) __naked __critical {
    /* Step 1: relocate BIOS to runtime address */
    memcpy((void *)BIOS_BASE, (void *)__BOOT_tail, bios_code_size);

    /* Step 2-3: copy CONFI and conversion tables */
    memcpy((void *)CFG_ADDR, confi_defaults, 128);
    memcpy((void *)0xF680, conv_tables, 384);

    /* Step 4: zero BSS */
    memset((void *)__bss_compiler_head, 0, bss_size);

    /* Step 5: set SP and jump */
    __asm
        ld sp, #0x0080
        call _bios_hw_init
        jp BIOSAD
    __endasm;
}
```

**Challenges**:
- `__naked` means no prologue/epilogue — we must not use local variables
  (no stack frame).  All values must be constants or globals.
- The linker symbols (`__BOOT_tail`, `__bss_compiler_head`, etc.) need
  to be accessible from C.  z88dk exposes these as `extern byte` symbols.
- `memcpy`/`memset` must be available without stdlib (implement as LDIR
  wrappers or use z88dk's built-in `l_memcpy`).
- The function runs from physical address (BOOT section at 0x0000), not
  from runtime address.  It must be compiled into the BOOT section.
- After the BIOS relocation memcpy, the code we're running from
  (physical 0x0000) is still intact because it's in BOOT, not BIOS.
  But we must not call any function in the BIOS section until after
  relocation completes.

**Simplification**: Use inline LDIR wrappers instead of memcpy to avoid
library dependencies:

```c
static void ldir_copy(void *dst, const void *src, word count) __naked {
    __asm
        pop bc      ; return address
        pop de      ; dst
        pop hl      ; src  (note: sdcccall stack order)
        ; count already in stack...
    __endasm;
}
```

Actually, sdcccall(1) passes first arg in HL, second in DE — this maps
naturally to LDIR's HL=source, DE=dest with a swap.  But 3-arg functions
go partly on stack.  A cleaner approach:

```c
/* Two-arg copy using sdcccall(1): src in HL, count in DE */
static void copy_to_fixed(const void *src, word count) __naked {
    /* DE = fixed destination, set before call */
}
```

This is getting complex for __naked.  The cleanest path may be to keep
_cboot as a minimal __naked stub that calls a normal C function:

```c
void cboot(void) __naked __critical {
    __asm
        call _cboot_body
        ld sp, #0x0080
        call _bios_hw_init
        jp 0xDA00
    __endasm;
}

void cboot_body(void) {
    /* Normal C function — compiler manages registers */
    memcpy((void *)BIOS_BASE, &__BOOT_tail, bios_code_size);
    memcpy((void *)CFG_ADDR, confi_defaults, 128);
    memcpy((void *)0xF680, conv_tables, 384);
    memset((void *)&__bss_compiler_head, 0, bss_size);
}
```

**But**: `cboot_body` would need a stack, and SP is undefined when the
ROM jumps to _cboot.  The ROM sets SP before jumping?  Need to check.

Looking at the ROA375 PROM: it sets SP to 0xBFFF before jumping to 0x0000.
So SP is valid when _cboot runs.  This means `cboot_body()` CAN use the
stack.

**Answer: Yes, this works.**  The PROM provides a valid stack at 0xBFFF.
`cboot_body()` can be a normal C function.  After it returns, the __naked
wrapper sets SP to 0x80 (CP/M DMA buffer area) and jumps to BIOS.

### 3. ISR Shims → __naked C, placed before body for fall-through

The 4 shims handle CP/M↔sdcccall(1) calling convention mismatch:

```
_bios_list:   ld a,c ; jp _bios_list_body
_bios_punch:  push hl; ld a,c; call _bios_punch_body; pop hl; ret
_bios_reader: push hl; call _bios_reader_body; pop hl; ld c,a; ret
_bios_reads:  push hl; call _bios_reads_body; pop hl; ld c,a; ret
```

These become `__naked` C functions placed **immediately before** their
corresponding `_body` function in the source file.  This lets the
peephole optimizer eliminate the call/jp entirely via fall-through:

```c
/* Shim: CP/M passes char in C, sdcccall(1) expects A */
void bios_list(void) __naked {
    __asm
        ld a, c
    __endasm;
    /* fall through to bios_list_body below */
}

void bios_list_body(byte ch) {
    /* ... actual list output code ... */
}
```

The peephole optimizer sees `jp _bios_list_body` followed by the
`_bios_list_body:` label and eliminates the jump.  For the `push hl`
/ `pop hl` shims (punch, reader, reads), the pattern is:

```c
void bios_reader(void) __naked {
    __asm
        push hl
        call _bios_reader_body
        pop hl
        ld c, a
        ret
    __endasm;
}

void bios_reader_body(void) {
    /* ... */
}
```

Here the `call`+`ret` pair in the body can be optimized to fall-through
by the peephole optimizer (the `call _body; ... ret` in the shim becomes
direct execution when the body follows immediately).  The `push hl` /
`pop hl` wrapping must remain since HL preservation is required by SNIOS.

### 4. BOOT Header + Data Blocks

The boot pointer, signature, CONFI defaults, and conversion tables are
pure data.  These can be C arrays with `__at()` placement:

```c
/* BOOT section: first 128-byte sector on Track 0 */
__at(0x0000) const word boot_ptr = (word)&cboot;
__at(0x0008) const char signature[6] = " RC702";
```

**Problem**: The boot pointer must be the physical address of `cboot`,
which the linker resolves.  sdcc supports `= (word)&func` in static
initializers for function pointers.  Need to verify z88dk does too.

The CONFI defaults and conversion tables are already mostly data — just
need `const byte[]` arrays with section attributes to land in BOOT.

### 5. Section Ordering

Currently explicit `SECTION` declarations ensure the linker places
sections in the right order.  In an all-C approach, use z88dk pragmas
or explicit section attributes on each function/data block.

## Execution Plan

### Phase 1: BIOSAD + JTVARS as C struct (safest first)

1. Define `BiosPage` struct in bios.h
2. Place it `__at(0xDA00)` in the BIOS section
3. Add `init_jp_table()` to bios_hw_init() to fill JP opcodes
4. Remove JP table and JTVARS from crt0.asm
5. Verify: build, check addresses in .map, boot in MAME

### Phase 2: _cboot as __naked + C body

1. Write `cboot_body()` in a new C file (boot_section, --codeseg BOOT)
2. Reduce _cboot to a __naked __critical stub that calls cboot_body
3. Need LDIR-based memcpy (write or use z88dk intrinsic)
4. Verify: boot in MAME, check Track 0 layout

### Phase 3: ISR shims as __naked C

1. Move 4 shims from crt0.asm to bios.c as __naked functions
2. Verify: boot, test serial I/O (SNIOS depends on HL preservation)

### Phase 4: Data blocks as C arrays

1. Move CONFI defaults and conversion tables to C const arrays
2. Move boot header (pointer, signature) to C
3. Minimal crt0.asm: only section ordering declarations remain

### Phase 5: Externalize linker block definitions

After phases 1-4, crt0.asm contains only SECTION declarations that
control linker ordering.  Goal: move these out of the project entirely.

Options:
- **z88dk custom target config**: Define section ordering in a `.cfg`
  file under `z88dk/lib/config/`.  z88dk's `+z80` target allows custom
  section maps via `-pragma-define` and config files.
- **Linker script**: z88dk's z80asm linker supports `-split-bin` and
  section ordering via the module link order.  If all C files declare
  their own sections, the link order in the Makefile determines layout.
- **Pragma in C**: `#pragma codeseg`, `#pragma dataseg` etc. in the C
  source files can declare sections without any .asm file.

The end state: **no .asm files in the project**.  All Z80 code is either
compiler-generated C or inline `__asm` blocks within C functions.

## Risks

- **JP table correctness**: If any JP address is wrong, the system
  crashes immediately.  Must verify every address in the .map file.
- **Section placement**: z88dk's linker must place the BIOS section at
  exactly 0xDA00.  Currently guaranteed by `org`; C placement depends
  on `__at()` working correctly for initialized data in non-BSS sections.
- **BOOT section code**: Code in the BOOT section runs at physical
  address 0x0000.  z88dk must compile it for the correct address, not
  the BIOS runtime address.  The `--codeseg BOOT` flag handles this.
- **Binary size**: Runtime JP table init adds ~100 bytes.  Currently
  64 bytes to spare in mini format.  Tight but should fit.
- **memcpy in BOOT**: Must not call any function in the BIOS section
  before relocation completes.  The memcpy implementation must be in
  the BOOT section or inlined.
