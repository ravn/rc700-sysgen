# Plan: RC702 CP/M BIOS in C (REL30)

Rewrite the REL30 BIOS in C using z88dk with sdcc backend, following the
same approach as autoload-in-c/ (ROA375 PROM rewrite).

## Goals

- **Functionally equivalent** to the assembly REL30 BIOS
- **Fits on both mini and maxi system tracks** (mini: 6144 bytes, maxi: 9984 bytes)
- **Fixed memory layout preserved** — work area addresses (0xFFD0-0xFFFF),
  display RAM (0xF800-0xFFCF), ring buffers, and all CP/M-visible structures
  must remain at their defined positions
- **Testable on host** via mock HAL (same pattern as autoload-in-c)
- **Tested in MAME** with both mini and maxi disk images
- **No rc700 emulator** — MAME only for now

## Constraints

### Size budget

| Format | System track capacity | Notes |
|--------|----------------------|-------|
| Mini (5.25") | 6144 bytes | T0S0 FM 16×128 + T0S1 MFM 16×256 |
| Maxi (8") | 9984 bytes | T0S0 FM 26×128 + T0S1 MFM 26×256 |

The current assembly REL30 is **6426 bytes** — 282 bytes over the mini budget.
A C rewrite can be more compact if BGSTAR is removed (saves ~382 bytes of code)
and the compiler produces reasonably tight output.  If the C version exceeds
6144 bytes for mini, apply JP→JR optimization in assembly stubs and/or shrink
tables before resorting to removing features.

### Fixed memory addresses

Addresses fall into three categories: **fixed** (visible to CP/M, hardware, or
external programs), **movable** (internal BIOS code and work area), and
**not used** (freed by removing BGSTAR).

**Fixed addresses (must not move):**

```
0x0000-0x00FF  Boot entry (loaded by PROM, contains JP to BIOS cold boot)
0x0003         IOBYTE
0x0004         Current disk (CDISK)
0x0005-0x0007  BDOS entry (JP 0xCC06)
0xC400         CCP load address (56K system)
0xCC00         BDOS load address
0xD480         START (code load point for 56K BIOS)
0xDA00         BIOS jump table (17 entries × 3 bytes = 51 bytes)
0xDA33-0xDA49  BIOS configuration variables (JTVARS)
0xDA4A-0xDA6D  Extended jump table entries (INTJP0-10)
0xF500-0xF67F  ISR stack area (grows downward from 0xF67F)
0xF680-0xF6FF  OUTCON (128B output character conversion table)
0xF700-0xF77F  INCONV (128B input character conversion table)
0xF800-0xFFCF  DSPSTR (2000B display refresh memory, hardware-addressed)
0xFFD0         Unused
0xFFD1-0xFFFF  Display state variables (cursor, timers, RTC)
               Must match layout in src/BIOS.MAC work area block
```

**Movable addresses (0xDB00-0xF4FF) — compiler/linker can freely arrange:**

The entire range from the end of the jump table area (0xDB00) through 0xF4FF
is internal to the BIOS.  The compiler and linker can place code, data, BSS,
and work area variables anywhere in this range.  This includes:

- All BIOS code (functions, ISR bodies, tables)
- HSTBUF (512B host buffer), DIRBF (128B directory buffer)
- ALV/CHK allocation vectors
- Floppy driver state (blocking/deblocking variables)
- Ring buffer pointers and KBBUF
- RXBUF (256B, must remain page-aligned for INC L wraparound trick)
- IVT (must remain 256-byte aligned for Z80 IM2, but position is free)

This flexibility means the C compiler can lay out code and data optimally
without worrying about matching the assembly layout.  Only the page-alignment
constraints for RXBUF and IVT need to be enforced (via linker pragmas).

**Freed by BGSTAR removal:**

The 250-byte BGSTAR bitmap and its associated code are not ported.  The space
is available for code, stack, or other use.

### BIOS jump table (CP/M 2.2 standard)

The 17 standard entries at 0xDA00 **and** the extended entries at 0xDA4A are
hard-coded by the CCP/BDOS and by applications.  The C code must produce JP
instructions at exactly these addresses.  This is best done with a hand-written
assembly stub (like crt0.asm) that defines the jump table and calls into C.

### Interrupt vector table

Z80 IM2 vectors at a 256-byte-aligned address (within the movable zone).
The IVT contains 16 word entries pointing to ISR handlers.

### ISR implementation — all in C

The goal is **close to 100% C code**.  sdcc provides the tools to write ISRs
entirely in C:

- `__interrupt` attribute generates register saves (AF, BC, DE, HL) and
  ends with EI + RETI.  It places EI *before* register saves, which is
  acceptable for the BIOS ISRs because they are fast enough to complete
  before the next interrupt of the same type fires.

- `__critical __interrupt` generates RETN instead of RETI — **do not use**
  for maskable interrupts (leaves IFF1=0 on Z80).

- `__sfr __at` for port I/O compiles to single IN/OUT instructions.

- For ISRs that need SP switching (save main SP, switch to ISR stack),
  use a small inline assembly sequence at the top/bottom of the C ISR:

  ```c
  void isr_sio_rx(void) __interrupt {
      // Inline asm for SP switch (4 instructions)
      __asm
          ld (_savsp), sp
          ld sp, _isrstk
      __endasm;

      // ... pure C ISR body (port reads, ring buffer, flow control) ...

      __asm
          ld sp, (_savsp)
      __endasm;
  }
  ```

  The `__interrupt` attribute handles register saves and EI/RETI around this.
  The SP switch is just 2+2 = 4 assembly instructions embedded in C.

- For the SIO RX ring buffer, the page-aligned INC L trick can be expressed
  as a C operation on the low byte of a pointer, or via a one-line inline
  asm.  The compiler's optimizer may find an equivalent encoding.

- OTIR loops for initialization can use `z88dk_otir()` intrinsic or a
  small inline asm block within the C init function.

**The only assembly file** should be a minimal crt0.asm containing:
- The BIOS JP table at 0xDA00 (must be at a fixed address)
- The IVT DW table (must be 256-byte aligned)
- DEFC definitions for fixed-address variables
- Startup code to set IM2 and jump to C main

Everything else — ISR bodies, display driver, floppy driver, serial driver,
boot sequences — is C with occasional inline asm for Z80-specific tricks.

## Architecture

### Directory structure

```
rcbios/bios-in-c/
  ├── Makefile            Build system (host test + z88dk)
  ├── crt0.asm            Minimal startup: JP table, IVT, DEFC vars
  ├── hal.h               Hardware abstraction (inline for Z80, functions for host)
  ├── hal_host.c          Mock HAL for host testing
  ├── bios.h              Shared declarations, memory layout constants, state structs
  ├── init.c              Hardware initialization (PIO, CTC, SIO, DMA, CRT, FDC)
  ├── console.c           CONOUT, CONIN, CONST (display driver + keyboard)
  ├── serial.c            SIO driver (READER, PUNCH, LIST, ring buffer, flow control)
  ├── floppy.c            Floppy driver (blocking/deblocking, FDC commands, DMA)
  ├── boot.c              BOOT, WBOOT, SELDSK, HOME, SETTRK/SEC/DMA, SECTRAN
  ├── clock.c             CLOCK, SETWARM (RTC access)
  ├── tables.c            DPB tables, format tables, character conversion tables
  ├── isr.c               ISR bodies (CRT refresh, floppy completion, SIO RX/TX)
  ├── test_console.c      Host tests for display logic
  ├── test_floppy.c       Host tests for blocking/deblocking
  ├── test_serial.c       Host tests for ring buffer, flow control
  └── peephole.def        Custom sdcc peephole rules (from autoload-in-c)
```

### Code sections and memory layout

```
Section    Address range    Contents
-------    -------------    --------
INIT       0xD480-0xD9FF    INIT code (runs once, then overwritten by CCP)
JPTABLE    0xDA00-0xDA6D    JP table + JTVARS + extended entries (fixed)
CODE       0xDB00-0xF4FF    BIOS code, data, BSS — freely arranged by linker
                            Includes: functions, DPB tables, ISR bodies,
                            HSTBUF, DIRBF, ALV/CHK, floppy vars, ring buffers,
                            IVT (256-byte aligned), RXBUF (page-aligned)
STACK      0xF500-0xF67F    ISR stack (fixed, grows downward)
CONVTAB    0xF680-0xF77F    Character conversion tables (fixed)
DSPSTR     0xF800-0xFFCF    Display RAM (hardware, not in binary)
WORKAREA   0xFFD0-0xFFFF    Display state (fixed, not in binary, positional)
```

The total binary (.cim) contains INIT + JPTABLE + CODE = 0xD480 to end of
last emitted byte.  For mini, this must be ≤ 6144 bytes.  For maxi, ≤ 9984.

The large movable range (0xDB00-0xF4FF = **6656 bytes**) gives the compiler
plenty of room to arrange code and data without the tight packing constraints
of the assembly version.

### Assembly vs. C split

**Assembly (minimal crt0.asm only):**
- BIOS jump table at 0xDA00 (17 × JP + extended entries, fixed address)
- Interrupt vector table (16 × DW, 256-byte aligned)
- Startup: IM 2 setup, jump to C `bios_init()`
- DEFC definitions for fixed-address variables (0xFFD0+ work area)

**C with inline asm where needed (everything else):**
- ISR handlers: `__interrupt` attribute for register save/EI/RETI,
  inline asm for SP switch (4 instructions per ISR)
- Hardware init: `__sfr` for port I/O, inline asm for OTIR sequences
- All BIOS entry points: BOOT, WBOOT, CONST, CONIN, CONOUT, LIST,
  PUNCH, READER, HOME, SELDSK, SETTRK, SETSEC, SETDMA, READ, WRITE,
  LISTST, SECTRAN, CLOCK, SETWARM, LINSEL
- Floppy blocking/deblocking, FDC commands, DMA setup
- Display driver (escape sequences, scroll, cursor)
- Serial driver (ring buffer, RTS flow control)
- All tables (DPB, format, character conversion)

**Optimization approach:**
- Use `--opt-code-size -SO3` and `--max-allocs-per-node 1000000`
- Custom peephole rules (peephole.def) for RC702-specific patterns
- `--fomit-frame-pointer` to save IX setup overhead
- `__sfr __at` for all port I/O (generates single IN/OUT instructions)
- `sdcccall(1)` register calling convention (params in A/HL/DE)
- Review generated .lis files and add peephole rules for bad patterns
- Profile hot paths (CONOUT, scroll, SIO ISR) and tune if needed

### Memory-mapped variables

Use `__at()` attribute or linker DEFC to place C variables at fixed addresses:

```c
// In bios.h — fixed-address variables
// These are defined in crt0.asm with DEFC and declared extern in C

extern uint8_t curx;        // 0xFFD1: cursor column
extern uint16_t cury;       // 0xFFD2: cursor row offset
extern uint8_t cursy;       // 0xFFD4: CRT row counter
extern uint16_t locbuf;     // 0xFFD5: scroll source pointer
extern uint8_t xflg;        // 0xFFD7: escape state
extern uint16_t locad;      // 0xFFD8: screen address
extern uint8_t usher;       // 0xFFDA: char being output
extern uint8_t adr0;        // 0xFFDE: XY escape coordinate
extern uint16_t timer1;     // 0xFFDF: warm-boot countdown
extern uint16_t timer2;     // 0xFFE1: motor stop countdown
extern uint16_t delcnt;     // 0xFFE3: motor stop delay
extern uint16_t warmjp;     // 0xFFE5: seek delay counter
extern uint8_t fdtimo;      // 0xFFE7: JP opcode for warm boot
extern uint16_t stptim;     // 0xFFEA: motor timer reload
extern uint16_t clktim;     // 0xFFEC: clock/screen-blank timer
extern uint16_t rtc0;       // 0xFFFC: RTC low word
extern uint16_t rtc2;       // 0xFFFE: RTC high word

// Floppy work area (0xF100+)
extern uint8_t sekdsk;      // current seek disk
extern uint16_t sektrk;     // current seek track
// ... etc., all at fixed addresses via DEFC in crt0.asm
```

For host testing, these become regular global variables (no fixed address).

### HAL design

Same pattern as autoload-in-c:

```c
#ifdef HOST_TEST
  // Real functions in hal_host.c with recording/playback
  void hal_fdc_command(uint8_t cmd);
  uint8_t hal_fdc_status(void);
  // ...
#else
  // Z80: inline port I/O via __sfr or small assembly stubs
  __sfr __at 0x04 FDC_PORT;
  __sfr __at 0x05 FDD_PORT;
  #define hal_fdc_status()    (FDC_PORT)
  #define hal_fdc_command(c)  do { FDD_PORT = (c); } while(0)
  // ...
#endif
```

### Build system

```makefile
# Host tests (cc, mock HAL)
make test          # compile + run all test_*.c

# Z80 build (z88dk/sdcc)
make bios          # compile to .cim binary
make bios-mini     # verify size ≤ 6144
make bios-maxi     # verify size ≤ 9984

# MAME testing
make mame-mini     # build, patch onto mini image, boot in MAME
make mame-maxi     # build, patch onto maxi image, boot in MAME
make mame-test     # automated: both mini + maxi, verify signon
```

Uses `patch_bios.py` to write the .cim onto disk images, then launches MAME
with the patched image.

## Implementation phases

### Phase 1: Skeleton + boot

1. Create `bios-in-c/` directory with Makefile, crt0.asm, hal.h, bios.h
2. Implement crt0.asm: JP table at 0xDA00, ISR wrappers, IVT
3. Implement init.c: hardware init (ported from INIT.MAC + INIPARMS.MAC)
4. Implement boot.c: BOOT, WBOOT (load CCP/BDOS from disk)
5. Stub all other BIOS entries (return 0 / no-op)
6. Build and verify: boots to CP/M prompt in MAME (mini)
7. **Milestone: CP/M boots with C BIOS**

### Phase 2: Console I/O

1. Implement console.c: CONST, CONIN (PIO keyboard)
2. Implement CONOUT: basic character output (no escape sequences yet)
3. Add escape sequence parsing (cursor position, clear, scroll)
4. Implement screen scroll (the performance-critical path)
5. Host tests for escape sequences and cursor math
6. **Milestone: interactive console works (type commands, see output)**

### Phase 3: Serial + printer

1. Implement serial.c: READER, PUNCH (SIO Channel A)
2. Implement LIST, LISTST (SIO Channel B — printer)
3. Port ring buffer logic (RXBUF with RTS flow control)
4. ISR bodies for SIO RX/TX
5. Host tests for ring buffer wraparound, flow control thresholds
6. **Milestone: PIP to/from serial port works**

### Phase 4: Floppy driver

1. Implement floppy.c: blocking/deblocking (XREAD, XWRITE)
2. Port FDC command sequences (SPECIFY, SEEK, READ, WRITE)
3. Port DMA setup for disk transfers
4. Port multi-density track 0 handling (CHKTRK)
5. Port motor control (FDSTAR, FDSTOP, timer-based stop)
6. Implement SELDSK with format table lookup
7. Host tests for blocking/deblocking algorithm
8. **Milestone: DIR, TYPE, PIP all work from floppy**

### Phase 5: Tables + remaining

1. Port DPB tables, DPH structures, skew tables (tables.c)
2. Implement CLOCK, SETWARM
3. Implement LINSEL (line selector)
4. Remove BGSTAR code (not ported — saves space)
5. **Milestone: full BIOS feature parity (minus BGSTAR)**

### Phase 6: Size optimization + dual format

1. Measure .cim size, compare to 6144 budget
2. If over budget: apply peephole rules, shrink tables, use JR in asm stubs
3. Verify mini boot (patch onto mini image, test in MAME)
4. Verify maxi boot (patch onto maxi image, test in MAME)
5. Add `make mame-test` for automated dual-format verification
6. **Milestone: boots on both mini and maxi in MAME**

### Phase 7: Integration testing

1. Test with CP/NET (serial file transfer at 38400 baud)
2. Test CONFI.COM (configuration utility)
3. Test multi-drive operation (A: + B:)
4. Stress test: large file copies, directory listings
5. **Milestone: production-ready C BIOS**

## Testing strategy

### Host tests (fast, no emulator)

- **Console**: escape sequence parsing, cursor math, scroll buffer operations
- **Floppy**: blocking/deblocking state machine, sector translation, DPB selection
- **Serial**: ring buffer insert/remove, flow control threshold logic
- **Clock**: RTC read/write, timer decrement

Mock HAL records port I/O sequences for assertion.  All tests run in < 1 second.

### MAME tests (integration)

- Boot mini image → verify signon string appears
- Boot maxi image → verify signon string appears
- Interactive: type DIR, TYPE, PIP commands
- Serial: transfer file via null_modem at 38400 baud
- Multi-drive: switch between A: and B:

Automated via `mame_boot_test.sh` pattern (launch MAME, capture output, grep
for expected strings, timeout on failure).

## Risks and mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| C code too large for mini | Blocks mini support | Remove BGSTAR (382B), tune peephole rules, compress tables |
| ISR timing too slow in C | Missed interrupts | Profile generated code, add peephole rules for hot paths |
| sdcc register usage conflicts | Subtle bugs | Test thoroughly, review .lis output for ISR register clobber |
| Fixed-address variables wrong | CP/M crash | Verify with `make verify` comparing memory map to reference |
| `__interrupt` EI placement | Reentrancy issues | Acceptable: BIOS ISRs are fast; verify no DMA conflicts |
| Inline asm SP switch in ISR | Compiler conflict | `__interrupt` saves regs before our SP switch runs — verify in .lis |

## Non-goals

- Hard disk support (HARDDSK.MAC) — not ported, can be added later
- BGSTAR selective clearing — intentionally removed (unused, saves 382 bytes)
- Byte-exact match with assembly REL30 — not required, functional equivalence only
- 58K BIOS — separate codebase, not in scope
- RC702E / RC703 variants — separate codebases, not in scope
