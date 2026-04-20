/* cpnos-rom linker script for LLVM-Z80 (ld.lld)
 *
 * Physical ROM (two EPROMs on the RC702):
 *   PROM0 at 0x0000, 2KB
 *   PROM1 at 0x2000, 2KB
 * Both are disabled by a single OUT (0x18,A) executed from runtime code
 * that has already been copied into high RAM at 0xF580+.
 *
 * Runtime RAM layout (after PROM disable):
 *   0xF580  BIOS jump table
 *   0xF5C0  BIOS resident code (stubs into SNIOS)
 *   ... stack, IVT, conv_tables, display, workarea untouched
 *
 * Phase 0 skeleton: everything fits in PROM0, PROM1 is 0xFF-padded by
 * the Makefile.  Subsequent phases will place runtime-resident code in
 * a separate section whose LMA is in PROM and VMA is at 0xF580+;
 * coldboot code memcpys it into place.
 */

ENTRY(_reset)

MEMORY {
  PROM0 (rx) : ORIGIN = 0x0000, LENGTH = 2048
  PROM1 (rx) : ORIGIN = 0x2000, LENGTH = 2048
  /* Runtime-resident BIOS lands here after cold boot copies it out of ROM. */
  RESIDENT (rwx) : ORIGIN = 0xF580, LENGTH = 0x80
  /* Scratch RAM for init-only variables used before PROM disable. */
  SCRATCH (rwx) : ORIGIN = 0xE000, LENGTH = 0x1000
}

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

  .prom1 0x2000 : {
    *(.prom1)
    *(.prom1.*)
  } > PROM1

  __prom1_end = .;
  ASSERT(__prom1_end <= 0x2800, "PROM1 code overflowed 2KB!")

  .resident 0xF580 : AT(__prom0_end) {
    __resident_start = .;
    *(.resident)
    *(.resident.*)
    __resident_end = .;
  } > RESIDENT

  __resident_size = __resident_end - __resident_start;

  .scratch_bss (NOLOAD) : {
    *(.bss*)
    *(COMMON)
  } > SCRATCH

  /DISCARD/ : {
    *(.comment)
    *(.eh_frame*)
    *(.note*)
    *(.addrsig)
  }
}
