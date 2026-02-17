;
; crt0.asm — Startup code for RC702 autoload PROM (sdcc sdcccall(1) ABI)
;
; This file contains the parts that must stay in assembly:
; - Self-relocation loop (runs from ROM at 0x0000, copies to RAM at 0x7000)
; - Interrupt vector table (page-aligned at 0x7300)
; - NMI stub (RETN at fixed ROM offset 0x0066)
; - DISINT display interrupt handler (timing-critical DMA reprogramming)
; - HDINT, FLPINT, DUMINT interrupt wrappers
; - Hardware init sequences (PIO, CTC, DMA, CRT)
; - HAL functions: hal_fdc_wait_write, hal_fdc_wait_read, hal_delay
; - Utility: clear_screen, init_fdc, mcopy, mcmp, halt_msg
; - FDC functions: stpdma, rsult, flrtrk, boot7
;
; All other boot logic, FDC driver, and format tables are in C (sdcc).
;

	; External symbols provided by C code
	EXTERN	_main
	EXTERN	_flpint_body
	EXTERN	_errdsp

	; Message strings defined in boot.c (non-static)
	EXTERN	_msg_rc700
	EXTERN	_msg_rc702
	EXTERN	_msg_nosys
	EXTERN	_msg_nocat

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
; Small functions placed in alignment padding gap (saves ~7 bytes)
;------------------------------------------------------------------------

	PUBLIC	_halt_forever
_halt_forever:
	jr	_halt_forever

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

; g_state field offsets
GS_FDCRES	EQU	0		; +0: fdcres[7]
GS_FDCFLG	EQU	7		; +7: fdcflg
GS_DRVSEL	EQU	10		; +10: drvsel
GS_FDCWAI	EQU	12		; +12: fdcwai
GS_CURCYL	EQU	17		; +17: curcyl
GS_CURHED	EQU	18		; +18: curhed
GS_DISKBITS	EQU	28		; +28: diskbits
GS_ERRSAV	EQU	38		; +38: errsav
GS_MEMADR	EQU	32		; +32: memadr
GS_TRBYT	EQU	34		; +34: trbyt

;------------------------------------------------------------------------
; hal_fdc_wait_write(data) — sdcccall(1), data in A; void return
;------------------------------------------------------------------------
	PUBLIC	_hal_fdc_wait_write
_hal_fdc_wait_write:
	ld	d, a
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
ww_tout:
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
; hal_delay(outer, inner) — sdcccall(1), outer in A, inner in E
;------------------------------------------------------------------------
	PUBLIC	_hal_delay
_hal_delay:
	or	a
	ret	z
	ld	d, a			; D = outer count
dl_outer:
	ld	b, e			; B = inner count
dl_mid:
	xor	a
dl_inner:
	dec	a
	jr	nz, dl_inner
	djnz	dl_mid
	dec	d
	jr	nz, dl_outer
	ret

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
	ld	a, 1			; outer = 1
	ld	e, 0xFF			; inner = 0xFF
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

;------------------------------------------------------------------------
; mcopy(dst, src, len) — sdcccall(1): HL=dst, DE=src, [SP+2]=len
; Copy len bytes from src to dst using LDIR.
;------------------------------------------------------------------------
	PUBLIC	_mcopy
_mcopy:
	ex	de, hl			; HL=src, DE=dst (LDIR convention)
	push	hl			; save src
	ld	hl, 4			; offset: 2(push) + 2(retaddr)
	add	hl, sp
	ld	c, (hl)			; C = len
	pop	hl			; HL = src
	ld	b, 0			; BC = len
	ldir
	ret

;------------------------------------------------------------------------
; mcmp(a, b, len) — sdcccall(1): HL=a, DE=b, [SP+2]=len
; Compare len bytes, return L: 0=match, 1=mismatch.
;------------------------------------------------------------------------
	PUBLIC	_mcmp
_mcmp:
	push	hl			; save a
	ld	hl, 4			; offset: 2(push) + 2(retaddr)
	add	hl, sp
	ld	c, (hl)			; C = len
	pop	hl			; HL = a
mc_loop:
	ld	a, (de)
	cp	(hl)
	jr	nz, mc_diff
	inc	hl
	inc	de
	dec	c
	jr	nz, mc_loop
	ld	l, 0			; match
	ret
mc_diff:
	ld	l, 1			; mismatch
	ret

;------------------------------------------------------------------------
; halt_msg(msg, len) — sdcccall(1): HL=msg, E=len
; Copy len bytes from msg to dspstr, then halt forever.
;------------------------------------------------------------------------
	PUBLIC	_halt_msg
_halt_msg:
	ld	c, e			; C = len
	ld	b, 0			; BC = len
	ld	de, _DSPSTR		; DE = dst (0x7800)
	ldir				; copy msg to display
	jp	_halt_forever

;------------------------------------------------------------------------
; stpdma — setup DMA for floppy read
;------------------------------------------------------------------------
	PUBLIC	_stpdma
_stpdma:
	di
	ld	a, 0x05
	out	(SMSK), a		; mask ch1
	ld	a, 0x45
	out	(0xFB), a		; mode: single write ch1
	out	(CLBP), a		; clear byte pointer
	ld	hl, (_g_state + GS_MEMADR)
	ld	a, l
	out	(0xF2), a		; ch1 addr low
	ld	a, h
	out	(0xF2), a		; ch1 addr high
	ld	hl, (_g_state + GS_TRBYT)
	dec	hl			; trbyt - 1
	ld	a, l
	out	(0xF3), a		; ch1 word count low
	ld	a, h
	out	(0xF3), a		; ch1 word count high
	ld	a, 0x01
	out	(SMSK), a		; unmask ch1
	ei
	ret

;------------------------------------------------------------------------
; rsult — read FDC result phase (up to 7 bytes)
;------------------------------------------------------------------------
	PUBLIC	_rsult
_rsult:
	ld	a, 7
	ld	(_g_state + GS_FDCFLG), a ; fdcflg = 7
	ld	de, _g_state + GS_FDCRES  ; DE = &fdcres[0]
	ld	b, 7			; loop counter
rs_loop:
	push	de
	push	bc
	call	_hal_fdc_wait_read	; returns byte in L
	ld	a, l			; save result
	pop	bc
	pop	de
	ld	(de), a			; fdcres[i] = result
	inc	de
	in	a, (P_FDC_STATUS)	; check if FDC still busy
	and	0x10
	jr	z, rs_early		; bit 4 clear → early exit
	djnz	rs_loop
	; All 7 read — error
	ld	a, 0xFE
	jp	_errdsp			; tail call errdsp(0xFE)
rs_early:
	in	a, (0xF8)		; hal_dma_status()
	ld	(de), a			; fdcres[i+1] = dma_status
	ret

;------------------------------------------------------------------------
; flrtrk(cmd) — sdcccall(1): cmd in A
; Send FDC command with optional MFM flag and 7-byte parameter block.
;------------------------------------------------------------------------
	PUBLIC	_flrtrk
_flrtrk:
	ld	c, a			; C = original cmd
	ld	a, (_g_state + GS_DISKBITS)
	rrca				; bit 0 → carry
	ld	a, c			; A = cmd
	jr	nc, ft_nomfm
	or	0x40			; set MFM flag
ft_nomfm:
	ld	d, a			; D = cmd | mfm
	; Compute dh = (curhed << 2) | drvsel
	ld	a, (_g_state + GS_CURHED)
	rlca
	rlca
	ld	hl, _g_state + GS_DRVSEL
	or	(hl)			; A = dh
	ld	e, a			; E = dh
	; Send command
	di
	ld	a, 0xFF
	ld	(_g_state + GS_FDCFLG), a ; fdcflg = 0xFF
	ld	a, d
	call	_hal_fdc_wait_write	; send cmd|mfm
	ld	a, e
	call	_hal_fdc_wait_write	; send dh
	; Check if read/write data command (0x06)
	ld	a, c
	and	0x0F
	cp	0x06
	jr	nz, ft_done
	; Send 7 parameter bytes: curcyl through dtl
	ld	hl, _g_state + GS_CURCYL
	ld	b, 7
ft_parm:
	push	hl
	push	bc
	ld	a, (hl)
	call	_hal_fdc_wait_write
	pop	bc
	pop	hl
	inc	hl
	djnz	ft_parm
ft_done:
	ei
	ret

;------------------------------------------------------------------------
; boot7 — Check boot signature, validate system files, or show error
; Z80 only (HOST_TEST version is a stub in boot.c)
;------------------------------------------------------------------------
	PUBLIC	_boot7
_boot7:
	; Compare 6 bytes at 0x0002 against " RC700"
	ld	hl, 0x0002
	ld	de, _msg_rc700
	ld	bc, 6
	push	bc			; len on stack for mcmp
	call	_mcmp			; returns L: 0=match
	pop	bc
	ld	a, l
	or	a
	jr	nz, b7_try702

	; RC700 boot: scan directory starting at DIROFF + 0x20
	ld	hl, 0x0B80		; 0x0B60 + 0x20
b7_dirloop:
	ld	a, h
	cp	0x0D			; >= 0x0D00?
	jr	nc, b7_nosys
	ld	a, (hl)
	or	a			; empty entry?
	jr	z, b7_skip

	; chk_sysfile(dir, "SYSM")
	push	hl
	ld	de, b7_sysm
	call	b7_chksys
	pop	hl
	jr	nz, b7_nosys

	; dir += 0x20
	ld	de, 0x20
	add	hl, de
	ld	a, (hl)
	or	a
	jr	z, b7_nosys

	; chk_sysfile(dir, "SYSC")
	push	hl
	ld	de, b7_sysc
	call	b7_chksys
	pop	hl
	jr	nz, b7_nosys
	ret				; success — both system files found

b7_skip:
	ld	de, 0x20
	add	hl, de
	jr	b7_dirloop

b7_nosys:
	ld	hl, _msg_nosys
	ld	e, 20
	jp	_halt_msg

b7_try702:
	; Compare 6 bytes at 0x0002 against " RC702"
	ld	hl, 0x0002
	ld	de, _msg_rc702
	ld	bc, 6
	push	bc
	call	_mcmp
	pop	bc
	ld	a, l
	or	a
	jr	nz, b7_nocat
	; Match — jump to boot vector at address 0x0000
	ld	hl, (0x0000)
	jp	(hl)

b7_nocat:
	ld	hl, _msg_nocat
	ld	e, 15
	jp	_halt_msg

; Local subroutine: check directory entry against 4-byte pattern
; HL = dir entry, DE = 4-byte pattern
; Returns Z=match, NZ=mismatch. Clobbers A, B, DE, HL.
b7_chksys:
	inc	hl			; HL = dir + 1
	ld	b, 4
b7_cmp:
	ld	a, (de)
	cp	(hl)
	ret	nz			; mismatch
	inc	hl
	inc	de
	djnz	b7_cmp
	; Check attribute: dir[1+ATTOFF] = dir[8], HL is now at dir+5
	inc	hl			; dir+6
	inc	hl			; dir+7
	inc	hl			; dir+8
	ld	a, (hl)
	and	0x3F
	cp	0x13
	ret				; Z=match, NZ=mismatch

b7_sysm:
	DB	"SYSM"
b7_sysc:
	DB	"SYSC"

;------------------------------------------------------------------------
; g_state — boot state structure at fixed RAM address
;------------------------------------------------------------------------
	PUBLIC	_g_state
	DEFC	_g_state = 0xBF00

; Payload length
PAYLOADLEN	EQU	$ - INIT_RELOCATED
