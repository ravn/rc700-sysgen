;
; crt0.asm — Startup code for RC702 autoload PROM
;
; This file contains the parts that must stay in assembly:
; - Self-relocation loop (runs from ROM at 0x0000, copies to RAM at 0x7000)
; - Interrupt vector table (page-aligned at 0x7300)
; - NMI stub (RETN at fixed ROM offset 0x0066)
; - DISINT display interrupt handler (timing-critical DMA reprogramming)
; - CRTINT, FLPINT, DUMINT interrupt wrappers
;
; After relocation, sets up SP and calls _main in C code.
;

	SECTION	BOOT
	ORG	0x0000

	; All code is in this file — no external references

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

;------------------------------------------------------------------------
; Inline hardware initialization — saves C function call overhead
; Equivalent to init_pio, init_ctc, init_dma, init_crt, init_fdc in C
;------------------------------------------------------------------------

; init_pio — PIO setup (roa375.asm PIOINT)
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

; init_ctc — CTC setup (roa375.asm CTCINT)
	LD	A, 0x08
	OUT	(0x0C), A		; Ch0: vector base = 8
	LD	A, 0xE0		; 0x47 | 0x99 (mode = 0x99)
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

; init_dma — DMA setup (roa375.asm DMAINT)
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

; init_crt — CRT setup (roa375.asm CRTINT)
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

	JP	_main			; Enter C code (init_fdc + boot logic)

;------------------------------------------------------------------------
; DISINT — Display interrupt handler (timing-critical DMA reprogramming)
;
; Implements circular-buffer hardware scrolling using DMA channels 2 and 3.
; Must stay in assembly due to tight timing requirements.
;------------------------------------------------------------------------

	PUBLIC	_crt_refresh

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

_crt_refresh:
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
; CRTINT — CRT vertical retrace interrupt (CTC Ch2)
; DI -> CALL DISINT -> EI -> RETI
;------------------------------------------------------------------------

CRTINT:
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
	DW	CRTINT			; +12: CTC CH2 - CRT vertical retrace
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

;========================================================================
; Assembly implementations of C functions
;
; Placed AFTER INTVEC so they don't affect ALIGN padding.
; These replace the C versions for the Z80 ROM build, saving space.
; The C versions are kept under #ifdef HOST_TEST for host unit tests.
;========================================================================

; g_state structure offsets (g_state is at 0xBF00 via __at)
GS		EQU	0xBF00
GS_FDCRES	EQU	GS + 0		; fdcres[7]
GS_FDCFLG	EQU	GS + 7
GS_EPTS		EQU	GS + 8
GS_TRKSZ	EQU	GS + 9
GS_DRVSEL	EQU	GS + 10
GS_FDCTMO	EQU	GS + 11
GS_FDCWAI	EQU	GS + 12
GS_CURCYL	EQU	GS + 17
GS_CURHED	EQU	GS + 18
GS_CURREC	EQU	GS + 19
GS_RECLEN	EQU	GS + 20
GS_CUREOT	EQU	GS + 21
GS_GAP3		EQU	GS + 22
GS_DTL		EQU	GS + 23
GS_SECBYT	EQU	GS + 24
GS_FLPFLG	EQU	GS + 26
GS_FLPWAI	EQU	GS + 27
GS_DISKBITS	EQU	GS + 28
GS_DSKTYP	EQU	GS + 29
GS_MOREFL	EQU	GS + 30
GS_REPTIM	EQU	GS + 31
GS_MEMADR	EQU	GS + 32
GS_TRBYT	EQU	GS + 34
GS_TRKOVR	EQU	GS + 36
GS_ERRSAV	EQU	GS + 38

; Port addresses
P_FDC_STATUS	EQU	0x04
P_FDC_DATA	EQU	0x05
P_DMA_CH1ADDR	EQU	0xF2
P_DMA_CH1WC	EQU	0xF3
P_DMA_CMD	EQU	0xF8
P_DMA_SMSK	EQU	0xFA
P_DMA_MODE	EQU	0xFB
P_DMA_CLBP	EQU	0xFC
P_SW1		EQU	0x14
P_RAMEN		EQU	0x18
P_BIB		EQU	0x1C
P_CRT_CMD	EQU	0x01

;------------------------------------------------------------------------
; hal_fdc_wait_write(data) — FASTCALL, data in L
; Wait for FDC RQM=1 DIO=0, then write data byte.
; Returns 0 in L on success, 1 on timeout.
;------------------------------------------------------------------------
	PUBLIC	_hal_fdc_wait_write
_hal_fdc_wait_write:
	ld	d, l			; save data
	ld	bc, 0			; timeout counter
ww_loop:
	inc	c
	jr	nz, ww_chk
	inc	b
	jr	z, ww_tout		; 64K iterations -> timeout
ww_chk:
	in	a, (P_FDC_STATUS)
	and	0xC0
	cp	0x80			; RQM=1, DIO=0?
	jr	nz, ww_loop
	ld	a, d
	out	(P_FDC_DATA), a
	ld	l, 0
	ret
ww_tout:
	ld	l, 1
	ret

;------------------------------------------------------------------------
; hal_fdc_wait_read() — Wait for FDC RQM=1 DIO=1, read data byte.
; Returns byte in L, 0xFF on timeout.
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
	cp	0xC0			; RQM=1, DIO=1?
	jr	nz, wr_loop
	in	a, (P_FDC_DATA)
	ld	l, a
	ret
wr_tout:
	ld	l, 0xFF
	ret

;------------------------------------------------------------------------
; hal_delay(outer, inner) — CALLEE convention
; Triple-nested delay: outer * inner * 256 iterations.
; Stack at entry: ret(2) | outer(2) | inner(2)
;------------------------------------------------------------------------
	PUBLIC	_hal_delay
_hal_delay:
	pop	hl			; HL = return address
	pop	de			; E = outer
	pop	bc			; C = inner
	push	hl			; restore return address
dl_outer:
	ld	a, e
	or	a
	ret	z			; outer == 0 -> done
	ld	b, c			; B = inner count
dl_mid:
	xor	a			; A = 0, will wrap to 255
dl_inner:
	dec	a
	jr	nz, dl_inner		; 256 iterations
	djnz	dl_mid			; inner count
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
	; hal_delay(1, 0xFF): outer=1, inner=0xFF
	; With CALLEE: push inner, push outer, call
	ld	bc, 0x00FF		; C = inner = 0xFF
	push	bc
	ld	bc, 0x0001		; C = outer = 1
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
; mkdhb — returns (curhed << 2) | drvsel in L
;------------------------------------------------------------------------
	PUBLIC	_mkdhb
_mkdhb:
	ld	a, (GS_CURHED)
	rlca
	rlca
	ld	hl, GS_DRVSEL
	or	(hl)
	ld	l, a
	ret

;------------------------------------------------------------------------
; clrflf — clear floppy flag (DI, clear, EI)
;------------------------------------------------------------------------
	PUBLIC	_clrflf
_clrflf:
	di
	xor	a
	ld	(GS_FLPFLG), a
	ei
	ret

;------------------------------------------------------------------------
; snsdrv — sense drive status
;------------------------------------------------------------------------
	PUBLIC	_snsdrv
_snsdrv:
	ld	l, 0x04
	call	_hal_fdc_wait_write
	ld	hl, (GS_DRVSEL)	; L = drvsel
	call	_hal_fdc_wait_write
	call	_hal_fdc_wait_read
	ld	a, l
	ld	(GS_FDCRES), a
	ret

;------------------------------------------------------------------------
; flo4 — recalibrate command (0x07)
;------------------------------------------------------------------------
	PUBLIC	_flo4
_flo4:
	ld	l, 0x07
	call	_hal_fdc_wait_write
	ld	hl, (GS_DRVSEL)	; L = drvsel
	jp	_hal_fdc_wait_write

;------------------------------------------------------------------------
; flo6 — sense interrupt status (0x08)
;------------------------------------------------------------------------
	PUBLIC	_flo6
_flo6:
	ld	l, 0x08
	call	_hal_fdc_wait_write
	call	_hal_fdc_wait_read
	ld	a, l
	ld	(GS_FDCRES), a
	and	0xC0
	cp	0x80
	ret	z			; ST0=0x80 (invalid) -> no PCN read
	call	_hal_fdc_wait_read
	ld	a, l
	ld	(GS_FDCRES + 1), a
	ret

;------------------------------------------------------------------------
; flo7(dh, cyl) — seek command (0x0F) — CALLEE convention
; Stack at entry: ret(2) | dh(2) | cyl(2)
;------------------------------------------------------------------------
	PUBLIC	_flo7
_flo7:
	pop	hl			; return address
	pop	de			; E = dh
	pop	bc			; C = cyl
	push	hl			; restore return address
	ld	l, 0x0F
	call	_hal_fdc_wait_write
	ld	a, e
	and	0x07
	ld	l, a
	call	_hal_fdc_wait_write
	ld	l, c
	jp	_hal_fdc_wait_write

;------------------------------------------------------------------------
; waitfl(timeout) — FASTCALL, timeout in L
; Wait for floppy interrupt. Returns 0=OK, 1=timeout in L.
;------------------------------------------------------------------------
	PUBLIC	_waitfl
_waitfl:
	ld	c, l			; C = timeout counter
wf_loop:
	dec	c
	jr	z, wf_tout
	; Inline delay ~256 iterations (equivalent to hal_delay(1,1))
	xor	a
wf_dly:
	dec	a
	jr	nz, wf_dly
	ld	a, (GS_FLPFLG)
	bit	1, a
	jr	z, wf_loop
	call	_clrflf
	ld	l, 0
	ret
wf_tout:
	ld	l, 1
	ret

;------------------------------------------------------------------------
; flpint_body — floppy interrupt handler body
;------------------------------------------------------------------------
	PUBLIC	_flpint_body
_flpint_body:
	ld	a, 2
	ld	(GS_FLPFLG), a
	; hal_delay(0, fdctmo) is a no-op (outer=0 returns immediately)
	; Just read FDC status directly
	in	a, (P_FDC_STATUS)
	bit	4, a
	jp	nz, _rsult
	jp	_flo6

;------------------------------------------------------------------------
; stpdma(addr, count, mode) — DMA channel 1 setup
; Stack at entry: ret(2) | addr(2) | count(2) | mode(2)
;------------------------------------------------------------------------
	PUBLIC	_stpdma
_stpdma:
	ld	hl, 2
	add	hl, sp
	ld	e, (hl)
	inc	hl
	ld	d, (hl)		; DE = addr
	inc	hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)		; BC = count
	inc	hl
	ld	a, (hl)		; A = mode
	di
	push	af			; save mode
	ld	a, 0x05
	out	(P_DMA_SMSK), a	; mask channel 1
	pop	af
	out	(P_DMA_MODE), a	; set mode
	xor	a
	out	(P_DMA_CLBP), a	; clear byte pointer
	ld	a, e
	out	(P_DMA_CH1ADDR), a
	ld	a, d
	out	(P_DMA_CH1ADDR), a	; set address
	ld	a, c
	out	(P_DMA_CH1WC), a
	ld	a, b
	out	(P_DMA_CH1WC), a	; set word count
	ld	a, 0x01
	out	(P_DMA_SMSK), a	; unmask channel 1
	ei
	ret

;------------------------------------------------------------------------
; rsult — read FDC result phase (up to 7 bytes)
;------------------------------------------------------------------------
	PUBLIC	_rsult
_rsult:
	ld	a, 7
	ld	(GS_FDCFLG), a
	ld	de, GS_FDCRES		; DE = pointer into fdcres
	ld	b, 7			; loop counter
rs_loop:
	push	bc
	push	de
	call	_hal_fdc_wait_read
	ld	a, l
	pop	de
	pop	bc
	ld	(de), a			; fdcres[i] = read byte
	; hal_delay(0, fdcwai) is a no-op (outer=0) — skip
	in	a, (P_FDC_STATUS)
	bit	4, a
	jr	nz, rs_next
	; FDC no longer in result phase — read DMA status
	inc	de
	in	a, (P_DMA_CMD)
	ld	(de), a
	ret
rs_next:
	inc	de
	djnz	rs_loop
	ld	l, 0xFE
	jp	_errdsp

;------------------------------------------------------------------------
; chkres — check FDC result status bytes
; Returns 0=OK, 1=retry, 2=exhausted in L
;------------------------------------------------------------------------
	PUBLIC	_chkres
_chkres:
	ld	a, (GS_FDCRES)
	and	0xC3
	ld	c, a
	ld	a, (GS_DRVSEL)
	cp	c
	jr	nz, ck_err
	ld	a, (GS_FDCRES + 1)
	or	a
	jr	nz, ck_err
	ld	a, (GS_FDCRES + 2)
	and	0xBF
	jr	nz, ck_err
	ld	l, 0
	ret
ck_err:
	ld	hl, GS_REPTIM
	dec	(hl)
	ld	a, (hl)
	or	a
	jr	nz, ck_retry
	ld	l, 2
	ret
ck_retry:
	ld	l, 1
	ret

;------------------------------------------------------------------------
; flrtrk(cmd) — send FDC read/write command — FASTCALL, cmd in L
;------------------------------------------------------------------------
	PUBLIC	_flrtrk
_flrtrk:
	ld	a, (GS_DISKBITS)
	rrca
	ld	c, 0			; MFM flag
	jr	nc, ft_nomfm
	ld	c, 0x40
ft_nomfm:
	di
	ld	a, 0xFF
	ld	(GS_FDCFLG), a
	ld	a, l			; cmd
	add	a, c			; cmd + MFM flag
	push	af			; save cmd for later check
	ld	l, a
	call	_hal_fdc_wait_write
	call	_mkdhb
	call	_hal_fdc_wait_write
	pop	af			; A = cmd + MFM
	and	0x0F
	cp	0x06
	jr	nz, ft_done
	; Send 7 consecutive bytes from curcyl through dtl
	ld	b, 7
	ld	hl, GS_CURCYL
ft_sloop:
	push	bc
	push	hl
	ld	l, (hl)
	call	_hal_fdc_wait_write
	pop	hl
	pop	bc
	inc	hl
	djnz	ft_sloop
ft_done:
	ei
	ret

;------------------------------------------------------------------------
; recalv — recalibrate and verify
; Returns 0=OK, 1=timeout, 2=error in L
;------------------------------------------------------------------------
	PUBLIC	_recalv
_recalv:
	call	_flo4
	ld	l, 0xFF
	call	_waitfl
	ld	a, l
	or	a
	jr	z, rc_chk
	ld	l, 1
	ret
rc_chk:
	ld	a, (GS_DRVSEL)
	add	a, 0x20
	ld	c, a
	ld	a, (GS_FDCRES)
	cp	c
	jr	nz, rc_err
	ld	a, (GS_FDCRES + 1)
	or	a
	jr	nz, rc_err
	ld	l, 0
	ret
rc_err:
	ld	l, 2
	ret

;------------------------------------------------------------------------
; flseek — seek to current cylinder and verify
; Returns 0=OK, 1=timeout, 2=error in L
;------------------------------------------------------------------------
	PUBLIC	_flseek
_flseek:
	call	_mkdhb			; L = (curhed<<2)|drvsel
	ld	e, l			; save dhb
	ld	a, (GS_CURCYL)
	ld	c, a
	push	bc			; cyl (word, C=cyl)
	push	de			; dh (word, E=dhb)
	call	_flo7
	ld	l, 0xFF
	call	_waitfl
	ld	a, l
	or	a
	jr	z, fs_chk
	ld	l, 1
	ret
fs_chk:
	ld	a, (GS_DRVSEL)
	add	a, 0x20
	ld	c, a
	ld	a, (GS_FDCRES)
	cp	c
	jr	nz, fs_err
	ld	a, (GS_CURCYL)
	ld	c, a
	ld	a, (GS_FDCRES + 1)
	cp	c
	jr	nz, fs_err
	ld	l, 0
	ret
fs_err:
	ld	l, 2
	ret

;------------------------------------------------------------------------
; readtk(cmd, retries) — CALLEE convention
; Read track with retry loop.
; Stack at entry: ret(2) | cmd(2) | retries(2)
; Returns 0=OK, 1=error in L
;------------------------------------------------------------------------
	PUBLIC	_readtk
_readtk:
	pop	hl			; return address
	pop	de			; E = cmd
	pop	bc			; C = retries
	push	hl			; restore return address
	ld	a, c
	ld	(GS_REPTIM), a
rt_loop:
	push	de			; save cmd
	call	_clrflf
	pop	de
	ld	a, e
	and	0x0F
	cp	0x0A
	jr	z, rt_skdma
	; stpdma(memadr, trbyt-1, 0x45)
	push	de			; save cmd
	ld	bc, (GS_TRBYT)
	dec	bc			; BC = count
	ld	hl, (GS_MEMADR)	; HL = addr
	ld	de, 0x0045		; E = mode = 0x45
	push	de			; mode on stack
	push	bc			; count on stack
	push	hl			; addr on stack
	call	_stpdma
	pop	hl			; clean addr
	pop	hl			; clean count
	pop	hl			; clean mode
	pop	de			; restore cmd
rt_skdma:
	push	de			; save cmd
	ld	l, e			; L = cmd for FASTCALL
	call	_flrtrk
	ld	l, 0xFF
	call	_waitfl
	ld	a, l
	pop	de			; restore cmd
	or	a
	jr	z, rt_chkr
	ld	l, 1
	ret
rt_chkr:
	push	de
	call	_chkres
	ld	a, l
	pop	de
	or	a
	jr	nz, rt_chk2
	ld	l, 0
	ret
rt_chk2:
	cp	2
	jr	nz, rt_loop
	ld	l, 1
	ret

;------------------------------------------------------------------------
; dskauto — auto-detect disk density
; Returns 0=OK, 1=error in L
;------------------------------------------------------------------------
	PUBLIC	_dskauto
_dskauto:
	ld	a, (GS_DISKBITS)
	and	0xFE
	ld	(GS_DISKBITS), a
da_retry:
	call	_flseek
	ld	a, l
	or	a
	jr	z, da_rdid
	ld	l, 1
	ret
da_rdid:
	ld	hl, 4
	ld	(GS_TRBYT), hl
	; readtk(0x0A, 1) — CALLEE
	ld	bc, 1			; retries
	push	bc
	ld	bc, 0x0A		; cmd = Read ID
	push	bc
	call	_readtk
	ld	a, l
	or	a
	jr	z, da_ok
	; Read ID failed — try MFM
	ld	a, (GS_DISKBITS)
	bit	0, a
	jr	nz, da_fail		; already tried MFM
	or	0x01
	ld	(GS_DISKBITS), a
	jr	da_retry
da_fail:
	ld	l, 1
	ret
da_ok:
	ld	a, (GS_DISKBITS)
	and	0xE3
	ld	c, a
	ld	a, (GS_FDCRES + 6)	; N value from Read ID result
	rlca
	rlca
	or	c
	ld	(GS_DISKBITS), a
	call	_setfmt
	ld	l, 0
	ret

;------------------------------------------------------------------------
; fmtlkp — format table lookup
;------------------------------------------------------------------------
	PUBLIC	_fmtlkp
_fmtlkp:
	ld	a, (GS_RECLEN)
	and	0x03
	ld	e, a
	ld	d, 0
	; DE = n * 1, but tables are 4 bytes per row
	ex	de, hl
	add	hl, hl
	add	hl, hl			; HL = n * 4
	ex	de, hl			; DE = n * 4
	ld	a, (GS_DISKBITS)
	rlca
	jr	c, fl_mini
	; maxi
	ld	hl, MAXIFMT
	ld	a, 0x4C
	jr	fl_common
fl_mini:
	ld	hl, MINIFMT
	ld	a, 0x23
fl_common:
	ld	(GS_EPTS), a
	add	hl, de			; HL = &table[n]
	; side_offset = (diskbits & 1) ? 2 : 0
	ld	a, (GS_DISKBITS)
	rrca
	ld	e, 0
	jr	nc, fl_side0
	ld	e, 2
fl_side0:
	ld	d, 0
	add	hl, de			; HL = &table[n][side_offset]
	ld	a, (hl)
	ld	(GS_CUREOT), a
	ld	(GS_TRKSZ), a
	inc	hl
	ld	a, (hl)
	ld	(GS_GAP3), a
	ld	a, 0x80
	ld	(GS_DTL), a
	ret

; Format tables (shared with fmtlkp, placed here in CODE section)
MAXIFMT:
	DB	0x1A, 0x07, 0x34, 0x07
	DB	0x0F, 0x0E, 0x1A, 0x0E
	DB	0x08, 0x1B, 0x0F, 0x1B
	DB	0x00, 0x00, 0x08, 0x35
MINIFMT:
	DB	0x10, 0x07, 0x20, 0x07
	DB	0x09, 0x0E, 0x10, 0x0E
	DB	0x05, 0x1B, 0x09, 0x1B
	DB	0x00, 0x00, 0x05, 0x35

;------------------------------------------------------------------------
; calctb — calculate sector bytes and transfer bytes
;------------------------------------------------------------------------
	PUBLIC	_calctb
_calctb:
	ld	de, 0x0080		; secbytes = 128
	ld	c, 0			; i = 0
cb_sloop:
	ld	a, (GS_RECLEN)
	cp	c
	jr	z, cb_sdone
	jr	c, cb_sdone
	ex	de, hl
	add	hl, hl
	ex	de, hl
	inc	c
	jr	cb_sloop
cb_sdone:
	ld	(GS_SECBYT), de
	; sectors = cureot - currec + 1
	ld	a, (GS_CUREOT)
	ld	c, a
	ld	a, (GS_CURREC)
	ld	b, a
	ld	a, c
	sub	b
	ld	e, a
	inc	e			; E = sectors
	; check (dsktyp & 0x80) && (curhed ^ 0x01) == 0
	ld	a, (GS_DSKTYP)
	rlca
	jr	nc, cb_trbyt
	ld	a, (GS_CURHED)
	xor	0x01
	jr	nz, cb_trbyt
	ld	e, 0x0A		; sectors = 10
cb_trbyt:
	ld	d, 0			; DE = sectors
	ld	a, (GS_RECLEN)
	add	a, 7			; A = 7 + reclen
cb_shift:
	or	a
	jr	z, cb_store
	ex	de, hl
	add	hl, hl
	dec	a
	ex	de, hl
	jr	cb_shift
cb_store:
	ld	(GS_TRBYT), de
	ret

;------------------------------------------------------------------------
; setfmt — extract density bits and call fmtlkp + calctb
;------------------------------------------------------------------------
	PUBLIC	_setfmt
_setfmt:
	ld	a, (GS_DISKBITS)
	rrca
	rrca
	and	0x07
	ld	(GS_RECLEN), a
	call	_fmtlkp
	jp	_calctb

;========================================================================
; Boot logic functions — previously in C (boot.c)
; Moved to assembly to fit within the 2048-byte PROM.
;========================================================================

;------------------------------------------------------------------------
; String constants
;------------------------------------------------------------------------
MSG_RC700:
	DB	" RC700", 0
MSG_RC702:
	DB	" RC702", 0
MSG_NOSYS:
	DB	" **NO SYSTEM FILES** ", 0
MSG_NOCAT:
	DB	" **NO KATALOG** ", 0
MSG_NODISK:
	DB	" **NO DISKETTE NOR LINEPROG** ", 0
MSG_DISKERR:
	DB	"**DISKETTE ERROR** ", 0
STR_SYSM:
	DB	"SYSM", 0
STR_SYSC:
	DB	"SYSC", 0

;------------------------------------------------------------------------
; display_banner — show " RC700" on screen
;------------------------------------------------------------------------
	PUBLIC	_display_banner
_display_banner:
	ld	hl, MSG_RC700
	ld	de, _DSPSTR
	ld	bc, 6
	ldir
	ld	hl, 0
	ld	(_SCROLLOFFSET), hl
	ld	a, 0x23
	out	(P_CRT_CMD), a
	ret

;------------------------------------------------------------------------
; errcpy — copy "**DISKETTE ERROR**" to display buffer
;------------------------------------------------------------------------
	PUBLIC	_errcpy
_errcpy:
	ld	hl, MSG_DISKERR
	ld	de, _DSPSTR
	ld	bc, 19
	ldir
	ret

;------------------------------------------------------------------------
; errdsp(code) — FASTCALL, code in L
; Save error code, beep, display error, halt
;------------------------------------------------------------------------
	PUBLIC	_errdsp
_errdsp:
	ld	a, l
	ld	(GS_ERRSAV), a
	ei
	ld	a, (GS_DSKTYP)
	rrca
	ret	c			; dsktyp & 1 -> silent return
	xor	a
	out	(P_BIB), a		; beep
	call	_errcpy
ed_halt:
	jr	ed_halt

;------------------------------------------------------------------------
; isrc70x — compare signature at base+2 with RC700 or RC702
; DE = base address, A = which (0x0A=RC700, 0x0B=RC702)
; Returns L: 0=match, 1=mismatch
;------------------------------------------------------------------------
isrc70x:
	cp	0x0A
	ld	hl, MSG_RC700
	jr	z, ix_go
	ld	hl, MSG_RC702
ix_go:
	inc	de
	inc	de			; DE = base + 2
	ld	b, 6
ix_cmp:
	ld	a, (de)
	cp	(hl)
	jr	nz, ix_diff
	inc	de
	inc	hl
	djnz	ix_cmp
	ld	l, 0
	ret
ix_diff:
	ld	l, 1
	ret

;------------------------------------------------------------------------
; chk_sysfile — check directory entry for system file name + attribute
; DE = dir_entry, HL = 4-char filename
; Returns L: 0=match, 1=mismatch
;------------------------------------------------------------------------
chk_sysfile:
	inc	de			; DE = dir_entry + 1
	ld	b, 4
cs_loop:
	ld	a, (de)
	cp	(hl)
	jr	nz, cs_fail
	inc	de
	inc	hl
	djnz	cs_loop
	; DE now at dir_entry+5, attribute at dir_entry+8 = DE+3
	inc	de
	inc	de
	inc	de
	ld	a, (de)
	and	0x3F
	cp	0x13
	jr	nz, cs_fail
	ld	l, 0
	ret
cs_fail:
	ld	l, 1
	ret

;------------------------------------------------------------------------
; boot7 — verify catalogue and system files
;------------------------------------------------------------------------
	PUBLIC	_boot7
_boot7:
	ld	de, 0x0000		; base = FLOPPYDATA
	ld	a, 0x0A
	call	isrc70x
	ld	a, l
	or	a
	jr	nz, b7_try702
	; RC700 signature — search directory for SYSM, SYSC
	ld	de, 0x0B60		; dir = DIROFF
b7_dirloop:
	ld	hl, 0x0020
	add	hl, de
	ex	de, hl			; dir += 0x20
	ld	a, d
	cp	0x0D			; dir >= DIREND_HI << 8?
	jr	nc, b7_nosys
	ld	a, (de)
	or	a
	jr	z, b7_dirloop		; empty entry, skip
	push	de
	ld	hl, STR_SYSM
	call	chk_sysfile
	pop	de
	ld	a, l
	or	a
	jr	nz, b7_nosys
	; Next entry: check SYSC
	ld	hl, 0x0020
	add	hl, de
	ex	de, hl			; dir += 0x20
	ld	a, (de)
	or	a
	jr	z, b7_nosys
	push	de
	ld	hl, STR_SYSC
	call	chk_sysfile
	pop	de
	ld	a, l
	or	a
	jr	nz, b7_nosys
	ret				; success — both files found

b7_try702:
	ld	de, 0x0000
	ld	a, 0x0B
	call	isrc70x
	ld	a, l
	or	a
	jr	nz, b7_nocat
	; RC702 boot: tail call through vector at address 0x0000
	ld	hl, (0x0000)
	jp	(hl)

b7_nocat:
	ld	hl, MSG_NOCAT
	ld	de, _DSPSTR
	ld	bc, 16
	ldir
b7_nocat_h:
	jr	b7_nocat_h

b7_nosys:
	ld	hl, MSG_NOSYS
	ld	de, _DSPSTR
	ld	bc, 21
	ldir
b7_nosys_h:
	jr	b7_nosys_h

;------------------------------------------------------------------------
; check_prom1 — check for PROM1 at 0x2000, or halt with error
;------------------------------------------------------------------------
	PUBLIC	_check_prom1
_check_prom1:
	ld	de, 0x2000
	ld	a, 0x0B
	call	isrc70x
	ld	a, l
	or	a
	jr	nz, cp1_nodisk
	; Tail call through vector at 0x2000
	ld	hl, (0x2000)
	jp	(hl)
cp1_nodisk:
	ld	hl, MSG_NODISK
	ld	de, _DSPSTR
	ld	bc, 30
	ldir
cp1_halt:
	jr	cp1_halt

;------------------------------------------------------------------------
; nxthds — advance to next head/cylinder
;------------------------------------------------------------------------
nxthds:
	ld	a, 1
	ld	(GS_CURREC), a
	ld	a, (GS_DISKBITS)
	rrca
	and	0x01			; max_head = (diskbits >> 1) & 1
	ld	hl, GS_CURHED
	cp	(hl)			; compare max_head with curhed
	jr	nz, nh_inchead
	ld	(hl), 0			; curhed = 0
	dec	hl			; HL = GS_CURCYL
	inc	(hl)
	ret
nh_inchead:
	inc	(hl)
	ret

;------------------------------------------------------------------------
; calctx — calculate transfer, check remaining
;------------------------------------------------------------------------
calctx:
	call	_calctb
	ld	hl, (GS_TRKOVR)
	ld	de, (GS_TRBYT)
	or	a			; clear carry
	sbc	hl, de			; HL = trkovr - trbyt
	jr	z, cx_nomore
	bit	7, h
	jr	nz, cx_nomore		; negative -> no more
	; remaining > 0
	ld	a, 1
	ld	(GS_MOREFL), a
	ld	(GS_TRKOVR), hl
	ret
cx_nomore:
	xor	a
	ld	(GS_MOREFL), a
	ld	hl, (GS_TRKOVR)
	ld	(GS_TRBYT), hl
	ld	hl, 0
	ld	(GS_TRKOVR), hl
	ret

;------------------------------------------------------------------------
; rdtrk0 — read track 0 loop, HL = trkovr_init
;------------------------------------------------------------------------
rdtrk0:
	ld	(GS_TRKOVR), hl
rd_loop:
	call	_flseek
	ld	a, l
	cp	1
	jp	z, _check_prom1		; timeout -> check prom1
	or	a
	jr	z, rd_read
	ld	l, 0x06
	jp	_errdsp			; seek error
rd_read:
	call	calctx
	; readtk(0x06, 5) — CALLEE
	ld	bc, 5
	push	bc
	ld	bc, 0x06
	push	bc
	call	_readtk
	ld	a, l
	or	a
	jr	z, rd_ok
	ld	l, 0x28
	jp	_errdsp			; read error
rd_ok:
	ld	hl, (GS_MEMADR)
	ld	de, (GS_TRBYT)
	add	hl, de
	ld	(GS_MEMADR), hl
	ld	hl, 0
	ld	(GS_TRBYT), hl
	call	nxthds
	ld	a, (GS_MOREFL)
	or	a
	jr	nz, rd_loop
	ret

;------------------------------------------------------------------------
; boot_detect — detect disk format on both sides
;------------------------------------------------------------------------
	PUBLIC	_boot_detect
_boot_detect:
	ld	hl, 0x0100
	ld	(GS_CURCYL), hl	; curcyl=0, curhed=1
	ld	a, 1
	ld	(GS_CURREC), a
	call	_dskauto
	ld	a, l
	or	a
	jr	nz, bd_skip
	ld	a, (GS_DISKBITS)
	or	0x02
	ld	(GS_DISKBITS), a
bd_skip:
	xor	a
	ld	(GS_CURHED), a
	jp	_dskauto		; tail call

;------------------------------------------------------------------------
; flboot — final boot: re-detect, read, jump to CP/M
;------------------------------------------------------------------------
	PUBLIC	_flboot
_flboot:
	ld	a, (GS_DISKBITS)
	and	0x80
	ld	c, a
	ld	a, (GS_DSKTYP)
	or	c
	dec	a
	ld	(GS_DSKTYP), a
	call	_dskauto
	ld	hl, 0
	ld	(GS_MEMADR), hl
	ld	hl, 0x0300		; 0x7300 - 0x7000
	call	rdtrk0
	ld	a, 1
	ld	(GS_DSKTYP), a
	jp	0x1000			; COMALBOOT

;------------------------------------------------------------------------
; fldsk1 — main disk boot sequence
;------------------------------------------------------------------------
fldsk1:
	; hal_delay(1, 0xFF)
	ld	bc, 0x00FF
	push	bc			; inner = 0xFF
	ld	bc, 1
	push	bc			; outer = 1
	call	_hal_delay
	call	_snsdrv
	ld	a, (GS_FDCRES)
	and	0x23
	ld	c, a
	ld	a, (GS_DRVSEL)
	add	a, 0x20
	cp	c
	jp	nz, _check_prom1
	call	_recalv
	ld	a, l
	or	a
	jp	nz, _check_prom1
	call	_boot_detect
	ld	a, l
	or	a
	jp	nz, _check_prom1
	; hal_prom_disable
	ld	a, 1
	out	(P_RAMEN), a
fd_rdloop:
	ld	hl, (GS_TRBYT)
	call	rdtrk0
	ld	a, (GS_CURCYL)
	or	a
	jr	nz, fd_done
	call	_dskauto
	jr	fd_rdloop
fd_done:
	ld	a, 1
	ld	(GS_DSKTYP), a
	call	_boot7
	jp	_flboot

;------------------------------------------------------------------------
; preinit — initialize state and start disk boot
;------------------------------------------------------------------------
preinit:
	ld	hl, 0x0403
	ld	(GS_FDCTMO), hl	; fdctmo=3, fdcwai=4
	ld	a, 4
	ld	(GS_FLPWAI), a
	in	a, (P_SW1)
	and	0x80
	ld	(GS_DISKBITS), a
	xor	a
	ld	(GS_CURHED), a
	ld	(GS_DRVSEL), a
	ld	(GS_DSKTYP), a
	ld	(GS_MOREFL), a
	ld	(GS_FLPFLG), a
	; Zero memadr(32-33), trbyt(34-35), trkovr(36-37)
	ld	hl, GS_MEMADR
	ld	b, 6
pi_zero:
	ld	(hl), a
	inc	hl
	djnz	pi_zero
	ei
	ld	a, 1
	out	(P_SW1), a		; motor on
	ld	a, 5
	ld	(GS_REPTIM), a
	jp	fldsk1			; tail call

;------------------------------------------------------------------------
; syscall(addr, b, c) — BIOS disk read entry point
; Stack: ret(2) | addr(2) | b(2) | c(2)
;------------------------------------------------------------------------
	PUBLIC	_syscall
_syscall:
	ld	hl, 2
	add	hl, sp
	ld	e, (hl)
	inc	hl
	ld	d, (hl)		; DE = addr
	inc	hl
	ld	b, (hl)		; B = b param
	inc	hl
	inc	hl			; skip high byte
	ld	c, (hl)		; C = c param
	ld	(GS_MEMADR), de
	ld	a, c
	and	0x7F
	ld	(GS_CURREC), a
	ld	a, b
	and	0x7F
	ld	(GS_CURCYL), a
	or	a
	jr	nz, sc_noauto
	push	bc
	call	_dskauto
	pop	bc
sc_noauto:
	bit	7, b
	ld	a, 0
	jr	z, sc_head0
	ld	a, 1
sc_head0:
	ld	(GS_CURHED), a
	push	bc
	ld	hl, 0
	call	rdtrk0
	pop	bc
	ld	a, b
	and	0x7F
	ret	nz
	ld	a, 1
	ld	(GS_CURCYL), a
	jp	_dskauto		; tail call

;------------------------------------------------------------------------
; main — entry point from crt0 init
;------------------------------------------------------------------------
	PUBLIC	_main
_main:
	call	_init_fdc
	call	_clear_screen
	call	_display_banner
	jp	preinit			; tail call, never returns

; Payload length
PAYLOADLEN	EQU	$ - INIT_RELOCATED
