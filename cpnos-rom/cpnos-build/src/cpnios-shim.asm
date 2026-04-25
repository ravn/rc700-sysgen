	title	'RC702 SNIOS shim — NIOS=0xEA00'
;
; Resolves cpndos.z80's `EXTRN NIOS` with a single absolute symbol.
; cpndos calls NIOS+N*3 for N = 0..7
; (NTWKIN/NTWKST/CNFTBL/SNDMSG/RCVMSG/NTWKER/NTWKBT/NTWKDN); those
; addresses now resolve directly to 0xEA00+N*3, which is where
; cpnos-rom's resident SNIOS JT lives (set up by the PROM resident
; before cpnos.com is entered).
;
; Phase 2A (2026-04-25): replaced the prior 24-byte JMP-trampoline.
; A trampoline added one more layer of indirection without doing
; anything the linker can't do for free.  Single source of "NIOS
; lives at 0xEA00" knowledge in cpnos.com.
;
; Phase 2B (2026-04-26): kept as-is.  DRI LINK has no command-line
; --defsym equivalent, so the EXTRN NIOS reference in cpndos.rel
; needs SOMETHING to publish NIOS as a public symbol.  Alternatives
; were (a) generate this .asm from a Makefile here-doc — moves the
; source uglier without removing it, (b) write a custom .REL emitter
; — significant code for zero functional gain.  Keeping the file is
; the cleanest expression of the single fact "NIOS lives at 0xEA00".

NIOS	EQU	0EA00h
	public	NIOS
	end
