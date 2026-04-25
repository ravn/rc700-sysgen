	title	'RC702 BIOS trampoline for CP/NOS 1.2'
;
; Replaces cpnet-z80/dist/src/cpbios.asm (which talks to Altos
; console/list ports 0x1C/0x1E).  On RC702 the console is the 8275
; CRT at 0xF800 and the list device is absent; those live in the
; cpnos-rom resident at VMA 0xED00+.
;
; This module provides:
;   - BIOS jump table (17 × 3-byte JPs) at `BIOS:`
;   - boot code that sets up CP/M zero page, copies the BIOS JT to
;     NDOSRL+0x300 (so CCP calls BIOS through the intercepted copy),
;     prints a signon banner via our resident CONOUT, and jumps to
;     NDOS coldstart.
;   - Thin const/conin/conout/list shims that call into the cpnos-rom
;     resident BIOS at 0xED00..0xED0F.  Register conversion: CP/M
;     passes char in C, returns status/char in A, preserves all other
;     regs.  cpnos-rom uses clang sdcccall(1): arg in A, 8-bit return
;     in L, callee-saved = none.  The shims bridge by pushing BC/DE
;     around the call and translating C↔A and L↔A.
;
;	Copyright (c) 1980..82 Digital Research (original concept)
;	RC702 retarget 2026-04, issue #38
;
true	equ	0ffffh
false	equ	not true
;
; cpnos-rom resident BIOS JT addresses (cpnos_rom.ld asserts these
; are stable: BIOS_BASE + 0/3/6/9/12/15).
rbboot	equ	0ED00h
rbwboot	equ	0ED03h
rbconst	equ	0ED06h
rbconin	equ	0ED09h
rbcout	equ	0ED0Ch
rblist	equ	0ED0Fh
;
	extrn	NDOS	; Network Disk Operating System
	extrn	BDOS	; Basic Disk Operating System
	extrn	NDOSRL	; NDOS serial number, BIOS jump table
			;  is page aligned at 0300H offset
	CSEG
BIOS:
	public	BIOS
;	jump vector for individual routines.  Console entries jump
;	directly into the resident BIOS JT — register translation /
;	BC,DE preservation lives in cpnos-rom's bios_shims.s now,
;	not in this file.  See memory note
;	project_cpnos_address_coupling_brittle.
	jmp	boot		; +0
wboote:	jmp	error		; +3  wboot (unused in CP/NOS)
	jmp	rbconst	; +6  CONST  (rbconst = 0xED06 = resident JT)
	jmp	rbconin	; +9  CONIN
	jmp	rbcout	; +12 CONOUT
	jmp	rblist	; +15 LIST
	jmp	error		; +18 PUNCH
	jmp	error		; +21 READER
	jmp	error		; +24 HOME
	jmp	error		; +27 SELDSK
	jmp	error		; +30 SETTRK
	jmp	error		; +33 SETSEC
	jmp	error		; +36 SETDMA
	jmp	error		; +39 READ
	jmp	error		; +42 WRITE
	jmp	lsshim	; +45 LISTST (local stub; resident has no impl)
	jmp	error		; +48 SECTRAN
BIOSlen	equ	$-BIOS
;
cr	equ	0dh
lf	equ	0ah
jpopc	equ	0c3h
buff	equ	0080h
;
signon:
;	db	cr,lf
	db	'RC702 CP/NOS v1.2'
	db	cr,lf,0
;
boot:	; print signon and jump to NDOS coldstart
	lxi	sp,buff+0080h
	lxi	h,signon
	call	prmsg
	mvi	a,jpopc
	sta	0000h
	sta	0005h
	lxi	h,BDOS
	shld	0006h
	xra	a
	sta	0004h
	lxi	h,NDOSRL+0303h
	shld	0001h
	dcx	h
	dcx	h
	dcx	h		; HL = NDOSRL+0300h (CCP's BIOS JT slot)
	lxi	d,BIOS
	mvi	c,BIOSlen
initloop:
	ldax	d
	mov	m,a
	inx	h
	inx	d
	dcr	c
	jnz	initloop
	jmp	NDOS+03h	; NDOS cold-start
;
; Utility
error:
	lxi	h,0ffffh
	mov	a,h
	ret
;
prmsg:	; print zero-terminated string at HL
	mov	a,m
	ora	a
	rz
	push	h
	mov	c,a
	call	rbcout	; resident bios_conout_shim handles BC/DE preservation
	pop	h
	inx	h
	jmp	prmsg
;
; LISTST stub — no list device on RC702.  Returns A=0 ("not ready"),
; matching original Altos behaviour when the port was absent.  Kept
; local because the resident's bios_jt routes LIST/LISTST to
; bios_stub_ret (a bare RET that leaves A undefined); cpnos.com
; callers expect a deterministic A on return.
lsshim:
	xra	a
	ret
;
; ABI shims for CONST/CONIN/CONOUT/LIST live in cpnos-rom/bios_shims.s
; (see memory: project_cpnos_address_coupling_brittle).  The cpnos.com
; side now just `JP rb<entry>`s into the resident BIOS JT slots.
;
	end
