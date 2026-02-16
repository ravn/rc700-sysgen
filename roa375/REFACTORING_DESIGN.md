# ROA375 Refactoring Design

## Goal

Rewrite the ROA375 autoload PROM in C (with minimal assembly stubs) to
produce a functionally equivalent but maintainable boot ROM.  The result
no longer needs to be byte-identical to the original — success is defined
as booting CP/M in both the MAME and jbox RC702 emulators.

## Why refactor

The current `roa375.asm` is a reverse-engineered reconstruction of a 2 KB
Z80 ROM.  While useful as documentation, it is difficult to modify, test,
or extend (e.g. adding hard-disk boot support or diagnostic output).
A C rewrite makes the boot logic readable, testable on a host machine,
and accessible to contributors who don't write Z80 assembly.

## Toolchain: z88dk with zsdcc backend

z88dk is the best fit for a 2 KB bare-metal Z80 ROM:

- **Code density**: 5–15% overhead vs hand assembly — fits in 2 KB.
- **Port I/O**: `__sfr __at` declarations give direct `IN`/`OUT` access
  without inline assembly.
- **Interrupts**: `__interrupt` keyword for IM2 handler functions.
- **Host testing**: The `+test` target compiles to a native binary with
  mock hardware, enabling unit tests without an emulator.
- **Active project** with good Z80 bare-metal documentation.

## What must stay in assembly

Some parts cannot be expressed in C or are too timing-sensitive:

| Component              | Size      | Reason                                    |
|------------------------|-----------|-------------------------------------------|
| Self-relocation loop   | ~30 bytes | Runs before RAM is available at 0x0000    |
| Interrupt vector table | 32 bytes  | Must be page-aligned, fixed layout        |
| NMI stub (RETN)        | 2 bytes   | Fixed ROM offset                          |
| DISINT (display ISR)   | ~40 bytes | Timing-critical DMA reprogramming         |

These would live in a `crt0.asm` startup file that hands off to `main()`.

## Proposed source layout

```
crt0.asm        Self-relocation bootstrap, vector table, NMI stub
hal.h           Hardware abstraction: port definitions, function prototypes
hal_z80.c       Real hardware implementation (__sfr declarations)
hal_host.c      Mock hardware for host-native testing
init.c          PIO, CTC, DMA, CRT initialization sequences
boot.c          Boot logic: drive detection, catalogue verification
fdc.c           FDC driver: density auto-detect, read, seek, retries
isr.c           Interrupt handlers (DISINT may need inline asm)
fmt.c           Format tables (FMTLKP, CALCTB, sector interleave)
test_boot.c     Host unit tests for boot logic
test_fdc.c      Host unit tests for FDC state machine
```

## Hardware abstraction layer

The HAL isolates all port I/O behind a C interface so the same boot logic
compiles for both the real Z80 target and a host test harness:

```c
// hal.h — hardware abstraction interface
void hal_fdc_command(uint8_t cmd);
uint8_t hal_fdc_status(void);
void hal_dma_setup(uint8_t channel, uint16_t addr, uint16_t count, uint8_t mode);
void hal_prom_disable(void);
uint8_t hal_diskette_size(void);   // 0 = maxi/8", 1 = mini/5.25"
void hal_motor(uint8_t on);
void hal_beep(void);
```

The Z80 implementation uses `__sfr __at` for zero-overhead port access:

```c
// hal_z80.c
__sfr __at 0x14 port_sw1;
__sfr __at 0x18 port_ramen;

void hal_prom_disable(void) { port_ramen = 0; }
uint8_t hal_diskette_size(void) { return (port_sw1 >> 7) & 1; }
```

The host implementation records calls for test assertions:

```c
// hal_host.c
static uint8_t mock_sw1 = 0x80;  // default: mini floppy
uint8_t hal_diskette_size(void) { return (mock_sw1 >> 7) & 1; }
```

## Boot sequence in C (sketch)

```c
void main(void) {
    init_pio();
    init_ctc();
    init_dma();
    init_crt();
    display_banner();

    if (try_hard_disk_boot())
        jump_to_system();

    uint8_t size = hal_diskette_size();
    if (try_floppy_boot(size))
        jump_to_system();

    if (check_prom1_signature())
        jump_to_prom1();

    display_error("NO DISKETTE NOR LINEPROG");
    halt();
}
```

## Verification approach

Since the refactored ROM is not byte-identical to the original:

1. **Host unit tests** — verify logic in isolation:
   - Catalogue sector parsing and validation
   - Density detection state machine (FM → MFM transitions)
   - Retry/error handling paths
   - Format table lookups for both mini and maxi diskettes

2. **Emulator boot tests** — verify the complete ROM:
   - Boots CP/M from 8" diskette image in MAME (`mame rc702`)
   - Boots CP/M from 5.25" diskette image in MAME
   - Boots in jbox emulator (http://www.jbox.dk/rc702/)
   - PROM1 detection works (with test ROM via new MAME bank2 support)
   - "NO DISKETTE NOR LINEPROG" shown when no boot media present

3. **Size constraint** — final binary must fit in 2048 bytes (0x800).

## RC702 vs RC703 PROM control differences

The RAMEN port semantics changed between RC702 and RC703:

| Port  | RC702                              | RC703 (page 15)                        |
|-------|------------------------------------|----------------------------------------|
| 0x18  | Disable both PROMs, enable RAM     | Enable both PROMs                      |
| 0x19  | (mirror of 0x18)                   | Disable both PROMs                     |
| 0x1A  | (mirror of 0x18)                   | Enable PROM1 (disable PROM0)           |
| 0x1B  | (mirror of 0x18)                   | Disable both PROMs                     |

The RC702 uses incomplete address decoding (ports mirrored in groups of 4),
so 0x18–0x1B all behave identically.  The RC703 decodes individual addresses,
giving finer control — notably 0x1A enables PROM1 while disabling PROM0,
allowing the line program to take over from the boot ROM.

This is why `rob358.mac` (RC703) uses port 0x19 for `RAMEN` while `roa375`
(RC702) uses port 0x18 — both disable both PROMs, but on the RC703 the
address matters.

## Open questions

- **CRT init tables**: The original ROM has ~200 bytes of CRT controller
  setup data.  Keep as a C array, or leave in the assembly crt0?
- **Stack location**: Original uses 0x73FF (just below vector table at
  0x7300).  z88dk's crt0 would need to set SP before calling main().
- **Relocation target**: Original relocates to 0x7000.  The z88dk linker
  needs an ORG directive matching this, with the crt0 stub at 0x0000.
