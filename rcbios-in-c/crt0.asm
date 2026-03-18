; crt0.asm — RC702 CP/M BIOS startup, JP table, IVT, fixed-address variables
;
; Binary layout on disk (Track 0):
;   Offset 0x000: Boot sector (128 bytes) — boot pointer, " RC702", _cboot
;   Offset 0x080: CONFI config block + conversion tables (512 bytes)
;   Offset 0x280: BIOS JP table + resident code (runtime address 0xDA00)
;
; Two sections:
;   BOOT at org 0x0000 — boot sector + config data, physical addresses.
;   BIOS at org 0xDA00 — JP table + resident code, runtime addresses.
;
; The ROM loads Track 0 to address 0x0000, reads the boot pointer from
; offset 0, and jumps there.  _cboot LDIRs the BIOS section from its
; physical location (__BOOT_tail) to its runtime address (__BIOS_head),
; then JPs to 0xDA00.
;
; The Makefile concatenates bios_BOOT.bin and bios_BIOS.bin (trimmed
; to exclude BSS) to produce bios.cim.

; CP/M memory layout — derived from MSIZE, same as BIOS.MAC.
MSIZE   EQU 56                      ; available memory excl. BIOS (KB)
BIAS    EQU (MSIZE - 20) * 1024
CPMB    EQU 0x3400 + BIAS           ; CCP base
CPML    EQU 0x1600                  ; CCP + BDOS length
BIOSAD  EQU CPMB + CPML             ; BIOS base (= 0xDA00 for 56K)

; ====================================================================
; BOOT section (physical address 0x0000)
;
; First sector of Track 0.  Boot pointer + signature + padding,
; followed by CONFI defaults and conversion tables.
;
; The cboot() function (boot_entry.c, compiled into BOOT section)
; is placed after the data blocks by the linker.
; ====================================================================

    SECTION BOOT

    org 0x0000

    EXTERN _cboot

    defw _cboot             ; +0x00: boot pointer (physical address of cboot)
    defs 6                  ; +0x02: reserved (zeros)
    defm " RC702"           ; +0x08: system signature (6 bytes)

    INCLUDE "builddate.inc" ; Timestamp bios for visual verification.

    defs 128 - ASMPC        ; pad to end of boot sector (128 bytes total)

; CONFI defaults (128 bytes) and conversion tables (384 bytes)
; are in boot_data.c, compiled into the BOOT_DATA section.

    SECTION BOOT_DATA       ; CONFI + conversion tables (from boot_data.c)
    SECTION BOOT_CODE       ; cboot() and helpers (from boot_entry.c)

; ====================================================================
; BIOS section — derived from MSIZE, same as BIOS.MAC.
;
; MSIZE  = available memory excluding BIOS (KB)
; BIAS   = (MSIZE - 20) * 1024
; CPMB   = 0x3400 + BIAS        (CCP base)
; BIOS   = CPMB + 0x1600        (CCP + BDOS length)
;
; JP table and all resident BIOS code.  Assembled at runtime address.
; On disk, follows immediately after BOOT section (no padding gap).
; ====================================================================

    SECTION BIOS

    org BIOSAD

; ====================================================================
; BIOS page (runtime 0xDA00-0xDA70) — 113 bytes.
;
; Contains the CP/M JP table (17 entries), JTVARS (22 bytes),
; extended JP table (6 entries), and reserved space.
; All initialized at runtime by init_bios_page() in bios.c,
; called from bios_hw_init() before _cboot jumps to BIOSAD.
; ====================================================================

    defs 113                ; 0xDA00-0xDA70: filled by init_bios_page()

; ====================================================================
; Fixed addresses used by boot code
; ====================================================================

defc _dspstr = 0xF800       ; display refresh memory (80x25)
defc _istack = 0xF600       ; interrupt stack top (grows down from IVT)

; ====================================================================
; Section ordering — declare all code/data sections before BSS so the
; linker places them contiguously in the binary, with BSS last (not
; stored in disk image).  Sections without org pack after previous.
; ====================================================================

    SECTION code_compiler

    SECTION rodata_compiler
    SECTION data_compiler
    SECTION code_l_sccz80
    SECTION code_clib
    SECTION code_string

; ====================================================================
; BSS section — uninitialized data, not stored in disk image.
; Linker places it after the last code/data section.
; Zeroed by cold boot code above. Must end below IVT (0xF600).
; ====================================================================

    SECTION BSS

    SECTION bss_compiler
