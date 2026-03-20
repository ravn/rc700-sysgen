;
; crt0.asm — Startup code for RC702 autoload PROM (sdcc sdcccall(1) ABI)
;
; PROM image layout (2048 bytes max):
;
;   Section  Address   Contents
;   -------  --------  ----------------------------------------
;   BOOT     0x0000    Assembly entry (BEGIN): DI, SP, inline LDIR, JP = 18 bytes
;            0x0012    C code from boot_entry.c (--codeseg BOOT) = ~74 bytes:
;                        clear_screen(), init_fdc(), display_banner()
;            ~0x005C   Gap (~10 bytes, available for future BOOT section data)
;   NMI      0x0066    nmi_noop() from nmi.c (--codeseg NMI) = 2 bytes (RETN)
;   CODE     0x0068+   Payload in ROM, copied to 0x7000 at boot:
;            0x7000      Interrupt vector table (naturally page-aligned)
;            0x7020      INIT_RELOCATED: SP/I/IM2, CALL init_peripherals, JP _main
;            0x702F      CRTINT, FLPINT, DUMINT: interrupt entry points
;            0x7040      Small functions: jump_to
;            0x7046      halt_msg + halt_forever
;            ...         C code (sdcc): init_peripherals, hal_z80.c, fdc.c,
;                        fmt.c, boot.c, isr.c
;            ...         Read-only data: format tables, message strings
;
; The full PROM (BOOT + NMI + CODE) is copied to RAM by the LDIR in BEGIN,
; with CODE landing at INTVEC (0x7000). BOOT+NMI land at INTVEC-0x68.
; The BOOT gap (b7_sysm/b7_sysc) is thus in RAM after hal_prom_disable()
; at INTVEC - 0x68 + <rom_offset>.
; Linker symbol __tail drives the relocation byte count.
;
; Assembly in this file (BOOT + CODE sections):
; - Interrupt vector table (at CODE section start, naturally page-aligned)
; - CRTINT, FLPINT, DUMINT interrupt wrappers
; - Utility: halt_msg, halt_forever, jump_to
; - hal_ei/hal_di are inline macros in hal.h (expand to EI/DI at call site)
; - b7_sysm, b7_sysc are static const arrays in boot.c (CODE section)
;
; All other boot logic, FDC driver, and format tables are in C (sdcc).
;

	; External symbols provided by C code
	EXTERN	_dumint
	EXTERN	_crtint
	EXTERN	_flpint

	; __tail — linker-generated symbol: address of the byte past the end of
	; the last output section (here: CODE).  The z80asm linker generates one
	; global __tail (entire output) and per-section variants __<NAME>_tail.
	; Source: z88dk/src/z80asm/src/c/modlink.c
	EXTERN	__tail


	SECTION	BOOT
	ORG	0x0000

;========================================================================
; ROM ENTRY POINT at 0x0000
;========================================================================

BEGIN:
	DI
	LD	SP, 0xBFFF		; Stack below display buffer

; Copy full PROM to RAM: BOOT+NMI at CODE-0x68, CODE at 0x7000.
; 0x68 = BOOT section max (0x66 bytes) + NMI (2 bytes).
; CODE starts at 0x7000 (page-aligned for Z80 IM2 interrupt vectors).
	LD	HL, 0x0000		; source: start of PROM
	LD	DE, INTVEC - 0x68	; destination: BOOT lands here, CODE at INTVEC
	LD	BC, __tail - INTVEC + 0x68  ; byte count
	LDIR
	JP	INIT_RELOCATED		; Jump to relocated init code

; C code from boot_entry.c follows here (--codeseg BOOT):
;   clear_screen(), init_fdc(), display_banner() — ~74 bytes
; ~10 bytes of gap remain before the NMI vector at 0x0066.

;========================================================================
; NMI section — must start at 0x0066 (Z80 hardware NMI vector)
; nmi_noop() from nmi.c is placed here via --codeseg NMI
;========================================================================

	SECTION	NMI
	ORG	0x0066

;========================================================================
; RELOCATED CODE SECTION — loaded to 0x7000, executed from there
;========================================================================

	SECTION CODE
	ORG	0x7000

;------------------------------------------------------------------------
; Interrupt vector table — at 0x7000 (naturally 256-byte page-aligned)
; Z80 IM2: vector address = I * 256 + data_bus_byte
; I register is loaded with INTVEC / 0x100 = 0x70
;
; INTVEC is the first label in the CODE section, so it aliases the linker
; symbol __CODE_head — both equal 0x7000.
;------------------------------------------------------------------------

; Interrupt vector table — 16 entries at 0x7000 (page-aligned for IM2).
; References C functions (_dumint in isr.c) and asm wrappers below.
INTVEC:
	DW	_dumint			; +0:  Dummy
	DW	_dumint			; +2:  PIO Port A
	DW	_dumint			; +4:  PIO Port B
	DW	_dumint			; +6:  Dummy
	DW	_dumint			; +8:  CTC CH0
	DW	_dumint			; +10: CTC CH1
	DW	_crtint			; +12: CTC CH2 - Display
	DW	_flpint			; +14: CTC CH3 - Floppy
	DW	_dumint			; +16: Dummy
	DW	_dumint			; +18: Dummy
	DW	_dumint			; +20: Dummy
	DW	_dumint			; +22: Dummy
	DW	_dumint			; +24: Dummy
	DW	_dumint			; +26: Dummy
	DW	_dumint			; +28: Dummy
	DW	_dumint			; +30: Dummy

;------------------------------------------------------------------------
; INIT_RELOCATED — Z80-specific setup, then C peripheral init and main
;------------------------------------------------------------------------

; INIT_RELOCATED is now init_relocated() in init.c
	EXTERN	_init_relocated
INIT_RELOCATED	EQU	_init_relocated

;------------------------------------------------------------------------
; Long-term goal: replace these assembly interrupt wrappers with C functions
; using the __interrupt attribute, eliminating the remaining hand-written
; assembly here. Prerequisites: verify that interrupt timing and ordering
; constraints (e.g. whether other interrupts may safely fire while
; crt_refresh or flpint_body is mid-execution) are understood and benign.
; See individual wrapper comments below for the specific open questions.
;------------------------------------------------------------------------

; ISR wrappers (crtint, flpint) are now in isr.c using __critical __interrupt.
; dumint is also in isr.c using __interrupt.


;------------------------------------------------------------------------
; Small utility functions
;------------------------------------------------------------------------

; jump_to — permanent transfer of control to address in HL (no return)
;
; There is no C equivalent: a function-pointer call generates CALL (which
; pushes a return address), not JP. The z88dk runtime does provide
; ___sdcc_call_hl which is literally "jp (hl)", but it is an internal
; compiler helper (triple-underscore), not a public API, and its intended
; use is as a CALL dispatcher (caller expects a RET back), not a one-way
; jump. Assembly is the only correct approach here.
	PUBLIC	_jump_to
_jump_to:
	jp	(hl)


;------------------------------------------------------------------------
; halt_msg — display null-terminated message then halt forever
;
; Entry: HL = pointer to null-terminated message string
; Uses ldi to copy one byte at a time. ldi also decrements BC, but BC
; is never checked — the loop exits on NUL (A==0), not on BC==0, so BC
; only needs to be non-zero to keep P/V flag out of the termination path.
; BC is undefined on entry; caller (C code via sdcccall) passes only HL.
;------------------------------------------------------------------------

	PUBLIC	_halt_msg
_halt_msg:
	ld	de, _DSPSTR		; DE = dst (display buffer 0x7800)
hm_lp:
	ld	a, (hl)			; load char
	or	a			; NUL?
	jr	z, _halt_forever	; done — don't copy NUL to display
	ldi				; copy byte, inc HL/DE, dec BC (ignored)
	jr	hm_lp			; next char
	PUBLIC	_halt_forever
_halt_forever:
	jr	_halt_forever

;========================================================================
; Constants and data
;========================================================================

_DSPSTR		EQU	0x7800		; Display buffer base address


;------------------------------------------------------------------------
; g_state — boot state structure at fixed RAM address
;------------------------------------------------------------------------
	PUBLIC	_g_state
	DEFC	_g_state = 0xBF00


