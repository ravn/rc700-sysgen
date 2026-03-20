; crt0.asm — Section layout, IVT data, and g_state address.
;
; All executable code is in C files. This file contains:
;   - Section declarations with ORG (linker scaffolding)
;   - INTVEC: interrupt vector table data (sdcc can't place in custom section)
;   - g_state DEFC: fixed RAM address alias (sdcc __at causes boot hang)
;
; Section layout:
;   BOOT     0x0000  begin() + C init code (boot_entry.c)
;   NMI      0x0066  NMI handler (nmi.c)
;   CODE     0x7000  IVT data + all C code (relocated to RAM by begin)

	EXTERN	_dumint, _crtint, _flpint   ; ISRs in isr.c
	EXTERN	__tail                      ; linker: end of last section

; ====================================================================
; BOOT section (ROM address 0x0000) — begin() in boot_entry.c
; ====================================================================

	SECTION	BOOT
	ORG	0x0000

; ====================================================================
; NMI section (0x0066) — nmi.c provides nmi_noop (RETN)
; ====================================================================

	SECTION	NMI
	ORG	0x0066

; ====================================================================
; CODE section (0x7000) — relocated to RAM by begin()
; ====================================================================

	SECTION CODE
	ORG	0x7000

; Interrupt vector table — 16 entries, page-aligned for Z80 IM2.
; Must stay in asm: sdcc's ROM model creates duplicate symbols for
; initialized data, preventing placement in a custom section.
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

; g_state: fixed RAM address alias. Must stay in asm — sdcc __at(0xBF00)
; creates a BSS allocation gap that causes boot hang.
	PUBLIC	_g_state
	DEFC	_g_state = 0xBF00
