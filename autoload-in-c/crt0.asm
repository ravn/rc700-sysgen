;
; crt0.asm — Startup code for RC702 autoload PROM (sdcc sdcccall(1) ABI)
;
; PROM image layout (2048 bytes max):
;
;   Section  Address   Contents
;   -------  --------  ----------------------------------------
;   BOOT     0x0000    Entry point: DI, SP setup, CALL relocate, JP INIT
;            0x000A    C code from boot_entry.c (--codeseg BOOT):
;                        relocate() — self-relocation loop
;            gap       Available for more BOOT C code (must fit before 0x0066)
;   NMI      0x0066    RETN (Z80 hardware NMI vector, fixed address)
;   CODE     0x0068+   Payload in ROM, copied to 0x7000 at boot:
;            0x7000      Interrupt vector table (naturally page-aligned)
;            0x7020      INIT_RELOCATED: SP/I/IM2, CALL init_peripherals, JP _main
;            0x702F      CRTINT, FLPINT, DUMINT: interrupt entry points
;            0x7040      Small functions: jump_to, hal_ei, hal_di
;            0x7046      halt_msg + halt_forever
;            0x7051      b7_sysm, b7_sysc strings
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
; - CRTINT, FLPINT, DUMINT interrupt wrappers
; - Utility: halt_msg, halt_forever, jump_to, hal_ei, hal_di
; - String data: b7_sysm, b7_sysc
;
; All other boot logic, FDC driver, and format tables are in C (sdcc).
;

	; External symbols provided by C code
	EXTERN	_main
	EXTERN	_crt_refresh
	EXTERN	_flpint_body
	EXTERN	_init_peripherals

	; Linker-generated section boundary symbols (for LDIR relocation)
	EXTERN	__NMI_tail
	EXTERN	__tail


	SECTION	BOOT
	ORG	0x0000

;========================================================================
; ROM ENTRY POINT at 0x0000
;========================================================================

BEGIN:
	DI
	LD	SP, 0xBFFF		; Stack below display buffer

; Copy CODE payload from ROM to RAM at 0x7000 (inline LDIR)
	LD	HL, __NMI_tail		; source: ROM right after NMI section
	LD	DE, 0x7000		; destination: RAM
	LD	BC, __tail - 0x7000	; byte count (total CODE payload size)
	LDIR
	JP	INIT_RELOCATED		; Jump to relocated init code

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
	DW	CRTINT			; +12: CTC CH2 - Display
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

_DSPSTR		EQU	0x7800

;------------------------------------------------------------------------
; CRTINT — CRT vertical retrace interrupt (CTC Ch2), calls C crt_refresh
;
; Must save ALL registers that sdcc may use as scratch: AF, BC, DE, HL.
; BC is critical — sdcc uses B and C freely in compiled code, and
; hal_delay uses B for DJNZ (inner loop) and C for DEC C (middle loop).
; If BC is not saved, CRT interrupts during hal_delay corrupt its loop
; counters, causing infinite delay loops that prevent boot from reaching
; the FDC driver.
;------------------------------------------------------------------------

CRTINT:
	DI
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	_crt_refresh
	POP	HL
	POP	DE
	POP	BC
	POP	AF
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

