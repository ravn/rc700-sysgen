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

ENTRY(_start)

MEMORY {
  ROM (rx)  : ORIGIN = 0x0000, LENGTH = 4096
  RAM (rwx) : ORIGIN = 0x6000, LENGTH = 0x6000
}

SECTIONS {
  /* BOOT section — runs from ROM at 0x0000.
   * start() at 0x0000 (DI is the first instruction).
   * NMI handler at Z80 hardwired vector 0x0066. */
  .boot : {
    KEEP(*boot.o(.text*))
    KEEP(*boot.o(.pagezero*))
  } > ROM
  .nmi 0x0066 : {
    KEEP(*boot.o(.nmi*))
  } > ROM

  /* CODE section — VMA in RAM at 0x6000, LMA in ROM after BOOT */
  __code_load = .;
  .text 0x6000 : AT(__code_load) {
    __code_start = .;
    KEEP(*intvec.o(.rodata*))  /* IVT: function pointers to ISRs */
    KEEP(*intvec.o(.text*))    /* IVT code */
    *rom.o(.text*)             /* All C code (GC'd by reachability) */
    *rom.o(.rodata*)           /* Constants, strings */
    *runtime.o(.text*)         /* Runtime stubs */
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

  __bss_size = __bss_end - __bss_start;
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
