/* cpnos-rom linker script for LLVM-Z80 (ld.lld)
 *
 * Physical ROM (two EPROMs on the RC702):
 *   PROM0 at 0x0000, 2KB
 *   PROM1 at 0x2000, 2KB
 * Both are disabled by a single OUT (0x18,A) executed from runtime code
 * that has already been copied into high RAM at 0xF200+ (was 0xF580
 * before session #24; moved down to fit SNIOS within the resident chunk).
 *
 * Runtime RAM layout (after PROM disable):
 *   0xF200  BIOS jump table
 *   0xF233  SNIOS jump table + body
 *   0xF40E  BIOS resident code (stubs into SNIOS, console I/O)
 *   0xF4B3  CFGTBL
 *   ... display, workarea (0xF800+) untouched
 *
 * Phase 0 skeleton: everything fits in PROM0, PROM1 is 0xFF-padded by
 * the Makefile.  Subsequent phases will place runtime-resident code in
 * a separate section whose LMA is in PROM and VMA is at 0xF580+;
 * coldboot code memcpys it into place.
 */

ENTRY(_reset)

MEMORY {
  /* PROM0 is the only physical EPROM we program.  PROM1 used to hold
   * netboot_mpm at 0x2000 but was merged into PROM0 in Phase 18
   * (issue #39).  The RC702's PROM1 socket is still wired — we just
   * burn 0xFF into that chip or leave it empty. */
  PROM0 (rx) : ORIGIN = 0x0000, LENGTH = 2048
  /* Runtime-resident BIOS lands here after cold boot copies it out of ROM. */
  /* Resident grows up to just below conv_tables (0xF780 in the planned
     memory map — see rcbios-in-c/tasks/cpnos-rom-plan.md). Phase 1 has
     no IVT or 8275 DMA chain yet, so the region that eventually hosts
     those (0xF680..0xF7FF) is temporarily available. Tighten this once
     the IVT lands. */
  /* BIOS_BASE moved from 0xF580 to 0xF200 in session #24 to fit SNIOS
     (~460B) alongside BIOS jump table + stubs.  Costs ~0x380 of TPA
     headroom relative to the original plan; acceptable given Phase 1 is
     still well under the 56KB TPA target.  Update cpnos-rom-plan.md
     concrete memory map when revisiting TPA numbers. */
  /* Session 33 follow-up (2026-04-22): BIOS_BASE moved from 0xF200 down
   * to 0xED00.  +1.25 KB of RESIDENT headroom for SNIOS growth.  SCRATCH
   * (BSS) + cold-boot stack region move with it.  User plans to tighten
   * back up after memory optimisation; the cpnos-build monolith's cpbios
   * trampolines were rebuilt in step.  See GitHub issue #34 for the
   * SPR-relocatable monolith plan that would remove this coupling. */
  RESIDENT (rwx) : ORIGIN = 0xED00, LENGTH = 0xB00
  /* Scratch RAM for BSS (netboot msgbuf, diag breadcrumbs).
   * Session #27 shifted CCP+NDOS one more page down after observing
   * SP=0xE199 with CCP at 0xD400 (stack_symbol resolves to ~base +
   * 0xD99, not the ~0xB99 we guessed last revision — CCP's BSS/stack
   * extends ~3.5 KB past code_len).  Layout, generously sized so the
   * memory map can absorb more BSS discoveries without another move:
   *   CCP   0xD000..0xDDFF   (2.5 KB code; BSS up to ~0xDD99)
   *   NDOS  0xDE00..0xE9FF   (3 KB code; est. BSS up to ~0xEB99)
   *   BSS   0xEC00..0xED1F   (0x400 gap to stack bottom)
   *   STACK 0xF200 down      (~0x4EB = 1.2 KB)
   * TPA 0x0100..0xCFFF = ~51.75 KB.  Move CCP back up later once we
   * have a precise number for CCP+NDOS true extents. */
  /* SCRATCH (BSS) relocated 0xEC00 -> 0xEA20 in step with BIOS_BASE.
   * 256 B (up to 0xEB20) is enough for current BSS (239 B) with slack.
   * Stack lives in 0xEB20..0xED00 (480 B) — cold-boot SP = 0xED00. */
  SCRATCH (rwx) : ORIGIN = 0xEA20, LENGTH = 0x100
}

/* IVT location shared with init.c (setup_ivt).  Defined here so the
 * ASSERTs below can check for overlap with .resident / .scratch_bss
 * after those sections are placed.  Issue #35. */
__ivt_start = 0xEC00;
__ivt_end   = __ivt_start + 18 * 2;

SECTIONS {
  .reset 0x0000 : {
    KEEP(*(.reset))
    KEEP(*(.reset.*))
  } > PROM0

  .init : {
    *(.text.init)
    *(.text.init.*)
    *(.text*)
    *(.rodata*)
  } > PROM0

  __prom0_end = .;
  ASSERT(__prom0_end <= 0x0800, "PROM0 code overflowed 2KB!")

  /* .resident's LMA follows the init code in PROM0.  Guard below
   * ensures init + resident LMA fits inside 2 KB. */
  .resident 0xED00 : AT(__prom0_end) {
    __resident_start = .;
    /* BIOS jump table MUST come first — its entries are the BIOS's
     * public ABI (BOOT at +0, WBOOT at +3, CONST at +6, ...). */
    KEEP(*(.resident.jumptable))
    KEEP(*(.resident.snios_jt))
    KEEP(*(.resident.snios))
    KEEP(*(.resident.isr))
    *(.resident)
    *(.resident.*)
    KEEP(*(.resident.data))
    __resident_end = .;
  } > RESIDENT

  ASSERT(_bios_boot == 0xED00, "BIOS jump table must start at 0xED00")
  ASSERT(_bios_conout - _bios_boot == 12, "BIOS CONOUT offset must be +12")
  ASSERT(_bios_sectran - _bios_boot == 48, "BIOS SECTRAN offset must be +48")

  __resident_lma = LOADADDR(.resident);
  __resident_size = __resident_end - __resident_start;
  __resident_lma_end = __resident_lma + __resident_size;

  /* Hard guard: init code + resident LMA must fit in the physical
   * 2 KB PROM0.  Without this assert the Makefile's `dd bs=2048` step
   * silently truncates the tail of the resident chunk and the cold
   * boot runs corrupt code. */
  ASSERT(__resident_lma_end <= 0x0800,
         "init + resident LMA overflowed 2 KB PROM0!")

  /* Guard: resident code must not overflow the RESIDENT region (below
     display RAM at 0xF800; really below conv_tables at 0xF680). */
  ASSERT(__resident_end <= 0xF800, "Resident chunk overflowed into display RAM!")

  .scratch_bss (NOLOAD) : {
    __scratch_bss_start = .;
    *(.bss*)
    *(COMMON)
    __scratch_bss_end = .;
  } > SCRATCH

  ASSERT(__scratch_bss_end <= 0xEB20,
         "scratch_bss overflowed into stack region!")

  /* Issue #35: guard against the class of bug where .resident (or BSS)
   * silently overlaps the IVT so memcpy-from-LMA clobbers setup_ivt's
   * writes.  Root-caused in session 33 follow-up when BIOS_BASE moved
   * and IVT at 0xF100 fell inside the new .resident range. */
  ASSERT(__ivt_end <= __resident_start || __ivt_start >= __resident_end,
         "IVT overlaps .resident — memcpy will clobber setup_ivt writes")
  ASSERT(__ivt_end <= __scratch_bss_start || __ivt_start >= __scratch_bss_end,
         "IVT overlaps .scratch_bss — BSS clear will clobber IVT")

  /DISCARD/ : {
    *(.comment)
    *(.eh_frame*)
    *(.note*)
    *(.addrsig)
  }
}
