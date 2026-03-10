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

; CTC channels
PUBLIC _mode0, _count0
_mode0:     defb 0x47       ; CTC timer mode (ch0, SIO-A baud)
_count0:    defb 0x01       ; divisor 1 = 38400 baud (REL30)
_mode1:     defb 0x47       ; CTC timer mode (ch1, SIO-B baud)
_count1:    defb 0x20       ; divisor 32 = 1200 baud
_mode2:     defb 0xD7       ; CTC counter mode (ch2, display)
_count2:    defb 0x01       ; interrupt after 1 count
_mode3:     defb 0xD7       ; CTC counter mode (ch3, floppy)
_count3:    defb 0x01       ; interrupt after 1 count

; SIO channel A init block (9 bytes, sent via OTIR to port 0x0A)
PUBLIC _psioa
_psioa:     defb 0x18       ; channel reset
            defb 0x04       ; select WR4
            defb 0x44       ; 1 stop, no parity, x16 clock (8-N-1)
            defb 0x03       ; select WR3
            defb 0xC1       ; RX enable, auto enable, 8 bits/char
            defb 0x05       ; select WR5
            defb 0x60       ; RTS off, DTR off, TX disable, 8 bits
            defb 0x01       ; select WR1
            defb 0x1B       ; enable RX, TX, ext status interrupts

; SIO channel B init block (11 bytes, sent via OTIR to port 0x0B)
PUBLIC _psiob
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

; DMA channel modes
_dmode0:    defb 0x48       ; ch0 mode (HD — write, ch0)
_dmode1:    defb 0x49       ; ch1 mode (floppy — write, ch1)
_dmode2:    defb 0x4A       ; ch2 mode (display — read, ch2)
_dmode3:    defb 0x4B       ; ch3 mode (display — read, ch3)

; CRT 8275 display parameters
PUBLIC _par1, _par2, _par3, _par4
_par1:      defb 0x4F       ; 80 chars/row
_par2:      defb 0x98       ; 25 rows, VRTC timing
_par3:      defb 0x7A       ; underline pos 8, 11 lines/char
_par4:      defb 0x6D       ; non-blink block cursor (REL30)

; FDC specify command
PUBLIC _fdprog
_fdprog:    defb 3          ; program length (bytes to send)
            defb 0x03       ; SPECIFY command
            defb 0xDF       ; step rate 3ms, head unload 240ms
            defb 0x28       ; head load 40ms, DMA mode

; CONFI defaults (read/displayed by CONFI.COM)
            defb 0x00       ; cursor number
            defb 0x00       ; conv table number (0 = Danish)
            defb 0x06       ; baud rate index A (1200 default display)
            defb 0x06       ; baud rate index B (1200 default display)
PUBLIC _xyflg
_xyflg:     defb 0x00       ; addressing mode (0=XY, 1=YX)
PUBLIC _cfgstptim
_cfgstptim: defw 250        ; motor stop timer (250 * 20ms = 5 sec)

; Disk format configuration (copied to FD0-FD15 by IDT at init)
PUBLIC _infd0
_infd0:     defb 8          ; drive A: maxi floppy 1.1MB
            defb 8          ; drive B: mini floppy 0.8MB
            defb 32         ; drive C: hard disk 1MB (floppy emu)
            defb 255,255,255,255,255,255,255,255,255,255,255,255,255
            defb 255        ; terminator (INFDXX)

; HD partition config
            defb 2          ; NDTAB
            defb 2, 0, 0    ; NDT1

; CTC2 (HD board)
            defb 0xD7       ; MODE4: counter mode
            defb 0x01       ; COUNT4: interrupt after 1
            defb 0x03       ; MODE5: channel reset

; Boot disk
            defb 0          ; IBOOTD: 0 = floppy boot

    ; Pad to offset 0x100 (runtime 0xD580)
    defs (0xD580 - START) - ASMPC

; ====================================================================
; Character conversion tables (offset 0x100, runtime 0xD580)
; 384 bytes: 128 output + 256 input (extracted from DANISH.MAC)
; Copied to 0xF680 (OUTCON/INCONV) by INIT code at boot.
; ====================================================================

PUBLIC _convta
_convta:
    BINARY "danish.bin"

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

    ; Copy conversion tables to runtime position
    ld hl, _convta          ; source (relocated)
    ld de, 0xF680           ; dest = OUTCON
    ld bc, 384              ; 128 output + 256 input
    ldir

    ; Set up stack (use DMA buffer area temporarily)
    ld sp, 0x80             ; BUFF

    ; Set up Z80 interrupt mode 2
    ld a, _itrtab >> 8      ; high byte of IVT address
    ld i, a
    im 2

    ; Call C hardware initialization
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

    jp _bios_boot           ; 0xDA00: cold boot
    jp _bios_wboot          ; 0xDA03: warm boot
    jp _bios_const          ; 0xDA06: console status
    jp _bios_conin          ; 0xDA09: console input
    jp _bios_conout         ; 0xDA0C: console output
    jp _bios_list           ; 0xDA0F: list output
    jp _bios_punch          ; 0xDA12: punch output
    jp _bios_reader         ; 0xDA15: reader input
    jp _bios_home           ; 0xDA18: home disk
    jp _bios_seldsk         ; 0xDA1B: select disk
    jp _bios_settrk         ; 0xDA1E: set track
    jp _bios_setsec         ; 0xDA21: set sector
    jp _bios_setdma         ; 0xDA24: set DMA address
    jp _bios_read           ; 0xDA27: read sector
    jp _bios_write          ; 0xDA2A: write sector
    jp _bios_listst         ; 0xDA2D: list status
    jp _bios_sectran        ; 0xDA30: sector translate

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

    defs 1                  ; 0xDA49: reserved
    jp _bios_wfitr          ; 0xDA4A: format utility entry
    jp _bios_reads          ; 0xDA4D: reader status
    jp _bios_linsel         ; 0xDA50: line selection
    jp _bios_exit           ; 0xDA53: exit routine
    jp _bios_clock          ; 0xDA56: real time clock
    jp _bios_hrdfmt         ; 0xDA59: format hard disk
    defs 16                 ; 0xDA5C-0xDA6B: reserved

; Misc fixed bytes
    defs 3                  ; 0xDA6C-0xDA6E
PUBLIC _pchsav
_pchsav:    defw 0          ; 0xDA6F: saved BDOS patch address

; ====================================================================
; Interrupt vector table (256-byte aligned, within movable zone)
; Z80 IM2: vector address = I register * 256 + device vector byte
; ASMPC is section-relative; add START to get absolute address for alignment
; ====================================================================

    EXTERN _isr_crt, _isr_floppy, _isr_hd
    EXTERN _isr_sio_b_tx, _isr_sio_b_ext, _isr_sio_b_spec
    EXTERN _isr_sio_a_tx, _isr_sio_a_ext, _isr_sio_a_rx, _isr_sio_a_spec
    EXTERN _isr_pio_kbd, _isr_pio_par

    ; Align to 256-byte boundary (accounting for section base 0xD480)
    defs (256 - ((ASMPC + START) & 0xFF)) & 0xFF

PUBLIC _itrtab
_itrtab:
    defw _isr_dummy         ; CTC1 ch0: SIO-A baud rate (no interrupt)
    defw _isr_dummy         ; CTC1 ch1: SIO-B baud rate (no interrupt)
    defw _isr_crt           ; CTC1 ch2: display refresh
    defw _isr_floppy        ; CTC1 ch3: floppy completion
    defw _isr_hd            ; CTC2 ch0: hard disk (WD1000)
    defw _isr_dummy         ; CTC2 ch1: unused
    defw _isr_dummy         ; CTC2 ch2: unused
    defw _isr_dummy         ; CTC2 ch3: unused
    defw _isr_sio_b_tx      ; SIO ch.B transmitter
    defw _isr_sio_b_ext     ; SIO ch.B external status
    defw _isr_dummy         ; SIO ch.B receiver (dead: RX disabled)
    defw _isr_sio_b_spec    ; SIO ch.B special receive
    defw _isr_sio_a_tx      ; SIO ch.A transmitter
    defw _isr_sio_a_ext     ; SIO ch.A external status
    defw _isr_sio_a_rx      ; SIO ch.A receiver (ring buffer)
    defw _isr_sio_a_spec    ; SIO ch.A special receive
    defw _isr_pio_kbd       ; PIO ch.A: keyboard
    defw _isr_pio_par       ; PIO ch.B: parallel output

PUBLIC _citab
_citab:     defw _itrtab    ; pointer to IVT (read by init for I register)

; ====================================================================
; Dummy interrupt handler
; ====================================================================

PUBLIC _isr_dummy
_isr_dummy:
    ei
    reti

; ====================================================================
; Fixed-address variables (0xFFD0-0xFFFF)
; Now defined in bios.h via __at(). These DEFCs are no longer needed.
; ====================================================================

; ====================================================================
; Other fixed addresses (still needed by crt0.asm code)
; ====================================================================

defc _dspstr = 0xF800       ; display refresh memory (80x25)
defc _outcon = 0xF680       ; output conversion table (128 bytes)
defc _inconv = 0xF700       ; input conversion table (128+128 bytes)
defc _istack = 0xF620       ; interrupt stack top
defc _stack  = 0xF680       ; BIOS driver stack top

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
; BSS section — uninitialized data, not stored in disk image
; Zeroed by cold boot code above. Must end below stack (0xF500).
; ====================================================================

    SECTION BSS
    org 0xEF30

    SECTION bss_compiler
