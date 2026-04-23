# CP/NOS RC702 Memory Map

Layout as of 2026-04-23 (Phase 18, branch `snios-compact` — PROM0
down to 0x05F4 = 524 B of slack).  Authoritative source for fixed
addresses is `cpnos_rom.ld`; this document summarizes.  Update both
sides when you move a boundary.

## 64 KB RAM overview

```
0x0000 ┌────────────────────────┐
       │ CP/M reset vectors     │  0x0000=RST0→WBOOT, 0x0005=BDOS JP
       │ 0x0000..0x00FF         │  0x0038=RST7 (IM0 entry — unused)
0x0100 ├────────────────────────┤
       │ TPA                    │  Transient Program Area
       │ 0x0100..0xCFFF         │  51.75 KB available to user code
       │                        │  (M80, L80, user programs, …)
0xD000 ├────────────────────────┤
       │ CP/NOS cold payload    │  Downloaded by netboot_mpm from the
       │ 0xD000..0xDFD9         │  master's A:CPNOS.IMG (4 KB file).
       │                        │    0xD000..0xDDFF  CCP (2.5 KB)
       │                        │    0xDE00..0xE9FF  NDOS (3 KB)
       │                        │    0xDF21          BDOS entry
0xEA00 ├────────────────────────┤
       │ SNIOS resident         │  Our Z80 port of DRI SNIOS (snios.s)
       │ 0xEA00..0xEA1F         │  NDOS expects SNIOS JT here.
       │                        │  cpnios-shim.asm forwards here.
0xEA20 ├────────────────────────┤
       │ SCRATCH (BSS)          │  0xEA20..0xEBFF (widened to 0x200
       │ kbd_head/tail          │    in Phase 18 to host cfgtbl).
       │ 0xEA22..0xEA31 kbd_ring│   0xEA20 kbd_head
       │ 0xEA32 curx            │   0xEA21 kbd_tail
       │ 0xEA33 cury            │   0xEA22..0xEA31  kbd_ring[16]
       │ 0xEA37..0xEAFE cfgtbl  │   0xEA32 curx
       │ (cfgtbl=0xEA37, 173 B) │   0xEA33 cury
       │                        │   0xEA37..0xEAFE  cfgtbl (173 B,
       │                        │                   runtime-init'd)
       │                        │   0xEAFF..0xEBxx  msg[] (netboot)
0xEC00 ├────────────────────────┤
       │ IM2 IVT (36 B)         │  0xEC00..0xEC23 — 18 x u16 ISR ptrs.
       │ Cold-boot stack below  │  SP=0xED00 at cold-boot entry.
       │ (diag breadcrumbs at   │  Diag scratch page 0xEC40..0xECFF
       │  0xEC40..0xECFF were   │  stripped in Phase 18; region free
       │  cleared in Phase 18)  │  for future use (see #47/#48).
0xED00 ├────────────────────────┤
       │ BIOS resident          │  Our retargeted RC702 BIOS, in C:
       │ 0xED00..~0xF24F        │    0xED00  bios JT (51 B, 17 × 3)
       │                        │    0xED33  SNIOS JT local (24 B)
       │                        │    ...     BIOS stubs, ISRs,
       │                        │            console driver, CFGTBL
       │ 2.75 KB region         │  Linker-tracked; ASSERTed ≤ 0xF800.
0xF800 ├────────────────────────┤
       │ 8275 display RAM       │  80×24 char buffer = 1920 B +
       │ 0xF800..0xFFFF         │  conv_tables + workarea (untouched)
0xFFFF └────────────────────────┘
```

## ROM (until `OUT (0x18),A` disables both)

```
0x0000 ┌────────────────────────┐
       │ PROM0  (roa375.ic66)   │  2 KB.  Everything: reset.s, cpnos_main,
       │ 0x0000..0x021B         │  init, netboot_mpm.  Followed by the
       │                        │  resident LMA block (984 B) that is
       │ 0x021C..0x05F3         │  memcpy'd to 0xED00 at cold boot.
0x05F4 ├ 0xFF padding (524 B) ──┤
0x07FF                          │
0x2000 ┌────────────────────────┐
       │ PROM1  (prom1.ic65)    │  Empty.  Socket is wired but the
       │ 0x2000..0x27FF         │  EPROM (if fitted) is all 0xFF.
       │ (unused)               │  netboot_mpm used to live here;
       │                        │  merged into PROM0 in Phase 18
       │                        │  (issue #39).
0x2800 └ 0xFF padding ──────────┘
```

Both PROMs are mapped at boot.  After the resident chunk is copied
to 0xED00..~0xF283 and `OUT (0x18),A` fires, the EPROMs disappear
and RAM shows through at 0x0000 + 0x2000.  Execution is already
running from 0xED00+ when that happens — never branch back into ROM
after the disable.

## Reserved diagnostic slots (RAM 0xEC40..0xECFF)

All prod-build trace bumps were removed in Phase 18 (commit
c54229c).  Page 0xEC40..0xECFF is free for future diagnostic
scratch; reservations from Phase 16-17 are no longer live code.

A MAME Lua tap on CPU-fetch of 0x0005 (in `mame_smoke_dump.lua`)
remains the primary external diagnostic — dumps every BDOS call
(fn, DE, caller, DMA-buffer contents) to `/tmp/cpnos_bdos_trace.txt`.
This lives outside the PROM.

## Key non-address facts

- **CP/M BDOS entry** is at `0x0005`, which is a JP to wherever
  BDOS actually lives (currently 0xDF21, inside the cpnos.com blob
  at 0xD000).
- **NDOS base** is 0xDE00.  The NDOS SNIOS JT stub expects our real
  SNIOS to live at `NDOS_BASE + NDOS_CODELEN = 0xEA00`.  If any
  NDOS/CCP component changes size, 0xEA00 moves — cpnios-shim.asm's
  `rsbase` must be updated in lock-step.
- **Default DMA** after cold boot is 0x0080 (CP/M standard).  M80's
  source-read loop (l4d25) sets its own DMA to `l4447 + k*128`
  starting at ~0xC200 in practice.

## Moving boundaries

Before moving any of these boundaries:
1. Update `cpnos_rom.ld` (MEMORY regions, ORIGIN/LENGTH, ASSERTs).
2. Update the matching `#define` / `equ` in `resident.c`, `snios.s`,
   `cpnios-shim.asm`, and this file.
3. Rebuild `cpnos.com` (so NDOS's baked-in SNIOS JT stub still
   points at the right resident address).
4. Re-run `make cpnet-smoke` to confirm netboot + CCP + M80 still
   land correctly.
