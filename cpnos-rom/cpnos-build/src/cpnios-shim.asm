	title	'RC702 SNIOS trampoline for CP/NOS 1.2'
;
; Replaces cpnet-z80/dist/src/cpnios.asm (DRI's reference SNIOS, which
; talks to Altos serial ports 0x3E/0x3F).  On RC702 the real SNIOS is
; the cpnos-rom resident implementation at VMA 0xEA00+, which uses
; SIO-A at 38400 8N1 to reach the MP/M master.
;
; NDOS was built (by RMAC+LINK) to call SNIOS services at NIOS+N*3 for
; N = 0..7.  This module sits at NIOS (the linker places it right after
; NDOS code) and forwards every call to the corresponding slot in our
; resident JT at 0xEA00.
;
; Entry order (DRI standard, matches cpnet-z80/dist/src/cpnios.asm and
; cpnos-rom/snios.s):
;   +00 NTWKIN  network initialization
;   +03 NTWKST  network status
;   +06 CNFTBL  return config table address
;   +09 SNDMSG  send message on network
;   +12 RCVMSG  receive message from network
;   +15 NTWKER  network error
;   +18 NTWKBT  network warm boot
;   +21 NTWKDN  network shutdown
;
; RC702 retarget 2026-04, issue #38.
;
rsbase	equ	0EA00h		; resident SNIOS JT base (set up by
				; cpnos-rom resident_entry before cpnos.com
				; is entered)
;
	CSEG
NIOS:
	public	NIOS
	jmp	rsbase+00h	; NTWKIN
	jmp	rsbase+03h	; NTWKST
	jmp	rsbase+06h	; CNFTBL
	jmp	rsbase+09h	; SNDMSG
	jmp	rsbase+0Ch	; RCVMSG
	jmp	rsbase+0Fh	; NTWKER
	jmp	rsbase+12h	; NTWKBT
	jmp	rsbase+15h	; NTWKDN
;
	end
