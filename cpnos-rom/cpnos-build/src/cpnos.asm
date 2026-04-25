; cpnos.asm — entry stub for the network-loadable CP/NOS image
;
; Phase 2A (2026-04-25): the boot-time signon, BIOS-JT copy, and
; ZP[0..4] setup all live in cpnos-rom (resident PROM) C code now.
; PROM jumps to 0xD000 with the JT-copy at 0xCF00 already populated
; and ZP[1..2] = 0xCF03.  This stub finishes the zero-page setup
; with ZP[5..7] = JP BDOS+6 — that one byte must come from the
; cpnos.com link because BDOS's address depends on cpndos's size,
; which is fixed only after RMAC+LINK runs.
;
; No RC702-specific knowledge in this file: the only addresses used
; are link-time module symbols (NDOS, BDOS).  Replaces the prior
; "JMP BIOS" stub that delegated everything to cpbios.asm.

	extrn	NDOS	; cpndos: NDOS+3 = COLDST
	extrn	BDOS	; cpbdos: BDOS+6 = BDOS dispatch entry

	CSEG
boot:
	public	boot
	lxi	sp,0100h	; CP/M convention: SP at TPA start before
				; CCP/BDOS run.  PROM C left SP near 0xED00
				; (resident-code stack); NDOS would PUSH into
				; the IVT at 0xEC00 with that.
	mvi	a,0c3h		; CP/M JP opcode at ZP[5]
	sta	0005h
	lxi	h,BDOS		; BDOS dispatch entry (cpbdos.z80 puts the
				; 6-byte serial number BEFORE the BDOS label,
				; so `BDOS` already points at JP BDOSE — no
				; +6 offset needed.  Matches the prior
				; cpbios.asm `LD HL, BDOS` convention.
	shld	0006h
	jmp	NDOS+3		; NDOS COLDST

	end	boot
