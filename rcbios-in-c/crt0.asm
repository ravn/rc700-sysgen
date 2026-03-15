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
    ; _confi_defaults (128 bytes) at physical 0x080 → CPMB+0x1100 (init-only)
    ; _danish_tables  (384 bytes) at physical 0x100 → 0xF680 (ConvTables)

    ld hl, _confi_defaults      ; physical source in BOOT section
    ld de, CPMB + 0x1100        ; CONFI runtime address (CCP area, init-only)
    ld bc, 128                  ; CONFI block size
    ldir
    ; HL now at _danish_tables, copy to ConvTables
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
; CONFI config block (offset 0x080, 128 bytes)
;
; Sector 2: Hardware initialization parameters.
; Read-only defaults; CONFI.COM writes updated config here.
; C code accesses via CFG macro (see ConfiBlock typedef in bios.h).
; ====================================================================

    PUBLIC _confi_defaults

_confi_defaults:
    ; --- CTC (Counter/Timer) channels 0-3, ports 0x0C-0x0F ---
    defb 0x47           ; +0x00 ctc_mode0:  SIO-A baud — timer, auto, TC follows, /16
    defb 0x01           ; +0x01 ctc_count0: divisor 1 → 38400 baud
    defb 0x47           ; +0x02 ctc_mode1:  SIO-B baud — timer, auto, TC follows, /16
    defb 0x20           ; +0x03 ctc_count1: divisor 32 → 1200 baud
    defb 0xD7           ; +0x04 ctc_mode2:  CRT refresh — counter, int, auto, TC follows
    defb 0x01           ; +0x05 ctc_count2: interrupt every pulse
    defb 0xD7           ; +0x06 ctc_mode3:  FDC — counter, int, auto, TC follows
    defb 0x01           ; +0x07 ctc_count3: interrupt every pulse

    ; --- SIO channel A init (serial/reader/punch port), 9 bytes ---
    defb 0x18           ; +0x08 sioa[0]: WR0 — channel reset
    defb 0x04           ; +0x09 sioa[1]: WR0 — select WR4
    defb 0x44           ; +0x0A sioa[2]: WR4 — x16 clock, 1 stop, no parity
    defb 0x03           ; +0x0B sioa[3]: WR0 — select WR3
    defb 0xE1           ; +0x0C sioa[4]: WR3 — 8-bit, auto enables, Rx enable
    defb 0x05           ; +0x0D sioa[5]: WR0 — select WR5
    defb 0x60           ; +0x0E sioa[6]: WR5 — 8-bit Tx, Tx disabled, RTS off, DTR off
    defb 0x01           ; +0x0F sioa[7]: WR0 — select WR1
    defb 0x1B           ; +0x10 sioa[8]: WR1 — Rx/Tx/Ext int enable

    ; --- SIO channel B init (printer port), 11 bytes ---
    defb 0x18           ; +0x11 siob[0]:  WR0 — channel reset
    defb 0x02           ; +0x12 siob[1]:  WR0 — select WR2
    defb 0x10           ; +0x13 siob[2]:  WR2 — int vector base 0x10
    defb 0x04           ; +0x14 siob[3]:  WR0 — select WR4
    defb 0x47           ; +0x15 siob[4]:  WR4 — x16 clock, 1 stop, even parity
    defb 0x03           ; +0x16 siob[5]:  WR0 — select WR3
    defb 0x60           ; +0x17 siob[6]:  WR3 — Rx disabled, auto enables, 7-bit
    defb 0x05           ; +0x18 siob[7]:  WR0 — select WR5
    defb 0x20           ; +0x19 siob[8]:  WR5 — 7-bit Tx, Tx disabled
    defb 0x01           ; +0x1A siob[9]:  WR0 — select WR1
    defb 0x1F           ; +0x1B siob[10]: WR1 — Rx/Tx/Ext int + status affects vector

    ; --- DMA mode registers ---
    defb 0x48           ; +0x1C dmode[0]: ch0 (HD) — single, read, ch0
    defb 0x49           ; +0x1D dmode[1]: ch1 (floppy) — single, read, ch1
    defb 0x4A           ; +0x1E dmode[2]: ch2 (display) — single, read, ch2
    defb 0x4B           ; +0x1F dmode[3]: ch3 (display2) — single, read, ch3

    ; --- 8275 CRT controller reset parameters ---
    defb 0x4F           ; +0x20 par1: 80 chars/row
    defb 0x98           ; +0x21 par2: 25 rows, VRTC timing
    defb 0x7A           ; +0x22 par3: 28 H retrace, 4 V retrace
    defb 0x6D           ; +0x23 par4: 7 lines/char, steady block cursor

    ; --- FDC SPECIFY command ---
    defb 0x03           ; +0x24 fdprog_len: 3 bytes
    defb 0x03           ; +0x25 fdprog_cmd: SPECIFY command
    defb 0xDF           ; +0x26 fdprog_srt: SRT=D(3ms), HUT=F(240ms)
    defb 0x28           ; +0x27 fdprog_hlt: HLT=14(40ms), ND=0(DMA)

    ; --- CONFI.COM display settings ---
    defb 0x00           ; +0x28 cursor_num: blink reverse block
    defb 0x00           ; +0x29 conv_num: Danish/Norwegian
    defb 0x06           ; +0x2A baud_a: index 6 (display only)
    defb 0x06           ; +0x2B baud_b: index 6 (display only)
    defb 0x00           ; +0x2C xyflg: XY cursor addressing
    defw 250            ; +0x2D stptim: motor stop 250×20ms = 5s

    ; --- Drive format table (16 drives + terminator) ---
    defb 0x08           ; +0x2F infd[0]:  A — maxi floppy (8" DD)
    defb 0x08           ; +0x30 infd[1]:  B — maxi floppy
    defb 0x20           ; +0x31 infd[2]:  C — hard disk (1MB)
    defb 0xFF,0xFF,0xFF,0xFF ; infd[3-6]:   D-G not present
    defb 0xFF,0xFF,0xFF,0xFF ; infd[7-10]:  H-K not present
    defb 0xFF,0xFF,0xFF,0xFF ; infd[11-14]: L-O not present
    defb 0xFF           ; +0x3F infd[15]: P not present
    defb 0xFF           ; +0x40 infd[16]: terminator

    ; --- Hard disk partition ---
    defb 0x02           ; +0x41 ndtab: 2 partitions
    defb 0x02, 0x00, 0x00 ; +0x42 ndt1[3]: partition descriptor

    ; --- CTC2 (HD interface board) ---
    defb 0xD7           ; +0x45 ctc2_mode4:  counter, int, auto, TC follows
    defb 0x01           ; +0x46 ctc2_count4: interrupt every pulse
    defb 0x03           ; +0x47 ctc2_mode5:  software reset

    ; --- Boot device ---
    defb 0x00           ; +0x48 ibootd: boot from floppy

    defs 128 - (ASMPC - _confi_defaults) ; pad to 128 bytes

; ====================================================================
; Character conversion tables (offset 0x100, 384 bytes)
;
; Sectors 3-5: outcon (128 bytes) + inconv (256 bytes).
; Copied to runtime address 0xF680 (ConvTables) by _cboot.
; See ConvTables typedef in bios.h.
; ====================================================================

    PUBLIC _danish_tables

_danish_tables:
    ; --- outcon[128]: output conversion (character → display) ---
    ; Identity mapping: all characters pass through unchanged.
    ; CONFI.COM writes national character mappings here.
    ;       x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 xA xB xC xD xE xF
    defb 0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07 ; 0x
    defb 0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F
    defb 0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17 ; 1x
    defb 0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E,0x1F
    defb 0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27 ; 2x  !"#$%&'
    defb 0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x2E,0x2F ;    ()*+,-./
    defb 0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37 ; 3x 01234567
    defb 0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E,0x3F ;    89:;<=>?
    defb 0x40,0x41,0x42,0x43,0x44,0x45,0x46,0x47 ; 4x @ABCDEFG
    defb 0x48,0x49,0x4A,0x4B,0x4C,0x4D,0x4E,0x4F ;    HIJKLMNO
    defb 0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57 ; 5x PQRSTUVW
    defb 0x58,0x59,0x5A,0x5B,0x5C,0x5D,0x5E,0x5F ;    XYZ[\]^_
    defb 0x60,0x61,0x62,0x63,0x64,0x65,0x66,0x67 ; 6x `abcdefg
    defb 0x68,0x69,0x6A,0x6B,0x6C,0x6D,0x6E,0x6F ;    hijklmno
    defb 0x70,0x71,0x72,0x73,0x74,0x75,0x76,0x77 ; 7x pqrstuvw
    defb 0x78,0x79,0x7A,0x7B,0x7C,0x7D,0x7E,0x7F ;    xyz{|}~.

    ; --- inconv[256]: input conversion (keyboard/serial → internal) ---
    ; First 128 bytes: identity (0x00-0x7F)
    defb 0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07 ; 0x
    defb 0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F
    defb 0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17 ; 1x
    defb 0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E,0x1F
    defb 0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27 ; 2x
    defb 0x28,0x29,0x2A,0x2B,0x2C,0x2D,0x2E,0x2F
    defb 0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37 ; 3x
    defb 0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E,0x3F
    defb 0x40,0x41,0x42,0x43,0x44,0x45,0x46,0x47 ; 4x
    defb 0x48,0x49,0x4A,0x4B,0x4C,0x4D,0x4E,0x4F
    defb 0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57 ; 5x
    defb 0x58,0x59,0x5A,0x5B,0x5C,0x5D,0x5E,0x5F
    defb 0x60,0x61,0x62,0x63,0x64,0x65,0x66,0x67 ; 6x
    defb 0x68,0x69,0x6A,0x6B,0x6C,0x6D,0x6E,0x6F
    defb 0x70,0x71,0x72,0x73,0x74,0x75,0x76,0x77 ; 7x
    defb 0x78,0x79,0x7A,0x7B,0x7C,0x7D,0x7E,0x7F

    ; High 128 bytes: Danish keyboard mapping (RC702 keyboard scan codes)
    ; Maps RC702 keyboard codes 0x80-0xFF to CP/M character codes.
    ; Non-identity entries are Danish special characters (Æ, Ø, Å etc.)
    ;       x0   x1   x2   x3   x4   x5   x6   x7
    defb 0x80,0x01,0x82,0x03,0x04,0x05,0x86,0x87 ; 8x
    defb 0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x8F
    defb 0x10,0x91,0x92,0x93,0x14,0x15,0x96,0x97 ; 9x
    defb 0x18,0x19,0x1A,0x1B,0x1C,0x9D,0x1E,0x9F
    defb 0x20,0x31,0x32,0x33,0x34,0x35,0x36,0x37 ; Ax
    defb 0x38,0x39,0xAA,0x30,0x2D,0xAD,0x2E,0x8B
    defb 0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37 ; Bx
    defb 0x38,0x39,0xBA,0x30,0x2D,0xBD,0x2E,0x83
    defb 0x12,0x86,0xC2,0xC3,0xC4,0x05,0x82,0xC7 ; Cx
    defb 0x08,0xC9,0x0A,0x84,0x85,0xCD,0xCE,0xCF
    defb 0x81,0xD1,0x87,0xD3,0xD4,0xD5,0x80,0xD7 ; Dx
    defb 0x18,0xD9,0x1A,0xDB,0xDC,0xDD,0xDE,0x30
    defb 0xE0,0x8E,0xE2,0xE3,0xE4,0xE5,0x8A,0xE7 ; Ex
    defb 0xE8,0xE9,0xEA,0x8C,0x8D,0xED,0xEE,0xEF
    defb 0x89,0xF1,0x8F,0xF3,0xF4,0xF5,0x88,0xF7 ; Fx
    defb 0xF8,0xF9,0xFA,0xFB,0xFC,0xFD,0xFE,0x7F

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
    EXTERN _bios_list_body, _bios_punch_body, _bios_reader_body
    EXTERN _bios_home, _bios_seldsk
    EXTERN _bios_settrk, _bios_setsec, _bios_setdma
    EXTERN _bios_read, _bios_write
    EXTERN _bios_listst, _bios_sectran

jt_boot:    jp _bios_boot       ; 0xDA00: cold boot
jt_wboot:   jp _bios_wboot      ; 0xDA03: warm boot
jt_const:   jp _bios_const      ; 0xDA06: console status
jt_conin:   jp _bios_conin      ; 0xDA09: console input
jt_conout:  jp _bios_conout     ; 0xDA0C: console output
jt_list:    jp _bios_list       ; 0xDA0F: list output (shim below)
jt_punch:   jp _bios_punch      ; 0xDA12: punch output (shim below)
jt_reader:  jp _bios_reader     ; 0xDA15: reader input (shim below)
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

    EXTERN _bios_wfitr, _bios_reads_body, _bios_linsel
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

jt_reads:   jp _bios_reads      ; 0xDA4D: READS — reader status (shim below).
                                ;   Returns SIO-A receive buffer status.
                                ;   Used by SNIOS for CP/NET.

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

; CP/M↔sdcccall(1) calling convention shims.
; Entry: CP/M passes byte param in C; sdcccall(1) expects A.
; Exit:  CP/M expects byte return in C; sdcccall(1) returns in A.
; These MUST be in asm — sdcc merges naked C wrappers with callees.

    PUBLIC _bios_list
    PUBLIC _bios_punch
    PUBLIC _bios_reader
    PUBLIC _bios_reads

; Entry shims: ld a,c then jp to body
_bios_list:
    ld a, c
    jp _bios_list_body

_bios_punch:
    push hl
    ld a, c
    call _bios_punch_body
    pop hl
    ret

; Exit shims: call body, ld c,a, ret
; HL preserved — SNIOS callers depend on it (not guaranteed by CP/M ABI,
; but widely assumed by DRI code including SNIOS SEND/RECVBT).
_bios_reader:
    push hl
    call _bios_reader_body
    pop hl
    ld c, a
    ret

_bios_reads:
    push hl
    call _bios_reads_body
    pop hl
    ld c, a
    ret

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
