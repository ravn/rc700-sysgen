/* Minimal linker script for z88dk-ticks benchmark.
 * Code at 0x0100, BSS follows. */
ENTRY(_start)
SECTIONS {
    . = 0x0100;
    .text : {
        *(.text.entry)
        *(.text*)
    }
    .rodata : { *(.rodata*) }
    .data : { *(.data*) }
    .bss : { *(.bss*) }
}
