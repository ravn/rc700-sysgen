; crt0.asm — RC702 CP/M BIOS startup, JP table, IVT, fixed-address variables
;
; This file provides the binary layout expected by the RC702 ROM bootstrap:
;   Offset 0x000: Boot entry (DW CBOOT pointer, ' RC702' identification)
;   Offset 0x080: CONFI configuration parameters (128 bytes)
;   Offset 0x100: Character conversion tables (384 bytes)
;   Offset 0x280: INIT code (relocate binary, init hardware, JP to BIOS)
;   Offset 0x580: BIOS JP table (17 entries at runtime address 0xDA00)
;
; The ROM loads Track 0 to address 0x0000, reads the first word (0x0280),
; and jumps there.  The INIT code copies everything to 0xD480+ (runtime
; position), then jumps to the BIOS cold boot entry at 0xDA00.
;
; z88dk note: ASMPC is section-relative (starts at 0), but org 0xD480
; makes the linker resolve all labels at runtime addresses (0xD480+).
; The binary includes 0xD480 bytes of leading zeros which are stripped
; by the Makefile (dd skip=54400).

    SECTION CODE

    org 0xD480

; Base address constant for offset calculations (ASMPC is section-relative)
START equ 0xD480

; ====================================================================
; Boot entry (offset 0x000, runtime 0xD480)
; ====================================================================

    defw 0x0280             ; CBOOT: physical address for ROM bootstrap
    defs 6                  ; padding (zeros)
    defm " RC702"           ; identification string (6 bytes)

    ; Pad to offset 0x080 (runtime 0xD500)
    defs (0xD500 - START) - ASMPC

; ====================================================================
; CONFI configuration parameters (offset 0x080, runtime 0xD500)
; Hardware init values — CONFI.COM reads/writes these on Track 0 Sector 2
; ====================================================================

; ConfiBlock struct layout (see bios.h ConfiBlock typedef).
; C code accesses via CFG macro at runtime address 0xD500.
; Labels kept for Makefile symbol verification.

; CTC channels (+0x00)
            defb 0x47       ; ctc_mode0: timer mode (ch0, SIO-A baud)
            defb 0x01       ; ctc_count0: divisor 1 = 38400 baud (REL30)
            defb 0x47       ; ctc_mode1: timer mode (ch1, SIO-B baud)
            defb 0x20       ; ctc_count1: divisor 32 = 1200 baud
            defb 0xD7       ; ctc_mode2: counter mode (ch2, display)
            defb 0x01       ; ctc_count2: interrupt after 1 count
            defb 0xD7       ; ctc_mode3: counter mode (ch3, floppy)
            defb 0x01       ; ctc_count3: interrupt after 1 count

; SIO channel A init block (+0x08, 9 bytes)
_psioa:     defb 0x18       ; channel reset
            defb 0x04       ; select WR4
            defb 0x44       ; 1 stop, no parity, x16 clock (8-N-1)
            defb 0x03       ; select WR3
            defb 0xC1       ; RX enable, auto enable, 8 bits/char
            defb 0x05       ; select WR5
            defb 0x60       ; RTS off, DTR off, TX disable, 8 bits
            defb 0x01       ; select WR1
            defb 0x1B       ; enable RX, TX, ext status interrupts

; SIO channel B init block (+0x11, 11 bytes)
_psiob:     defb 0x18       ; channel reset
            defb 0x02       ; select WR2
            defb 0x10       ; interrupt vector (offset for CTC2 gap)
            defb 0x04       ; select WR4
            defb 0x47       ; 1 stop, even parity, x16 clock
            defb 0x03       ; select WR3
            defb 0x60       ; auto enable, 7 bits/char, RX disable
            defb 0x05       ; select WR5
            defb 0x20       ; RTS off, TX off, DTR off, 7 bits
            defb 0x01       ; select WR1
            defb 0x1F       ; enable all interrupts, status affects vector

; DMA channel modes (+0x1C)
            defb 0x48       ; dmode0: ch0 (HD — write)
            defb 0x49       ; dmode1: ch1 (floppy — write)
            defb 0x4A       ; dmode2: ch2 (display — read)
            defb 0x4B       ; dmode3: ch3 (display — read)

; CRT 8275 display parameters (+0x20)
            defb 0x4F       ; par1: 80 chars/row
            defb 0x98       ; par2: 25 rows, VRTC timing
            defb 0x7A       ; par3: underline pos 8, 11 lines/char
            defb 0x6D       ; par4: non-blink block cursor (REL30)

; FDC specify command (+0x24)
            defb 3          ; fdprog_len: program length
            defb 0x03       ; fdprog_cmd: SPECIFY command
            defb 0xDF       ; fdprog_srt: step rate 3ms, head unload 240ms
            defb 0x28       ; fdprog_hlt: head load 40ms, DMA mode

; CONFI defaults (+0x28)
            defb 0x00       ; cursor_num
            defb 0x00       ; conv_num (0 = Danish)
            defb 0x06       ; baud_a: rate index A (1200 default display)
            defb 0x06       ; baud_b: rate index B (1200 default display)
            defb 0x00       ; xyflg: addressing mode (0=XY, 1=YX)
            defw 250        ; stptim: motor stop timer (250 * 20ms = 5 sec)

; Drive format config (+0x2F, 17 bytes: 16 drives + terminator)
            defb 8          ; infd[0]: drive A — maxi floppy 1.1MB
            defb 8          ; infd[1]: drive B — mini floppy 0.8MB
            defb 32         ; infd[2]: drive C — hard disk 1MB (floppy emu)
            defb 255,255,255,255,255,255,255,255,255,255,255,255,255
            defb 255        ; infd[16]: terminator

; HD partition config (+0x40)
            defb 2          ; ndtab
            defb 2, 0, 0    ; ndt1

; CTC2 HD board (+0x44)
            defb 0xD7       ; ctc2_mode4: counter mode
            defb 0x01       ; ctc2_count4: interrupt after 1
            defb 0x03       ; ctc2_mode5: channel reset

; Boot disk (+0x47)
            defb 0          ; ibootd: 0 = floppy boot

    ; Pad to offset 0x100 (runtime 0xD580)
    defs (0xD580 - START) - ASMPC

; ====================================================================
; Character conversion tables (offset 0x100, runtime 0xD580)
; 384 bytes placeholder: 128 output + 256 input.
; The actual conversion data lives on the disk image (written by
; CONFI.COM) and is loaded by the autoload PROM along with the rest
; of Track 0.  The BIOS binary only needs the placeholder space so
; that cboot and the JP table remain at the correct offsets.
; Identity tables are generated programmatically at boot time;
; disk-resident tables (if any) can be loaded by CONFI.COM.
; ====================================================================

; ConvTables layout: 128 bytes outcon + 256 bytes inconv = 384 bytes.
; C accesses the runtime copy at 0xF680 via CONV macro (bios.h).
; This disk-resident copy at 0xD580 (CONVTA_ADDR) can be memcpy'd there.
    defs 384

; ====================================================================
; INIT code (offset 0x280, runtime 0xD700 = CBOOT entry point)
; ROM bootstrap jumps here at physical address 0x0280.
; After LDIR relocation, all label references are valid.
; ====================================================================

    EXTERN _bios_hw_init
    EXTERN _bios_boot_c

_cboot:
    di

    ; Relocate binary from load address (0x0000) to runtime address (0xD480)
    ld hl, 0
    ld de, 0xD480           ; START
    ld bc, 0xF800 - 0xD480 + 1  ; copy through DSPSTR (same as original)
    ldir

    ; Zero BSS (uninitialized static variables, not in binary)
    EXTERN __bss_compiler_head, __bss_compiler_size
    ld hl, __bss_compiler_head
    ld (hl), 0
    ld de, __bss_compiler_head + 1
    ld bc, __bss_compiler_size - 1
    ldir

    ; Set up stack (use DMA buffer area temporarily)
    ld sp, 0x80             ; BUFF

    ; Call C hardware initialization (sets up IM2 from C IVT array)
    call _bios_hw_init

    ; Jump to BIOS cold boot entry (relocated JP table)
    jp 0xDA00

    ; Pad to JP table (offset 0x580, runtime 0xDA00)
    defs (0xDA00 - START) - ASMPC

; ====================================================================
; BIOS jump table (offset 0x580, runtime 0xDA00)
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
; JTVARS — configuration variables at fixed addresses (0xDA33)
; External programs (CONFI.COM etc.) depend on these positions.
; ====================================================================

    EXTERN _bios_wfitr, _bios_reads, _bios_linsel
    EXTERN _bios_exit, _bios_clock, _bios_hrdfmt

; JTVARS storage (labels/PUBLIC now in bios.h via __at)
    defb 0          ; 0xDA33: adrmod
    defb 0          ; 0xDA34: wr5a
    defb 0          ; 0xDA35: wr5b
    defb 0          ; 0xDA36: mtype
    defs 16         ; 0xDA37-0xDA46: fd0 (drive format table)
    defb 0xFF       ; 0xDA47: terminator
    defb 0          ; 0xDA48: bootd

; ====================================================================
; Extended jump table (0xDA49+)
; ====================================================================

jt_resv0:   defs 1              ; 0xDA49: reserved
jt_wfitr:   jp _bios_wfitr      ; 0xDA4A: format utility entry
jt_reads:   jp _bios_reads      ; 0xDA4D: reader status
jt_linsel:  jp _bios_linsel     ; 0xDA50: line selection
jt_exit:    jp _bios_exit       ; 0xDA53: exit routine
jt_clock:   jp _bios_clock      ; 0xDA56: real time clock
jt_hrdfmt:  jp _bios_hrdfmt     ; 0xDA59: format hard disk
    defs 16                 ; 0xDA5C-0xDA6B: reserved

; Misc fixed bytes
    defs 3                  ; 0xDA6C-0xDA6E
PUBLIC _pchsav
_pchsav:    defw 0          ; 0xDA6F: saved BDOS patch address

; ====================================================================
; Interrupt vector table — now defined as a C array in bios.c and
; copied to IVT_ADDR (0xF600, page-aligned) by bios_hw_init().
; ====================================================================

; ====================================================================
; Fixed-address variables (0xFFD0-0xFFFF)
; Now defined in bios.h via __at(). These DEFCs are no longer needed.
; ====================================================================

; ====================================================================
; Other fixed addresses (still needed by crt0.asm code)
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
