/* Linker script for the CP/NOS composite image (cpnos.com).
 *
 * Places:
 *   .cpnos_code at 0xD000 (code: cpnos stub + cpndos + cpnios + cpbdos + cpbios)
 *   .cpnos_data at 0xCC00 (data: NDOSRL + BDOSDS)
 *
 * Must sit below our cpnos-rom BIOS at 0xED00 and far below display RAM
 * at 0xF800 (hardware-fixed for 8275 DMA).  TPA = 0x0100..0xCBFF.
 *
 * The cpnos stub (cpnos.o) must appear first in .cpnos_code so BOOT
 * ends up at 0xD000 — the entry point cpnos-rom netboot hands control
 * to via FNC=4.
 */

ENTRY(BOOT)

SECTIONS {
    . = 0xCC00;
    .cpnos_data : {
        KEEP(*(.cpnos_data))
    }

    . = 0xD000;
    .cpnos_code : {
        /* cpnos.o first — its BOOT label is the entry point. */
        KEEP(cpnos.o(.cpnos_code))
        *(.cpnos_code)
    }

    /DISCARD/ : {
        *(.comment)
        *(.note*)
        *(.eh_frame*)
    }
}
