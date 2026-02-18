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
;            0x7000      INIT_RELOCATED: hardware init (PIO, CTC, DMA, CRT)
;                        JP _main
;            0x7079      DISINT: display interrupt handler (DMA reprogramming)
;            0x70CD      HDINT, FLPINT, DUMINT: interrupt entry points
;            0x70E6      Small functions: jump_to, hal_ei, hal_di
;            0x70EB      halt_msg + halt_forever (in alignment padding)
;            0x70F6      b7_sysm, b7_sysc strings (in alignment padding)
;            0x7100      Interrupt vector table (256-byte aligned)
;            0x7120      HAL: hal_fdc_wait_write, hal_fdc_wait_read, hal_delay
;            0x715C      Boot helpers: b7_cmp6, b7_chksys (CP (HL)/DJNZ)
;            0x7184+     C code (sdcc): fdc.c, fmt.c, boot.c, isr.c
;            ...+        Read-only data: format tables, message strings
;
; The BOOT and NMI sections remain in ROM until hal_prom_disable().
; The CODE payload is copied to RAM at 0x7000 by relocate() in boot_entry.c.
; Linker symbols __NMI_tail, __CODE_head, __tail drive the relocation.
;
; Assembly in this file (BOOT + CODE sections):
; - Interrupt vector table (page-aligned at 0x7300)
; - DISINT display interrupt handler (timing-critical DMA reprogramming)
; - HDINT, FLPINT, DUMINT interrupt wrappers
; - Hardware init sequences (PIO, CTC, DMA, CRT)
; - HAL functions: hal_fdc_wait_write, hal_fdc_wait_read, hal_delay
; - Utility: clear_screen, init_fdc, halt_msg
; - Boot helpers: b7_cmp6, b7_chksys (comparison loops need CP (HL)/DJNZ)
;
; All other boot logic, FDC driver, and format tables are in C (sdcc).
;

	; External symbols provided by C code
	EXTERN	_main
	EXTERN	_flpint_body
	EXTERN	_errdsp
	EXTERN	_relocate
	EXTERN	_msg_rc700


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
	ld	bc, 8 * 208 - 1		; BUG: should be 80*25-1 (original ROM oversight)
	ld	(hl), 0x20
	ldir
	ret

; init_fdc — wait for FDC ready, send SPECIFY command
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
; Small functions placed in alignment padding gap (saves ~7 bytes)
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
; Fill alignment gap: halt_msg (null-terminated copy, embeds halt_forever)
; + boot7 comparison string data.
;------------------------------------------------------------------------

	PUBLIC	_halt_msg
_halt_msg:
	ld	de, _DSPSTR		; DE = dst (0x7800)
hm_lp:
	ld	a, (hl)			; load char
	ldi				; copy byte, inc HL/DE, dec BC (BC ignored)
	or	a			; was it NUL?
	jr	nz, hm_lp		; continue if not
	PUBLIC	_halt_forever
_halt_forever:
	jr	_halt_forever

	PUBLIC	_b7_sysm
_b7_sysm:
	DB	"SYSM"
	PUBLIC	_b7_sysc
_b7_sysc:
	DB	"SYSC"

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
; b7_cmp6(a, b) — Compare 6 bytes at a vs b
; sdcccall(1): a in HL, b in DE. Returns 0 (match) or 1 (mismatch) in A.
; These byte-comparison loops use CP (HL)/DJNZ which C cannot express.
;------------------------------------------------------------------------
	PUBLIC	_b7_cmp6
_b7_cmp6:
	ld	b, 6
b7c6_lp:
	ld	a, (de)
	cp	(hl)
	jr	nz, b7_ne
	inc	hl
	inc	de
	djnz	b7c6_lp
	xor	a			; return 0 = match
	ret
b7_ne:
	ld	a, 1			; return 1 = mismatch
	ret

;------------------------------------------------------------------------
; b7_chksys(dir, pattern) — Check directory entry name + attribute
; sdcccall(1): dir in HL, pattern in DE.
; Compares dir[1..4] against pattern[0..3], then checks dir[8] attribute.
; Returns 0 (match) or 1 (mismatch) in A.
;------------------------------------------------------------------------
	PUBLIC	_b7_chksys
_b7_chksys:
	inc	hl			; HL = dir + 1
	ld	b, 4
b7cs_lp:
	ld	a, (de)
	cp	(hl)
	jr	nz, b7_ne		; reuse mismatch return above
	inc	hl
	inc	de
	djnz	b7cs_lp
	; Check attribute: dir[1+ATTOFF] = dir[8], HL is now at dir+5
	inc	hl			; dir+6
	inc	hl			; dir+7
	inc	hl			; dir+8
	ld	a, (hl)
	and	0x3F
	cp	0x13
	jr	nz, b7_ne		; reuse mismatch return
	xor	a			; return 0 = match
	ret

;------------------------------------------------------------------------
; g_state — boot state structure at fixed RAM address
;------------------------------------------------------------------------
	PUBLIC	_g_state
	DEFC	_g_state = 0xBF00

