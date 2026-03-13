; crt0.asm — RC702 CP/M BIOS startup, JP table, IVT, fixed-address variables
;
; Binary layout on disk (Track 0):
;   Offset 0x000: Boot sector (128 bytes) — boot pointer, " RC702", _cboot
;   Offset 0x080: CONFI config block + Danish conversion tables (512 bytes)
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

    EXTERN _bios_hw_init
    EXTERN __BOOT_tail, __BIOS_head
    EXTERN __bss_compiler_head, __bss_compiler_size

; CP/M memory layout — derived from MSIZE, same as BIOS.MAC.
MSIZE   EQU 56                      ; available memory excl. BIOS (KB)
BIAS    EQU (MSIZE - 20) * 1024
CPMB    EQU 0x3400 + BIAS           ; CCP base
CPML    EQU 0x1600                  ; CCP + BDOS length
BIOSAD  EQU CPMB + CPML             ; BIOS base (= 0xDA00 for 56K)

; ====================================================================
; BOOT section (physical address 0x0000)
;
; First sector of Track 0.  The ROM reads the first word as the boot
; pointer (physical address to jump to after loading Track 0 to 0x0000).
; The " RC702" signature at offset 8 identifies the disk as a system disk.
;
; NOTE: The original CP/M boot sector had a simple jump instruction here, but
; we have moved the relocating boot code (_cboot) here as there was room, and
; it keeps logic simpler which the sdcc linker likes.
;
; _cboot follows the signature, fitting within the 128-byte boot sector.
; Assembled at 0x0000 — the address where it actually executes.
; ====================================================================

    SECTION BOOT

    org 0x0000

    defw _cboot             ; +0x00: boot pointer (physical address of _cboot)
    defs 6                  ; +0x02: reserved (zeros)
    defm " RC702"           ; +0x08: system signature (6 bytes)

    INCLUDE "builddate.inc"

_cboot:                     ; cold boot init code
    di

    ; Relocate BIOS section from physical to runtime address.
    ; On disk: BOOT (config data) then BIOS (JP table + C code).
    ; The ROM loaded Track 0 to 0x0000, so BIOS sits at physical
    ; address __BOOT_tail.  Copy it to __BIOS_head (0xDA00).

    ld hl, __BOOT_tail              ; physical source
    ld de, __BIOS_head              ; runtime destination (0xDA00)
    ld bc, __bss_compiler_head - __BIOS_head  ; code + rodata + data size
    ldir

    ; Copy CONFI block and conversion tables from disk to runtime addresses.
    ; confi.bin (128 bytes) at physical 0x080 → CPMB+0x1100 (init-only, CCP area)
    ; danish.bin (384 bytes) at physical 0x100 → 0xF680 (ConvTables)

    ld hl, 0x0080               ; physical source (confi.bin in BOOT)
    ld de, CPMB + 0x1100        ; CONFI runtime address (CCP area, init-only)
    ld bc, 128                  ; CONFI block size
    ldir
    ; HL now at 0x0100, copy danish.bin to ConvTables
    ld de, 0xF680               ; ConvTables runtime address
    ld bc, 384                  ; outcon(128) + inconv(256)
    ldir

    ; Zero BSS (uninitialized static variables, not in binary)
    ld hl, __bss_compiler_head
    ld (hl), 0
    ld de, __bss_compiler_head + 1
    ld bc, __bss_compiler_size - 1
    ldir

    ; Set up stack (use DMA buffer area temporarily)
    ld sp, 0x80             ; BUFF

    ; Call C hardware initialization (relocated, runs at runtime address)
    call _bios_hw_init

    ; Jump to BIOS cold boot entry (relocated JP table)
    jp BIOSAD

    defs 128 - ASMPC        ; pad to end of boot sector (128 bytes total)

; ====================================================================
; CONFI config block + conversion tables (offset 0x080-0x280)
;
; Sectors 2-5: CONFI block (128 bytes) + Danish tables (384 bytes).
; Read-only defaults; CONFI.COM writes updated config here.
; ====================================================================

    BINARY "confi.bin"          ; 128 bytes at offset 0x080
    BINARY "danish.bin"         ; 384 bytes at offset 0x100

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
; BIOS jump table (runtime 0xDA00)
; 17 standard CP/M 2.2 entries — addresses are hardcoded by CCP/BDOS
; ====================================================================

    EXTERN _bios_boot, _bios_wboot
    EXTERN _bios_const, _bios_conin, _bios_conout
    EXTERN _bios_list, _bios_punch, _bios_reader
    EXTERN _bios_home, _bios_seldsk
    EXTERN _bios_settrk, _bios_setsec, _bios_setdma
    EXTERN _bios_read, _bios_write
    EXTERN _bios_listst, _bios_sectran

jt_boot:    jp _bios_boot       ; 0xDA00: cold boot
jt_wboot:   jp _bios_wboot      ; 0xDA03: warm boot
jt_const:   jp _bios_const      ; 0xDA06: console status
jt_conin:   jp _bios_conin      ; 0xDA09: console input
jt_conout:  jp _bios_conout     ; 0xDA0C: console output
jt_list:    jp _bios_list       ; 0xDA0F: list output
jt_punch:   jp _bios_punch      ; 0xDA12: punch output
jt_reader:  jp _bios_reader     ; 0xDA15: reader input
jt_home:    jp _bios_home       ; 0xDA18: home disk
jt_seldsk:  jp _bios_seldsk     ; 0xDA1B: select disk
jt_settrk:  jp _bios_settrk     ; 0xDA1E: set track
jt_setsec:  jp _bios_setsec     ; 0xDA21: set sector
jt_setdma:  jp _bios_setdma     ; 0xDA24: set DMA address
jt_read:    jp _bios_read       ; 0xDA27: read sector
jt_write:   jp _bios_write      ; 0xDA2A: write sector
jt_listst:  jp _bios_listst     ; 0xDA2D: list status
jt_sectran: jp _bios_sectran    ; 0xDA30: sector translate

; ====================================================================
; JTVARS — runtime configuration variables at fixed addresses (0xDA33).
;
; Located immediately after the 17-entry CP/M BIOS JP table (0xDA00).
; External programs (CONFI.COM, FORMAT.COM, etc.) depend on these
; exact addresses — they are part of the BIOS ABI.
;
; All fields are initialized to 0 here; bios_hw_init() and bios_boot()
; populate them from the CONFI block (CFG) at boot time.
;
; C code accesses these via the JTVars struct overlay at 0xDA33
; (see bios.h, JT macro).
; ====================================================================

    EXTERN _bios_wfitr, _bios_reads, _bios_linsel
    EXTERN _bios_exit, _bios_clock, _bios_hrdfmt

    defb 0          ; 0xDA33: adrmod — cursor addressing mode.
                    ;   0 = XY (column first, row second) — default.
                    ;   1 = YX (row first, column second).
                    ;   Copied from CFG.xyflg at boot.
                    ;   Controls the ESC 0x06 cursor positioning sequence.

    defb 0          ; 0xDA34: wr5a — SIO channel A WR5 bits-per-char mask.
                    ;   Extracted from CFG.sioa[6] & 0x60 at boot.
                    ;   0x60 = 8-bit chars (REL30), 0x20 = 7-bit (older).
                    ;   Used by CONOUT/LIST to configure SIO WR5 before
                    ;   transmitting, setting the character width field.

    defb 0          ; 0xDA35: wr5b — SIO channel B WR5 bits-per-char mask.
                    ;   Extracted from CFG.siob[8] & 0x60 at boot.
                    ;   Used by PUNCH to set character width on SIO-B.

    defb 0          ; 0xDA36: mtype — machine type identifier.
                    ;   0 = RC700/RC702 (default, set by defb 0 here)
                    ;   1 = RC850/RC855
                    ;   2 = ITT3290
                    ;   3 = RC703
                    ;   Not modified by BIOS; only changed by specialized
                    ;   builds or external programs.

    defs 16         ; 0xDA37-0xDA46: fd0[16] — active drive format table.
                    ;   One format code byte per logical drive (A-P).
                    ;   Initialized from CFG.infd[] at boot (only infd[0]
                    ;   is copied; rest filled as drives are selected).
                    ;   Format codes:
                    ;     0x08 = DD 512 B/S (standard maxi or mini format)
                    ;     0x10 = SS 128 B/S (FM single density)
                    ;     0x18 = DD 256 B/S (MFM double density)
                    ;     0x20 = HD 1 MB (hard disk, floppy emulation)
                    ;     0xFF = drive not present

    defb 0xFF       ; 0xDA47: fd0 terminator.
                    ;   Always 0xFF. Marks end of fd0[] table scan.

    defb 0          ; 0xDA48: bootd — boot device identifier.
                    ;   0x00 = booted from floppy disk.
                    ;   0x01 = booted from hard disk.
                    ;   Set from CFG.ibootd at boot. Used by warm boot
                    ;   to reload CCP/BDOS from the correct device.

; ====================================================================
; Extended jump table (0xDA49+).
;
; RC702-specific BIOS extensions beyond the standard CP/M 2.2 entries.
; Called by CONFI.COM, FORMAT.COM, and other RC702 utilities.
; Addresses are ABI — external programs use hardcoded JP offsets.
; ====================================================================

jt_resv0:   defs 1              ; 0xDA49: reserved byte (alignment)

jt_wfitr:   jp _bios_wfitr      ; 0xDA4A: WFITR — write format track.
                                ;   Entry point for FORMAT.COM to write
                                ;   a formatted track to floppy disk.

jt_reads:   jp _bios_reads      ; 0xDA4D: READS — reader status.
                                ;   Returns SIO-B receive buffer status.
                                ;   Used for serial file transfer (FILEX).

jt_linsel:  jp _bios_linsel     ; 0xDA50: LINSEL — line selector.
                                ;   Controls RC791 Linieselektor (8 V.24
                                ;   inputs → 2 outputs). A=port, B=line.
                                ;   REL22+ added a delay for hardware timing.

jt_exit:    jp _bios_exit       ; 0xDA53: EXIT — delayed warm boot.
                                ;   Sets timer1 countdown and warmjp target.
                                ;   Display ISR decrements timer1; when it
                                ;   reaches 0, jumps to warmjp (warm boot).

jt_clock:   jp _bios_clock      ; 0xDA56: CLOCK — real-time clock display.
                                ;   Reads rtc0:rtc2 and formats HH:MM:SS
                                ;   on screen. Called by user programs.

jt_hrdfmt:  jp _bios_hrdfmt     ; 0xDA59: HRDFMT — format hard disk.
                                ;   Entry point for HD formatting utility.
                                ;   No-op on systems without WD1000 controller.

    defs 16                 ; 0xDA5C-0xDA6B: reserved (16 bytes)
    defs 3                  ; 0xDA6C-0xDA6E: reserved (3 bytes)

; _pchsav at 0xDA6F: saved BDOS patch address for hard disk boot.
; When booting from HD, the BIOS patches a JP in the CCP to skip
; disk login on warm boot.  _pchsav stores the original word so it
; can be restored.  Not used without hard disk support.
    defw 0                  ; 0xDA6F: reserved (was _pchsav)

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
