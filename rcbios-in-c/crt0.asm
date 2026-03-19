; crt0.asm — Section ordering and origin addresses for z88dk linker.
;
; All code and data are in C files. This file defines only the binary
; layout: section ordering and origin addresses that z88dk requires.
;
; BOOT sections (physical address 0x0000, loaded by ROM from Track 0):
;   BOOT       — boot header: pointer, signature, builddate (boot_hdr.c)
;   BOOT_DATA  — CONFI defaults + conversion tables (boot_data.c)
;   BOOT_CODE  — cold boot code: cboot(), LDIR helpers (boot_entry.c)
;
; BIOS section (runtime address 0xDA00, relocated by cboot):
;   BIOS       — JP table + JTVARS reservation (filled by init_bios_page)
;   code_compiler, rodata_compiler, data_compiler — compiled C code
;
; BSS (not stored on disk, zeroed by cboot):
;   BSS, bss_compiler

    SECTION BOOT
    org 0x0000

    SECTION BOOT_DATA
    SECTION BOOT_CODE

    SECTION BIOS            ; JP table + JTVARS (const struct from bios_page.c)
    org 0xDA00

    SECTION code_compiler
    SECTION rodata_compiler
    SECTION data_compiler
    SECTION code_l_sccz80
    SECTION code_clib
    SECTION code_string

    SECTION BSS
    SECTION bss_compiler
