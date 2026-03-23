/* RC700 autoload PROM linker script for LLVM-Z80 (ld.lld)
 *
 * ROM layout (4096 bytes max):
 *   0x0000  BOOT section (entry, init_fdc, banner, NMI handler)
 *   0x0068  CODE payload (copied to RAM by _start)
 *
 * RAM layout (after self-relocation by _start):
 *   0x7300  CODE section (IVT + C code + rodata + bss)
 *   0xBFFF  Stack (grows downward)
 */

ENTRY(__start)

MEMORY {
  ROM (rx)  : ORIGIN = 0x0000, LENGTH = 4096
  RAM (rwx) : ORIGIN = 0x7300, LENGTH = 0x4D00
}

SECTIONS {
  /* BOOT section — runs from ROM at 0x0000 */
  .boot : {
    *boot.o(.text*)
  } > ROM

  /* CODE section — VMA in RAM at 0x7300, LMA in ROM after BOOT */
  __code_load = .;
  .text 0x7300 : AT(__code_load) {
    __code_start = .;
    *intvec.o(.rodata*)        /* IVT first (16 function pointers) */
    *intvec.o(.text*)
    *rom.o(.text*)             /* All C code */
    *rom.o(.rodata*)           /* Constants, strings */
  } > RAM

  .data : AT(LOADADDR(.text) + SIZEOF(.text)) {
    *(.data*)
  } > RAM

  .bss : {
    __bss_start = .;
    *(.bss*)
    *(COMMON)
    __bss_end = .;
  } > RAM

  __code_end = .;
  __code_size = __code_end - __code_start;

  /* Verify PROM fits in 4096 bytes */
  __prom_end = __code_load + __code_size;
  ASSERT(__prom_end <= 4096, "PROM exceeds 4096 bytes!")

  /DISCARD/ : {
    *(.comment)
    *(.eh_frame*)
    *(.note*)
    *(.addrsig)
  }
}
