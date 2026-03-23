/* RC700 bare-metal linker script for LLVM-Z80 (ld.lld)
 *
 * Memory layout:
 *   0x0000  BOOT code (entry point, runs from ROM)
 *   0x7300  IVT + CODE (copied to RAM by begin())
 *   0x7A00  Display buffer (80x25)
 *   0x8200  BSS (uninitialized variables)
 *   0xBFFF  Stack (grows downward)
 */

ENTRY(__start)

SECTIONS {
  . = 0x0000;

  .text : {
    *(.text*)
    *(.rodata*)
  }

  .data : {
    *(.data*)
  }

  .bss : {
    __bss_start = .;
    *(.bss*)
    *(COMMON)
    __bss_end = .;
  }

  __bss_size = __bss_end - __bss_start;

  /DISCARD/ : {
    *(.comment)
    *(.eh_frame*)
    *(.note*)
    *(.addrsig)
  }
}
