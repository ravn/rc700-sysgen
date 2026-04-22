# cpnos-rom: unified 4 KB PROM payload (eliminates PROM0/PROM1 split)

**Origin:** 2026-04-22, after issue #36 (rc700_console integration) exposed how
brittle the PROM0/PROM1-aware linker script is.  .resident LMA crossed the
0x0800 boundary and the Makefile's `dd bs=2048 count=1` / `skip=4` carving
silently lost the bytes in the 0x0800..0x1FFF hardware gap.  `cpnos-install`
had to be extended to copy prom1.ic65 separately; a missed step leaves
MAME reading 0xFF across the LMA region so every `jp _impl_xxx` in
.resident becomes garbage at boot.

## Problem

The two 2 KB EPROMs on PCB530 (physical chips at bus addresses 0x0000 and
0x2000) leak through every layer:

- `cpnos_rom.ld` carries `.prom1` as a separate section with its own VMA=LMA
  at 0x2000, plus `AT(__prom0_end)` or `AT(0x2000)` for .resident LMA
  depending on size.
- The Makefile splits the raw objcopy output with two `dd` invocations —
  anything in the 0x0800..0x1FFF gap is silently discarded.
- `cpnos-install` has to know there are two files.
- MAME's rc702 driver has two separate `ROM_LOAD` entries.
- `build_loader.py` splices `prom0.bin + prom1.bin` for the .COM loader.
- Any code that straddles the physical gap by accident builds cleanly but
  boots to garbage.

None of this complexity is load-bearing: the boot sequence is already
"copy something from ROM into RAM, disable ROM, run from RAM."  The chip
count should be an output-stage concern only.

## Proposal

Treat the ROM as a single 4 KB payload from the linker's perspective.  A
tiny loader stub at PROM0 0x0000 is the *only* code that knows the
physical split.

### Memory map

```
MEMORY {
  LOADER  (rx) : ORIGIN = 0x0000, LENGTH = 64        ; stub in PROM0 head
  PAYLOAD (rx) : ORIGIN = 0x0040, LENGTH = 4032      ; single logical blob
  RESIDENT(rwx): ORIGIN = 0xED00, LENGTH = 0x0B00    ; current VMA
}
```

The linker sees one `.payload` LMA section starting at 0x0040 and growing
contiguously up to 4032 bytes (4 KB minus loader).  Physically the raw
binary has a hole between 0x0800 and 0x2000 (the PCB bus gap), but the
linker doesn't model it.  The Makefile's objcopy emits a flat 4 KB by
emitting `.loader` + `.payload` as one stream, then splits at offset
0x0800 for the burner / install script.

### Loader stub (~30 B in PROM0 0x0000..0x003F)

```asm
reset:
    di
    ld   sp, 0xED00           ; cold stack at top of RESIDENT
    ld   hl, payload_lma_lo   ; = 0x0040 (just after this stub)
    ld   de, payload_vma_lo   ; = wherever linker places .payload VMA
    ld   bc, 0x0800 - 0x0040  ; bytes remaining in PROM0
    ldir
    ld   hl, 0x2000           ; PROM1 base
    ; DE already advanced by first LDIR
    ld   bc, 0x0800           ; all of PROM1
    ldir
    ld   a, 0
    out  (0x18), a            ; disable both PROMs
    jp   payload_entry        ; at .payload VMA start
```

### Payload VMA choice

Must sit above NDOS's eventual BSS ceiling (est. ~0xEB99) and below display
RAM (0xF800).  Easiest: reuse the current `RESIDENT` region at 0xED00+.
Init + netboot + resident all land there.

Size budget check (issue #36 numbers):
- current .init:     0x26D = ~620 B
- current .resident: 0x79E = ~1950 B
- current .prom1:    0x0B3 = ~180 B
- **total:**         0xABA = ~2746 B

That's under the current 0xB00 (2.75 KB) RESIDENT region — but only just.
If the unified payload VMA also lives at 0xED00..0xF7FF (2.75 KB), init
and netboot would have to stay resident too (normally discarded after
boot).  Two options:

**Option A — keep resident region, extend downward.**  Move RESIDENT start
to 0xE800 (4 KB), overlapping NDOS BSS.  The loader writes payload there
before netboot runs; netboot then loads CP/NOS which overwrites
0xD000..0xE99F as usual — but the part of payload used for init/netboot
(call it 0xE800..0xEBFF) gets clobbered.  Fine, because init/netboot have
already finished.  The *resident* half (0xEC00..0xF7FF) survives.

**Option B — two-stage payload.**  Loader copies only the resident portion
to high RAM; init + netboot live at a scratch VMA that gets discarded.
Closer to current design but uses one logical LMA.

Recommend **A** for simplicity.  Layout:

```
0xE800..0xEBFF  init + netboot (throwaway; NDOS BSS clobbers after handoff)
0xEC00..0xEC7F  IVT + scratch breadcrumbs
0xEC80..0xEFFF  SNIOS JT, config, runtime helpers
0xED00..0xF7FF  BIOS JT, impl_*, rc700_console, resident data
```

Exact offsets come out of the linker once .payload is emitted.

### What goes away

- `.prom1` section in cpnos_rom.ld.
- `PROM1_CODE` macro in netboot_mpm.c.
- `AT(0x2000)` / `AT(__prom0_end)` for .resident.
- Separate `MAME_PROM1 = prom1.ic65` step in cpnos-install.
- Special-case dd slicing — replaced by one split at 0x0800.

### Risks

- **netboot runs from high RAM, not PROM.**  Any asm constant in
  snios.s / netboot that assumes a PROM address would break.  Quick
  audit of snios.s needed; I don't think there are any (snios uses RAM
  symbols throughout).
- **Loader must be fully self-contained.**  No calls into runtime.s
  (memcpy/etc) because those are in the payload being copied.  LDIR
  inline covers this.
- **Cold stack and IVT placement.**  Reset stack is at 0xED00; after
  resident_entry runs, it stays.  IVT at 0xEC00 is inside the payload
  VMA if we go with option A — need to guard with ASSERT (issue #35
  already covers this).
- **MAME rc702 driver.**  Currently expects roa375.ic66 (4 KB slot
  padded) and prom1.ic65 (2 KB optional).  Unified scheme still emits
  those two files, just carved from a single blob.  Driver unchanged.

### Knock-on benefits

- Issue #35's IVT-overlap ASSERT stays meaningful but only has to check
  against one payload region.
- `build_loader.py` becomes "cat prom0 prom1 → 4 KB .COM".
- `cpnos-install` becomes `cp prom0.bin roms/rc702/roa375.ic66; cp
  prom1.bin roms/rc702/prom1.ic65` — a one-step output stage.
- Adding rc700_console (or any future resident-side feature) is a
  budget question against one 4 KB number, not a guessing game about
  which half it'll land in.

## Plan

1. Back out the rc700_console integration in impl_conout (keep
   rc700_console.c in tree, no call sites yet).  Restore the inline
   baseline impl_conout so we have a known-good boot to compare
   against during refactor.
2. Write `loader.s` — ~30 B stub at 0x0000 doing SP/LDIR/LDIR/OUT/JP.
3. Rewrite `cpnos_rom.ld` with three memory regions (LOADER / PAYLOAD
   / RESIDENT) and a single `.payload` section covering init + netboot
   + resident + runtime.
4. Remove `.prom1` section, drop `PROM1_CODE` attribute from
   netboot_mpm.c.
5. Update Makefile: single objcopy, single dd split at 0x0800, one
   install target that writes both chips from the same blob.
6. Rebuild, verify boot to A> via `make cpnos-netboot`.
7. Re-land rc700_console integration: wire into impl_conout, add
   rc700_console_init call, verify boot to A>.
8. File follow-up issue for CP/M-BIOS ↔ sdcccall(1) ABI shim hardening
   (cpbios.asm needs push/pop bc/de around the call).

Closing the non-trivial fragilities documented in
tasks/cpnos-next-steps.md "session 33 follow-up" section.
