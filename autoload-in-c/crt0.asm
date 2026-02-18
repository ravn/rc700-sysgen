;
; crt0.asm — Startup code for RC702 autoload PROM (sdcc sdcccall(1) ABI)
;
; PROM image layout (2048 bytes max):
;
;   Section  Address   Contents
;   -------  --------  ----------------------------------------
;   BOOT     0x0000    Entry point: DI, SP setup, CALL relocate, JP INIT
;            0x000A    clear_screen (LDIR fill, runs from ROM)
;            0x0018    init_fdc (FDC ready wait + SPECIFY, runs from ROM)
;            0x0034    display_banner (asm, frees 30 bytes in CODE for C)
;            ...       C code from boot_entry.c (--codeseg BOOT):
;                        relocate() — self-relocation loop
;            gap       Available for more BOOT C code (must fit before 0x0066)
;   NMI      0x0066    RETN (Z80 hardware NMI vector, fixed address)
;   CODE     0x0068+   Payload in ROM, copied to 0x7000 at boot:
;            0x7000      Interrupt vector table (naturally page-aligned)
;            0x7020      INIT_RELOCATED: SP/I/IM2, CALL init_peripherals, JP _main
;            0x702F      DISINT: display interrupt handler (DMA reprogramming)
;            0x7083      HDINT, FLPINT, DUMINT: interrupt entry points
;            0x709C      Small functions: jump_to, hal_ei, hal_di
;            0x70A1      halt_msg + halt_forever
;            0x70AC      b7_sysm, b7_sysc strings
;            ...         C code (sdcc): init_peripherals, hal_z80.c, fdc.c,
;                        fmt.c, boot.c, isr.c
;            ...         Read-only data: format tables, message strings
;
; The BOOT and NMI sections remain in ROM until hal_prom_disable().
; The CODE payload is copied to RAM at 0x7000 by relocate() in boot_entry.c.
; Linker symbols __NMI_tail, __CODE_head, __tail drive the relocation.
;
; Assembly in this file (BOOT + CODE sections):
; - Interrupt vector table (at CODE section start, naturally page-aligned)
; - DISINT display interrupt handler (timing-critical DMA reprogramming)
; - HDINT, FLPINT, DUMINT interrupt wrappers
; - Utility: clear_screen, init_fdc, halt_msg, halt_forever
; - Small functions: jump_to, hal_ei, hal_di
; - String data: b7_sysm, b7_sysc
;
; All other boot logic, FDC driver, and format tables are in C (sdcc).
;

	; External symbols provided by C code
	EXTERN	_main
	EXTERN	_flpint_body
	EXTERN	_errdsp
	EXTERN	_relocate
	EXTERN	_msg_rc700
	EXTERN	_hal_fdc_wait_write
	EXTERN	_hal_delay
	EXTERN	_init_peripherals


	SECTION	BOOT
	ORG	0x0000

;========================================================================
; ROM ENTRY POINT at 0x0000
;========================================================================

BEGIN:
	DI
	LD	SP, 0xBFFF		; Stack below display buffer

; Copy payload from ROM to RAM at 0x7000
	CALL	_relocate		; C function in BOOT section
	JP	INIT_RELOCATED		; Jump to relocated init code

;========================================================================
; Functions in BOOT padding — only used before hal_prom_disable()
; PROM is still mapped here, so these are callable from relocated code.
;========================================================================

; clear_screen — fill display buffer with spaces
	PUBLIC	_clear_screen
_clear_screen:
	ld	hl, 0x7800		; _DSPSTR
	ld	de, 0x7801
	ld	bc, 80 * 25 - 1		; full 80x25 display (original ROM had 8*208-1)
	ld	(hl), 0x20
	ldir
	ret

; init_fdc — wait for FDC ready, send SPECIFY command
	PUBLIC	_init_fdc
_init_fdc:
	; hal_delay is now C (sdcccall(1): outer in A, inner in L).
	; sdcc's DJNZ inner loop is faster than the original dec a/jr nz,
	; so (2, 157) matches the original (1, 0xFF) timing within 0.3%.
	; If hal_delay reverts to assembly, restore to (1, 0xFF) in (A, E).
	ld	a, 2			; outer = 2
	ld	l, 157			; inner = 157
	call	_hal_delay
if_wait:
	in	a, (P_FDC_STATUS)
	and	0x1F
	jr	nz, if_wait
	ld	a, 0x03
	call	_hal_fdc_wait_write
	ld	a, 0x4F
	call	_hal_fdc_wait_write
	ld	a, 0x20
	jp	_hal_fdc_wait_write

; display_banner — write " RC700" to screen, reset scroll, enable CRT
; Written in assembly to free 30 bytes in CODE for C functions.
; Only called from main() before hal_prom_disable(), so safe in BOOT.
	PUBLIC	_display_banner
_display_banner:
	ld	hl, _msg_rc700
	ld	de, _DSPSTR		; 0x7800
	ld	bc, 6
	ldir
	ld	hl, 0
	ld	(_SCROLLOFFSET), hl
	ld	a, 0x23
	out	(CRTCOM), a
	ret

; Gap from here to 0x0066 is available for C code (--codeseg BOOT)

;========================================================================
; NMI handler — must be at ROM offset 0x0066 (Z80 hardware requirement)
;========================================================================

	SECTION	NMI
	ORG	0x0066
	RETN

;========================================================================
; RELOCATED CODE SECTION — loaded to 0x7000, executed from there
;========================================================================

	SECTION CODE
	ORG	0x7000

;------------------------------------------------------------------------
; Interrupt vector table — at 0x7000 (naturally 256-byte page-aligned)
; Z80 IM2: vector address = I * 256 + data_bus_byte
; I register is loaded with INTVEC / 0x100 = 0x70
;------------------------------------------------------------------------

INTVEC:
	DW	DUMINT			; +0:  Dummy
	DW	DUMINT			; +2:  PIO Port A
	DW	DUMINT			; +4:  PIO Port B
	DW	DUMINT			; +6:  Dummy
	DW	DUMINT			; +8:  CTC CH0
	DW	DUMINT			; +10: CTC CH1
	DW	HDINT			; +12: CTC CH2 - Display
	DW	FLPINT			; +14: CTC CH3 - Floppy
	DW	DUMINT			; +16: Dummy
	DW	DUMINT			; +18: Dummy
	DW	DUMINT			; +20: Dummy
	DW	DUMINT			; +22: Dummy
	DW	DUMINT			; +24: Dummy
	DW	DUMINT			; +26: Dummy
	DW	DUMINT			; +28: Dummy
	DW	DUMINT			; +30: Dummy

;------------------------------------------------------------------------
; INIT_RELOCATED — Z80-specific setup, then C peripheral init and main
;------------------------------------------------------------------------

INIT_RELOCATED:
	LD	SP, 0xBFFF		; Reset stack
	LD	A, INTVEC / 0x100	; Interrupt vector page (0x70)
	LD	I, A
	IM	2			; Z80 interrupt mode 2
	CALL	_init_peripherals	; PIO, CTC, DMA, CRT setup (C in init.c)
	CALL	_main			; Enter C code (CALL for stack trace)
	jr	$			; Should never return

;------------------------------------------------------------------------
; DISINT — Display interrupt handler (timing-critical DMA reprogramming)
;------------------------------------------------------------------------

	PUBLIC	_disint_handler

_DSPSTR		EQU	0x7800
_SCROLLOFFSET	EQU	0x7FF5

SMSK	EQU	0xFA
CLBP	EQU	0xFC
CH2ADR	EQU	0xF4
WCREG2	EQU	0xF5
CH3ADR	EQU	0xF6
WCREG3	EQU	0xF7
CRTCOM	EQU	0x01
CTCCH2	EQU	0x0E

_disint_handler:
DISINT:
	PUSH	AF
	IN	A, (CRTCOM)

	PUSH	HL
	PUSH	DE

	LD	A, 0x06
	OUT	(SMSK), A
	LD	A, 0x07
	OUT	(SMSK), A
	OUT	(CLBP), A

	LD	HL, (_SCROLLOFFSET)
	LD	DE, _DSPSTR
	ADD	HL, DE
	LD	A, L
	OUT	(CH2ADR), A
	LD	A, H
	OUT	(CH2ADR), A

	LD	A, L
	CPL
	LD	L, A
	LD	A, H
	CPL
	LD	H, A
	INC	HL
	LD	DE, 80*25-1		; screen length - 1
	ADD	HL, DE
	LD	DE, _DSPSTR
	ADD	HL, DE
	LD	A, L
	OUT	(WCREG2), A
	LD	A, H
	OUT	(WCREG2), A

	XOR	A			; _DSPSTR low = 0x00
	OUT	(CH3ADR), A
	LD	A, _DSPSTR / 256	; _DSPSTR high = 0x78
	OUT	(CH3ADR), A

	LD	A, (80*25-1) & 0xFF	; screen length - 1, low
	OUT	(WCREG3), A
	LD	A, (80*25-1) / 256	; screen length - 1, high
	OUT	(WCREG3), A

	LD	A, 0x02
	OUT	(SMSK), A
	LD	A, 0x03
	OUT	(SMSK), A

	POP	DE
	POP	HL

	LD	A, 0xD7
	OUT	(CTCCH2), A
	LD	A, 0x01
	OUT	(CTCCH2), A

	POP	AF
	RET

;------------------------------------------------------------------------
; HDINT — Display interrupt entry (CTC Ch2)
;------------------------------------------------------------------------

HDINT:
	DI
	CALL	DISINT
	EI
	RETI

;------------------------------------------------------------------------
; FLPINT — Floppy interrupt entry (CTC Ch3)
;------------------------------------------------------------------------

FLPINT:
	DI
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	_flpint_body
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	EI
	RETI

;------------------------------------------------------------------------
; DUMINT — Dummy interrupt handler
;------------------------------------------------------------------------

DUMINT:
	EI
	RETI

;------------------------------------------------------------------------
; Small utility functions
;------------------------------------------------------------------------

	PUBLIC	_jump_to
_jump_to:
	jp	(hl)

	PUBLIC	_hal_ei
_hal_ei:
	ei
	ret

	PUBLIC	_hal_di
_hal_di:
	di
	ret

;------------------------------------------------------------------------
; halt_msg (null-terminated copy + halt_forever) and string data
;------------------------------------------------------------------------

	PUBLIC	_halt_msg
_halt_msg:
	ld	de, _DSPSTR		; DE = dst (0x7800)
hm_lp:
	ld	a, (hl)			; load char
	or	a			; NUL?
	jr	z, _halt_forever	; done — don't copy NUL to display
	ldi				; copy byte, inc HL/DE
	jr	hm_lp			; next char
	PUBLIC	_halt_forever
_halt_forever:
	jr	_halt_forever

	PUBLIC	_b7_sysm
_b7_sysm:
	DB	"SYSM"
	PUBLIC	_b7_sysc
_b7_sysc:
	DB	"SYSC"

;========================================================================
; Constants and data
;========================================================================

; Port address (used by init_fdc in BOOT section)
P_FDC_STATUS	EQU	0x04

;------------------------------------------------------------------------
; g_state — boot state structure at fixed RAM address
;------------------------------------------------------------------------
	PUBLIC	_g_state
	DEFC	_g_state = 0xBF00

