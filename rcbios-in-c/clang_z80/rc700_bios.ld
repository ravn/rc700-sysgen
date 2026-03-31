/* RC700 CP/M BIOS linker script for LLVM-Z80 (ld.lld)
 *
 * Binary layout (bios.cim, loaded from Track 0 by autoload ROM):
 *
 *   File offset  Section     VMA       Contents
 *   -----------  ----------  --------  ---------------------------------
 *   0x0000       .boot       0x0000    Boot header (128B)
 *   0x0080       .boot_data  0x0080    CONFI defaults + conv tables (512B)
 *   0x0280       .boot_code  0x0280    coldboot + bios_hw_init
 *   varies       .bios_jt    BIOSAD    JP table + JTVARS (113B)
 *                .text       BIOSAD+   BIOS code
 *                .rodata                Constants, strings
 *                .data                  Initialized data
 *                (not in file) .bss     Zeroed by coldboot
 *
 * BOOT sections: LMA = VMA (run in place at physical address).
 * BIOS sections: VMA = BIOSAD (runtime), LMA = contiguous after BOOT.
 *   coldboot() copies BIOS from LMA to VMA before jumping to it.
 *
 * BIOSAD is passed via: ld.lld --defsym BIOSAD=0xDA00
 * MSIZE is passed to clang via: -DMSIZE=56
 */

ENTRY(_coldboot)

MEMORY {
  /* BOOT: physical address space, loaded by ROM to 0x0000 */
  BOOT (rx)  : ORIGIN = 0x0000, LENGTH = 0xC000

  /* BIOS: runtime address space after relocation */
  BIOS (rwx) : ORIGIN = BIOSAD, LENGTH = 0xF600 - BIOSAD
}

SECTIONS {
  /* ================================================================
   * BOOT sections — run at physical address (LMA = VMA)
   * ================================================================ */

  /* Boot header: boot pointer, " RC702" signature, timestamp.
   * Must be exactly at 0x0000. */
  .boot : {
    KEEP(*boot_block.o(.rodata*))
    KEEP(*boot_block.o(.text*))
    KEEP(*boot_block.o(.data*))
  } > BOOT

  /* CONFI defaults (128B) + conversion tables (384B).
   * Must follow boot header at 0x0080. */
  .boot_data 0x0080 : {
    KEEP(*boot_confi.o(.rodata*))
    KEEP(*boot_confi.o(.text*))
    KEEP(*boot_confi.o(.data*))
  } > BOOT

  /* Boot code: coldboot(), relocate_bios(), bios_hw_init().
   * Runs once at physical address, overwritten by CCP after boot. */
  .boot_code 0x0280 : {
    KEEP(*boot_entry.o(.text*))
    KEEP(*boot_entry.o(.rodata*))
    KEEP(*bios_hw_init.o(.text*))
    KEEP(*bios_hw_init.o(.rodata*))
    KEEP(*bios_hw_init.o(.data*))
  } > BOOT

  __boot_end = .;

  /* ================================================================
   * BIOS sections — VMA at BIOSAD, LMA contiguous after BOOT
   *
   * coldboot() copies from __boot_end (LMA) to BIOSAD (VMA).
   * All symbol references resolve to runtime (VMA) addresses.
   * ================================================================ */

  /* Jump vector table — MUST be first in BIOS (at exactly BIOSAD).
   * Contains the CP/M JP table, JTVARS, and extended JP table. */
  .bios_jt BIOSAD : AT(__boot_end) {
    __bios_load = LOADADDR(.bios_jt);
    KEEP(*bios_jump_vector_table.o(.rodata*))
    KEEP(*bios_jump_vector_table.o(.data*))
  } > BIOS

  /* BIOS code */
  .text : AT(LOADADDR(.bios_jt) + SIZEOF(.bios_jt)) {
    *bios_shims.o(.text*)
    *bios.o(.text*)
    *(.text*)
  } > BIOS

  /* Read-only data: strings, tables, DPBs, FDFs */
  .rodata : {
    *bios.o(.rodata*)
    *(.rodata*)
  } > BIOS

  /* Initialized data */
  .data : {
    *(.data*)
  } > BIOS

  __bss_head = .;

  /* BSS — not stored in binary, zeroed by coldboot */
  .bss : {
    __bss_start = .;
    *(.bss*)
    *(COMMON)
    __bss_end = .;
  } > BIOS

  __bss_size = __bss_end - __bss_start;

  /* Size of BIOS code+rodata+data (without BSS) for coldboot memcpy */
  __bios_code_size = __bss_head - BIOSAD;

  /* Total BIOS size including BSS (for overlap checks) */
  __bios_total_end = __bss_end;

  /* ================================================================
   * Assertions
   * ================================================================ */

  /* BSS must not overlap interrupt stack at 0xF600 */
  ASSERT(__bss_end <= 0xF600,
    "BIOS BSS overlaps interrupt stack (0xF600)!")

  /* BIOS code must not overflow into BSS (sanity check) */
  ASSERT(__bss_head >= BIOSAD,
    "BIOS code underflows BIOSAD!")

  /DISCARD/ : {
    *(.comment)
    *(.eh_frame*)
    *(.note*)
    *(.addrsig)
  }
}
