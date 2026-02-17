;
; crt0.asm — Startup code for RC702 autoload PROM (sccz80 C backend)
;
; This file contains the parts that must stay in assembly:
; - Self-relocation loop (runs from ROM at 0x0000, copies to RAM at 0x7000)
; - Interrupt vector table (page-aligned at 0x7300)
; - NMI stub (RETN at fixed ROM offset 0x0066)
; - DISINT display interrupt handler (timing-critical DMA reprogramming)
; - HDINT, FLPINT, DUMINT interrupt wrappers
; - Hardware init sequences (PIO, CTC, DMA, CRT)
; - HAL functions: hal_fdc_wait_write, hal_fdc_wait_read, hal_delay
; - Utility: clear_screen, init_fdc
;
; All boot logic, FDC driver, and format tables are in C (sccz80).
;

	; External symbols provided by C code
	EXTERN	_main
	EXTERN	_flpint_body

	SECTION	BOOT
	ORG	0x0000

;========================================================================
; ROM ENTRY POINT at 0x0000
;========================================================================

BEGIN:
	DI
	LD	SP, 0xBFFF		; Stack below display buffer
	LD	HL, MOVADR		; Start of payload marker

; Scan for actual code start (skip zeros, find 0xFF marker)
SCANLP:
	LD	A, (HL)
	OR	A
	INC	HL
	JP	Z, SCANLP
	CP	0xFF			; Found marker?
	JP	Z, SKIP
	DEC	HL			; Back up to non-zero byte
SKIP:
	EX	DE, HL			; DE = source address

; Copy payload from ROM to RAM at 0x7000
	LD	HL, 0x7000		; Destination
	LD	BC, PAYLOADLEN		; Byte count
COPYLP:
	LD	A, (DE)
	LD	(HL), A
	INC	DE
	INC	HL
	DEC	BC
	LD	A, C
	OR	B
	JP	NZ, COPYLP
	JP	INIT_RELOCATED		; Jump to relocated init code

;========================================================================
; Space between COPYLP and NMI vector at 0x0066
;========================================================================

	DEFS	0x0066 - $		; Pad to NMI vector address

; NMI handler at ROM offset 0x0066
	RETN

MOVADR:
	DB	0xFF			; Marker byte for relocation scanner

;========================================================================
; RELOCATED CODE SECTION — loaded to 0x7000, executed from there
;========================================================================

	SECTION CODE
	ORG	0x7000

INIT_RELOCATED:
	LD	SP, 0xBFFF		; Reset stack
	LD	A, INTVEC / 0x100	; Interrupt vector page (0x73)
	LD	I, A
	IM	2			; Z80 interrupt mode 2

;------------------------------------------------------------------------
; Inline hardware initialization — saves C function call overhead
;------------------------------------------------------------------------

; init_pio — PIO setup
	LD	A, 0x02
	OUT	(0x12), A		; PIO Port A ctrl: int vector = 2
	LD	A, 0x04
	OUT	(0x13), A		; PIO Port B ctrl: int vector = 4
	LD	A, 0x4F
	OUT	(0x12), A		; Port A: input mode
	LD	A, 0x0F
	OUT	(0x13), A		; Port B: output mode
	LD	A, 0x83
	OUT	(0x12), A		; Port A: int ctrl
	OUT	(0x13), A		; Port B: same

; init_ctc — CTC setup
	LD	A, 0x08
	OUT	(0x0C), A		; Ch0: vector base = 8
	LD	A, 0xE0		; 0x47 | 0x99
	OUT	(0x0C), A		; Ch0: config
	LD	A, 0x20
	OUT	(0x0C), A		; Ch0: TC = 32
	LD	A, 0xE0
	OUT	(0x0D), A		; Ch1: config
	LD	A, 0x20
	OUT	(0x0D), A		; Ch1: TC = 32
	LD	A, 0xD7
	OUT	(0x0E), A		; Ch2: display int
	LD	A, 0x01
	OUT	(0x0E), A		; Ch2: TC = 1
	LD	A, 0xD7
	OUT	(0x0F), A		; Ch3: floppy int
	LD	A, 0x01
	OUT	(0x0F), A		; Ch3: TC = 1

; init_dma — DMA setup
	LD	A, 0x20
	OUT	(0xF8), A		; DMA command
	LD	A, 0xC0
	OUT	(0xFB), A		; Ch0: cascade mode
	XOR	A
	OUT	(0xFA), A		; Unmask ch0
	LD	A, 0x4A
	OUT	(0xFB), A		; Ch2: demand write
	LD	A, 0x4B
	OUT	(0xFB), A		; Ch3: demand write

; init_crt — CRT setup
	XOR	A
	OUT	(0x01), A		; CRT reset
	LD	A, 0x4F
	OUT	(0x00), A		; 80 chars/row
	LD	A, 0x98
	OUT	(0x00), A		; 25 rows
	LD	A, 0x9A
	OUT	(0x00), A		; Underline scan 9
	LD	A, 0x5D
	OUT	(0x00), A		; Cursor config
	LD	A, 0x80
	OUT	(0x01), A		; Load cursor
	XOR	A
	OUT	(0x00), A		; Col 0
	OUT	(0x00), A		; Row 0
	LD	A, 0xE0
	OUT	(0x01), A		; Preset counters

	JP	_main			; Enter C code

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
	PUSH	BC

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
	LD	DE, 1999
	ADD	HL, DE
	LD	DE, _DSPSTR
	ADD	HL, DE
	LD	A, L
	OUT	(WCREG2), A
	LD	A, H
	OUT	(WCREG2), A

	LD	HL, _DSPSTR
	LD	A, L
	OUT	(CH3ADR), A
	LD	A, H
	OUT	(CH3ADR), A

	LD	HL, 1999
	LD	A, L
	OUT	(WCREG3), A
	LD	A, H
	OUT	(WCREG3), A

	LD	A, 0x02
	OUT	(SMSK), A
	LD	A, 0x03
	OUT	(SMSK), A

	POP	BC
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
	PUSH	HL
	CALL	_flpint_body
	POP	HL
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
; Interrupt vector table — must be page-aligned
;------------------------------------------------------------------------

	ALIGN	256
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

;========================================================================
; Assembly utility functions
;========================================================================

; Port addresses
P_FDC_STATUS	EQU	0x04
P_FDC_DATA	EQU	0x05
P_CRT_CMD	EQU	0x01

;------------------------------------------------------------------------
; hal_fdc_wait_write(data) — FASTCALL, data in L
;------------------------------------------------------------------------
	PUBLIC	_hal_fdc_wait_write
_hal_fdc_wait_write:
	ld	d, l
	ld	bc, 0
ww_loop:
	inc	c
	jr	nz, ww_chk
	inc	b
	jr	z, ww_tout
ww_chk:
	in	a, (P_FDC_STATUS)
	and	0xC0
	cp	0x80
	jr	nz, ww_loop
	ld	a, d
	out	(P_FDC_DATA), a
	ld	l, 0
	ret
ww_tout:
	ld	l, 1
	ret

;------------------------------------------------------------------------
; hal_fdc_wait_read() — returns byte in L
;------------------------------------------------------------------------
	PUBLIC	_hal_fdc_wait_read
_hal_fdc_wait_read:
	ld	bc, 0
wr_loop:
	inc	c
	jr	nz, wr_chk
	inc	b
	jr	z, wr_tout
wr_chk:
	in	a, (P_FDC_STATUS)
	and	0xC0
	cp	0xC0
	jr	nz, wr_loop
	in	a, (P_FDC_DATA)
	ld	l, a
	ret
wr_tout:
	ld	l, 0xFF
	ret

;------------------------------------------------------------------------
; hal_delay(outer, inner) — CALLEE convention
;------------------------------------------------------------------------
	PUBLIC	_hal_delay
_hal_delay:
	pop	hl
	pop	de			; E = outer
	pop	bc			; C = inner
	push	hl
dl_outer:
	ld	a, e
	or	a
	ret	z
	ld	b, c
dl_mid:
	xor	a
dl_inner:
	dec	a
	jr	nz, dl_inner
	djnz	dl_mid
	dec	e
	jr	dl_outer

;------------------------------------------------------------------------
; clear_screen — fill display buffer with spaces
;------------------------------------------------------------------------
	PUBLIC	_clear_screen
_clear_screen:
	ld	hl, _DSPSTR
	ld	de, _DSPSTR + 1
	ld	bc, 8 * 208 - 1
	ld	(hl), 0x20
	ldir
	ret

;------------------------------------------------------------------------
; init_fdc — wait for FDC ready, send SPECIFY command
;------------------------------------------------------------------------
	PUBLIC	_init_fdc
_init_fdc:
	ld	bc, 0x00FF
	push	bc
	ld	bc, 0x0001
	push	bc
	call	_hal_delay
if_wait:
	in	a, (P_FDC_STATUS)
	and	0x1F
	jr	nz, if_wait
	ld	l, 0x03
	call	_hal_fdc_wait_write
	ld	l, 0x4F
	call	_hal_fdc_wait_write
	ld	l, 0x20
	jp	_hal_fdc_wait_write

;------------------------------------------------------------------------
; halt_forever — infinite loop (avoids sccz80 defc bug with for(;;))
;------------------------------------------------------------------------
	PUBLIC	_halt_forever
_halt_forever:
	jr	_halt_forever

;------------------------------------------------------------------------
; jump_to(addr) — FASTCALL, addr in HL
; Jump to arbitrary address (used for boot vectors).
;------------------------------------------------------------------------
	PUBLIC	_jump_to
_jump_to:
	jp	(hl)

;------------------------------------------------------------------------
; hal_ei / hal_di — interrupt control (called from C code)
;------------------------------------------------------------------------
	PUBLIC	_hal_ei
_hal_ei:
	ei
	ret

	PUBLIC	_hal_di
_hal_di:
	di
	ret

;------------------------------------------------------------------------
; g_state — boot state structure at fixed RAM address
;------------------------------------------------------------------------
	PUBLIC	_g_state
	DEFC	_g_state = 0xBF00

; Payload length
PAYLOADLEN	EQU	$ - INIT_RELOCATED
