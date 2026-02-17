;
; crt0.asm — Startup code for RC702 autoload PROM
;
; This file contains the parts that must stay in assembly:
; - Self-relocation loop (runs from ROM at 0x0000, copies to RAM at 0x7000)
; - Interrupt vector table (page-aligned at 0x7300)
; - NMI stub (RETN at fixed ROM offset 0x0066)
; - DISINT display interrupt handler (timing-critical DMA reprogramming)
; - HDINT, FLPINT, DUMINT interrupt wrappers
;
; After relocation, sets up SP and calls _main in C code.
;

	SECTION	BOOT
	ORG	0x0000

	EXTERN	_main
	EXTERN	_flpint_body

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
; (filled by assembler with the payload data that follows MOVADR)
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
	JP	_main			; Enter C code

;------------------------------------------------------------------------
; DISINT — Display interrupt handler (timing-critical DMA reprogramming)
;
; Implements circular-buffer hardware scrolling using DMA channels 2 and 3.
; Must stay in assembly due to tight timing requirements.
;------------------------------------------------------------------------

	PUBLIC	_disint_handler

; Display buffer and scroll offset — fixed RAM addresses
_DSPSTR		EQU	0x7800
_SCROLLOFFSET	EQU	0x7FF5

; Port definitions for DMA and CRT
SMSK	EQU	0xFA			; DMA single mask register
CLBP	EQU	0xFC			; DMA clear byte pointer
CH2ADR	EQU	0xF4			; DMA Ch2 address
WCREG2	EQU	0xF5			; DMA Ch2 word count
CH3ADR	EQU	0xF6			; DMA Ch3 address
WCREG3	EQU	0xF7			; DMA Ch3 word count
CRTCOM	EQU	0x01			; CRT command register
CTCCH2	EQU	0x0E			; CTC channel 2

_disint_handler:
DISINT:
	PUSH	AF
	IN	A, (CRTCOM)		; Read 8275 status to acknowledge interrupt

	PUSH	HL
	PUSH	DE
	PUSH	BC

	; Mask (disable) DMA channels 2 and 3 during reprogramming
	LD	A, 0x06			; Channel 2, bit2=1 -> mask
	OUT	(SMSK), A
	LD	A, 0x07			; Channel 3, bit2=1 -> mask
	OUT	(SMSK), A
	OUT	(CLBP), A		; Clear byte pointer flip-flop

	; Ch2: start address = DSPSTR + SCROLLOFFSET
	LD	HL, (_SCROLLOFFSET)
	LD	DE, _DSPSTR
	ADD	HL, DE			; HL = absolute scroll start
	LD	A, L
	OUT	(CH2ADR), A
	LD	A, H
	OUT	(CH2ADR), A

	; Ch2: word count = 1999 - SCROLLOFFSET
	LD	A, L
	CPL
	LD	L, A
	LD	A, H
	CPL
	LD	H, A
	INC	HL			; HL = -(DSPSTR + S)
	LD	DE, 1999
	ADD	HL, DE
	LD	DE, _DSPSTR
	ADD	HL, DE			; HL = 1999 - S
	LD	A, L
	OUT	(WCREG2), A
	LD	A, H
	OUT	(WCREG2), A

	; Ch3: start address = DSPSTR
	LD	HL, _DSPSTR
	LD	A, L
	OUT	(CH3ADR), A
	LD	A, H
	OUT	(CH3ADR), A

	; Ch3: word count = 1999
	LD	HL, 1999
	LD	A, L
	OUT	(WCREG3), A
	LD	A, H
	OUT	(WCREG3), A

	; Unmask (enable) DMA channels 2 and 3
	LD	A, 0x02			; Unmask channel 2
	OUT	(SMSK), A
	LD	A, 0x03			; Unmask channel 3
	OUT	(SMSK), A

	POP	BC
	POP	DE
	POP	HL

	; Re-arm CTC channel 2 for next display interrupt
	LD	A, 0xD7			; Int enable, counter, prescale=16, falling, TC follows, reset
	OUT	(CTCCH2), A
	LD	A, 0x01			; Time constant = 1
	OUT	(CTCCH2), A

	POP	AF
	RET

;------------------------------------------------------------------------
; HDINT — Display interrupt entry (CTC Ch2)
; DI -> CALL DISINT -> EI -> RETI
;------------------------------------------------------------------------

HDINT:
	DI
	CALL	DISINT
	EI
	RETI

;------------------------------------------------------------------------
; FLPINT — Floppy interrupt entry (CTC Ch3)
; DI -> JP to C handler
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
; 16 entries x 2 bytes = 32 bytes
;------------------------------------------------------------------------

	ALIGN	256
INTVEC:
	DW	DUMINT			; +0:  Dummy
	DW	DUMINT			; +2:  PIO Port A (keyboard)
	DW	DUMINT			; +4:  PIO Port B
	DW	DUMINT			; +6:  Dummy
	DW	DUMINT			; +8:  CTC CH0
	DW	DUMINT			; +10: CTC CH1
	DW	HDINT			; +12: CTC CH2 - Display interrupt
	DW	FLPINT			; +14: CTC CH3 - Floppy interrupt
	DW	DUMINT			; +16: Dummy
	DW	DUMINT			; +18: Dummy
	DW	DUMINT			; +20: Dummy
	DW	DUMINT			; +22: Dummy
	DW	DUMINT			; +24: Dummy
	DW	DUMINT			; +26: Dummy
	DW	DUMINT			; +28: Dummy
	DW	DUMINT			; +30: Dummy

;------------------------------------------------------------------------
; Display buffer and scroll offset (absolute addresses in RAM)
; These are not part of the ROM payload — they're fixed RAM locations.
;------------------------------------------------------------------------

; Payload length
PAYLOADLEN	EQU	0x0798		; 1944 bytes (matches original ROM)
