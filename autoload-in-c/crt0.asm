; crt0.asm — ROM entry point, interrupt vector table, and section layout.
;
; All executable code and data are in C files, except:
;   - BEGIN: self-relocation stub (LDIR cannot be expressed in C)
;   - INTVEC: interrupt vector table (must be at CODE section start, 0x7000)
;
; Section layout:
;   BOOT     0x0000  ROM entry + C init code (boot_entry.c)
;   NMI      0x0066  NMI handler (nmi.c)
;   CODE     0x7000  IVT + all C code (relocated to RAM by BEGIN)

	EXTERN	_dumint, _crtint, _flpint   ; ISRs in isr.c
	EXTERN	_init_relocated             ; post-relocation init in init.c
	EXTERN	__tail                      ; linker: end of last section

; ====================================================================
; BOOT section (ROM address 0x0000)
; ====================================================================

	SECTION	BOOT
	ORG	0x0000

BEGIN:
	DI
	LD	SP, 0xBFFF
	LD	HL, 0x0000              ; source: start of PROM
	LD	DE, INTVEC - 0x68       ; dest: CODE at INTVEC (0x7000)
	LD	BC, __tail - INTVEC + 0x68
	LDIR
	JP	_init_relocated         ; jump to relocated C code

; boot_entry.c C code follows (--codeseg BOOT)

; ====================================================================
; NMI section (0x0066) — nmi.c provides nmi_noop (RETN)
; ====================================================================

	SECTION	NMI
	ORG	0x0066

; ====================================================================
; CODE section (0x7000) — relocated to RAM by BEGIN
; ====================================================================

	SECTION CODE
	ORG	0x7000

; Interrupt vector table — 16 entries, page-aligned for Z80 IM2.
; I register = 0x70, vector address = I*256 + data_bus_byte.
INTVEC:
	DW	_dumint         ;  +0: Dummy
	DW	_dumint         ;  +2: PIO Port A
	DW	_dumint         ;  +4: PIO Port B
	DW	_dumint         ;  +6: Dummy
	DW	_dumint         ;  +8: CTC CH0
	DW	_dumint         ; +10: CTC CH1
	DW	_crtint         ; +12: CTC CH2 — Display refresh
	DW	_flpint         ; +14: CTC CH3 — Floppy completion
	DW	_dumint         ; +16: Dummy
	DW	_dumint         ; +18: Dummy
	DW	_dumint         ; +20: Dummy
	DW	_dumint         ; +22: Dummy
	DW	_dumint         ; +24: Dummy
	DW	_dumint         ; +26: Dummy
	DW	_dumint         ; +28: Dummy
	DW	_dumint         ; +30: Dummy

; g_state at fixed RAM address (used by all C code via boot.h extern)
	PUBLIC	_g_state
	DEFC	_g_state = 0xBF00
