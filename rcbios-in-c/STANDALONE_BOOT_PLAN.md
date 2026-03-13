# Standalone Bootable C Program for RC702

Plan for creating a minimal C program that boots directly on the RC702,
using the same hardware init as the BIOS but without CP/M.

## Goal

A small standard-library C program written to Track 0, bootable by the
ROM just like the BIOS.  It initializes hardware (display, keyboard) and
runs a `main()` function with `putchar()`/`getchar()` style I/O.

## Minimum hardware init required

The RC702 display is entirely interrupt-driven: the 8275 CRT controller
generates ~50 Hz pulses via CTC ch2, which trigger the display ISR.
The ISR programs DMA ch2 to transfer 2000 bytes from display memory
(0xF800) to the CRT controller.  Without this ISR running, the screen
stays blank.

### Init sequence (same order as bios_hw_init):

1. **IVT** — copy 18 interrupt vectors to 0xF600 (page-aligned).
   Set I=0xF6, enable IM2.  Most vectors point to a dummy ISR (ei+reti).
2. **PIO** — set interrupt vectors, PIO-A input mode (keyboard),
   PIO-B output mode, enable interrupts on both.
3. **CTC** — set vector base.  Ch0/ch1: baud clocks (timer mode).
   Ch2: counter mode, count 1 (CRT interrupt source).
   Ch3: counter mode, count 1 (FDC interrupt source, can skip if no disk).
4. **SIO** — channel reset + init sequence for both channels.
   Even if unused, SIO must be initialized to prevent spurious interrupts.
   The SIO-B init includes the interrupt vector (WR2=0x10).
5. **DMA** — master clear, set ch2/ch3 modes (single, mem→IO).
   Ch2 address and word count are set by the display ISR, not here.
6. **FDC** — SPECIFY command (step rate, head load time).  Can skip
   if no disk I/O needed.
7. **Display memory** — fill 0xF800 with spaces (2000 bytes).
8. **WorkArea** — zero 0xFFD1-0xFFFF (48 bytes of runtime variables).
9. **CRT** — reset 8275, send 4 parameter bytes (80×25, 7 lines/char),
   load cursor position, preset counters, start display.

All timing constants come from ConfiBlock (the existing `confi_defaults`
struct can be reused directly).

### Essential ISRs

| ISR | Vector | Purpose | Notes |
|-----|--------|---------|-------|
| isr_crt | CTC ch2 (#2) | Display refresh via DMA | **Essential** — screen blank without it |
| isr_pio_kbd | PIO-A (#16) | Keyboard input to ring buffer | Needed for interactive programs |
| isr_floppy | CTC ch3 (#3) | Disk completion flag | Only if disk I/O needed |
| isr_dummy | all others | ei + reti | Prevents hangs from spurious interrupts |

The display ISR core is ~40 lines of C: acknowledge CRT interrupt,
program DMA ch2 with display memory address and word count, unmask
channels, reprogram CTC ch2 for next interrupt.  The BIOS version
also handles cursor update, RTC, timers, and floppy motor — a
standalone version can omit all of that.

The keyboard ISR is ~15 lines: read PIO-A data port, store in 16-byte
ring buffer, update head pointer and status flag.

### ISR wrappers

All ISRs that do real work need `__naked` wrappers with:
- Save SP to `sp_sav`, switch SP to ISTACK (0xF600)
- Push AF, BC, DE, HL
- Call C body function
- Pop HL, DE, BC, AF
- Restore SP from `sp_sav`
- EI + RETI

The dummy ISR can use `__interrupt(0)` (just ei + reti).

## Memory layout

```
Address       Size    Purpose
-------       ----    -------
0x0000-0x007F   128   Boot sector (boot pointer + " RC702")
0x0080-0x04FF  1152   _cboot + main program code (INIT region)
0x0500+        ...    More code/data (resident, survives after boot)
...
0xF500          256   ISTACK (ISR private stack, grows down)
0xF600-0xF623    36   IVT (18 word-size vectors, page-aligned)
0xF680-0xF7FF   384   ConvTables (can repurpose if not needed)
0xF800-0xFFCF  2000   Display memory (80×25, DMA-refreshed)
0xFFD0-0xFFFF    48   WorkArea (cursor, timers, RTC)
```

Unlike the BIOS, a standalone program has no CP/M constraints:
- No JP table at fixed 0xDA00
- No JTVARS at 0xDA33
- No CCP/BDOS to load
- The entire address space below 0xF500 is available for code + data

The ORG can be 0xD480 (same as BIOS) or lower if more space is needed.
The binary must fit in the system tracks: 6144 bytes (mini) or 9984
bytes (maxi).

## crt0.asm structure (simplified vs BIOS)

```asm
    SECTION CODE
    org 0xD480

START equ 0xD480

; Boot sector (128 bytes)
    defw _cboot - START     ; boot pointer
    defs 6
    defm " RC702"
    defs 128 - ASMPC

; _cboot (init code)
_cboot:
    di
    ld hl, 0
    ld de, START
    ld bc, 0xF800 - START + 1
    ldir
    ld hl, __bss_compiler_head
    ld (hl), 0
    ld de, __bss_compiler_head + 1
    ld bc, __bss_compiler_size - 1
    ldir
    ld sp, 0xF500           ; private stack
    call _main              ; call C main()
    halt                    ; if main returns

; ISR wrappers (same pattern as BIOS)
_isr_crt_wrapper:
    push af
    ld (_sp_sav), sp
    ld sp, #0xF600
    push bc
    push de
    push hl
    call _isr_crt_body
    pop hl
    pop de
    pop bc
    ld sp, (_sp_sav)
    pop af
    ei
    reti

; ... keyboard ISR wrapper similarly ...

; Section ordering
    SECTION code_compiler
    SECTION rodata_compiler
    SECTION data_compiler
    SECTION BSS
    SECTION bss_compiler
```

No JP table, no JTVARS, no extended entries.  The ISR wrappers can
follow the PURE_C_PLAN.md approach (wrappers in asm, bodies in C).

## Reusable components from rcbios-in-c/

| File | What to reuse | What to skip |
|------|---------------|--------------|
| `hal.h` | All port definitions, DI/EI/HALT macros | — |
| `bios.h` | WorkArea struct, ConfiBlock struct, display constants | JTVars, DPB, FSPA, FDF, CP/M constants |
| `bios.c` | `confi_defaults`, hw init sequence, display ISR core, keyboard ISR | All BIOS entry points, disk driver, CONOUT escape handling, BGSTAR |
| `crt0.asm` | Boot sector format, relocation, ISR wrapper pattern | JP table, JTVARS, extended entries |
| `peephole.def` | All rules (compiler-agnostic) | — |

## Proposed API for standalone programs

```c
// hw.h — minimal hardware abstraction
void hw_init(void);         // full hardware init (call before ei)
void hw_ei(void);           // enable interrupts (screen comes alive)
void hw_di(void);           // disable interrupts

// Console I/O
void putchar(char c);       // write character at cursor, advance
void puts(const char *s);   // write string
char getchar(void);         // block until key pressed, return it
int kbhit(void);            // non-blocking: return 1 if key available

// Display memory (direct access)
#define SCREEN ((volatile char (*)[80])0xF800)
// Usage: SCREEN[row][col] = 'X';
```

The `putchar` can start simple (just write to display memory + advance
cursor) and later gain escape sequence support if needed.

## Build system

Same z88dk flags as the BIOS, with a different crt0.asm:

```makefile
ZFLAGS = +z80 -clib=sdcc_iy --no-crt --opt-code-size -SO3 \
         -Cs"--max-allocs-per-node 1000000" \
         -Cs"--fomit-frame-pointer" \
         -Cs"--allow-unsafe-read" \
         -Cs"--sdcccall 1" \
         -Cs"--std-sdcc99" \
         -Cs"--disable-warning 296" \
         -pragma-define:CRT_ORG_CODE=0xD480 \
         -m --list -create-app
```

The Makefile trims BSS from .rom to produce the bootable .cim,
same as the BIOS build.  Patching onto a disk image uses the
existing `patch_bios.py` tool.

## Size estimate

| Component | Bytes |
|-----------|------:|
| Boot sector + _cboot | ~170 |
| ISR wrappers (asm) | ~80 |
| hw_init (C) | ~250 |
| Display ISR body (C) | ~80 |
| Keyboard ISR body (C) | ~40 |
| confi_defaults (const data) | 72 |
| putchar/puts/getchar (C) | ~100 |
| WorkArea, IVT array | ~80 |
| **Overhead total** | **~870** |
| Available for main() | ~5270 (mini) / ~9110 (maxi) |

## Implementation steps

1. Create `rc702boot/` directory (or similar) alongside `rcbios-in-c/`
2. Copy `hal.h` and `peephole.def` (or symlink)
3. Write simplified `crt0.asm` (boot sector + relocation + ISR wrappers)
4. Write `hw.c` with init sequence extracted from bios_hw_init()
5. Write minimal display ISR (DMA refresh only, no timers)
6. Write keyboard ISR (ring buffer)
7. Write `putchar`/`getchar` (simple cursor-tracking version)
8. Write `main.c` hello-world test program
9. Build, patch onto disk image, boot in MAME

## Design decisions (deferred)

- **Shared library vs copy**: Extract common code into a shared
  directory, or maintain separate copies?  Shared is cleaner but
  adds build complexity.
- **ORG address**: 0xD480 (same as BIOS, easy testing) or lower
  (more code space)?
- **CONOUT compatibility**: Support ESC sequences (cursor positioning,
  clear screen) or keep it minimal?
- **Disk I/O**: Add floppy read/write support?  Adds ~800 bytes but
  enables file loading.
- **Standard library**: z88dk provides printf/sprintf if linked with
  stdlib.  Worth the size cost (~500+ bytes)?

## What stays as asm

Same as BIOS (see PURE_C_PLAN.md):
- DI/EI/HALT intrinsics
- IM2 setup (ld i,a; im 2)
- ISR wrappers (SP switch, push/pop, ei+reti)
- Boot relocation (LDIR)

Everything else can be plain C.
