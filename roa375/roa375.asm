;************************************************************************
;*									*
;* AUTOLOAD-FILE FOR THE RC702 MICROCOMPUTER				*
;*  									*
;* REGNECENTRALEN 1982							*
;*									*
;* Complete disassembly - REFERENCE VERSION				*
;* NOT byte-exact - see comments for differences			*
;*									*
;************************************************************************
;
; NOTE:  It is assumed for now that a modern assembler is used that accepts
; very long label names.  This will most likely be remidied when the work
; is finished.

.Z80

;========================================================================
; BOOT CODE - Executes from ROM at 0x0000-0x0066
;========================================================================

	ORG	0000H

BEGIN:
	DI				;Disable interrupts
	LD	SP,0BFFFH		;Set stack pointer
	LD	HL,MOVADR		;Point to relocatable code start

; Scan for actual code start (skip zeros)
SCANLP:
	LD	A,(HL)			;Get byte
	OR	A			;Zero?
	INC	HL
	JP	Z,SCANLP		;Keep scanning
	CP	0FFH			;Found 0xFF marker?
	JP	Z,SKIP
	DEC	HL			;Back up to non-zero
SKIP:
	EX	DE,HL			;DE = source address

; Copy 0x798 bytes from ROM to RAM at 0x7000
	LD	HL,07000H		;Destination
	LD	BC,main_last-ERRVEC1+1	;Count = 1944 bytes
COPYLP:
	LD	A,(DE)			;Get source
	LD	(HL),A			;Store
	INC	DE
	INC	HL
	DEC	BC
	LD	A,C
	OR	B
	JP	NZ,COPYLP
	JP	070D0H			;Jump to relocated init

;========================================================================
; PRE-INITIALIZATION - Executes from ROM at 0x0027-0x0066
; This runs before the main relocated code
;========================================================================

PREINIT:
	LD	A,003H
	LD	(L0801CH),A
	INC	A
	LD	(L0801DH),A
	LD	(L08042H),A

	LD	A,000H
	LD	B,A
	IN	A,(014H)		;Read switch settings
	AND	080H			;Mask mini/maxi bit
	ADD	A,B
	LD	(L07320H),A

	XOR	A			;Clear A
	LD	(L08033H),A
	LD	(L0801BH),A
	LD	(L08060H),A
	LD	(L08061H),A
	LD	(L08041H),A

	LD	C,008H
	LD	HL,L08063H
CLRLP:
	LD	(HL),A
	INC	HL
	DEC	C
	JP	NZ,CLRLP

	EI				;Enable interrupts
	LD	A,001H
	OUT	(014H),A		;ROM disable port
	LD	A,005H
	LD	(L08062H),A
	JP	07218H

; FIXME NMIRETURN must be precise
	RETN				; NMI-RETURN

MOVADR:
	DB	0FFH			;0xFF marker byte indicating start of code to relocate
					;This is most likely to ensure that the label is given
					;a non-relocated address.

;========================================================================
; RELOCATED CODE SECTION - Loaded to 0x7000, executed from there
;========================================================================

	phase	07000H

; This code gets copied from ROM offset 0x0068 to RAM at 0x7000
; From here on, all addresses are runtime addresses (0x7000+)

;------------------------------------------------------------------------
; Interrupt vectors and error handlers at 0x7000
;------------------------------------------------------------------------

L73DA	EQU	073DAH ; -- FIXME

; Error message display vectors
ERRVEC1:
	LD	BC,07800H		;Display buffer
	LD	DE,ERMES1		;Error message 1
	LD	HL,0014H		;Length
	CALL	MOVCPY			;Copy to screen
	JP	L73DA			;Display error

ERRVEC2:
	LD	BC,07800H
	LD	DE,ERMES3
	LD	HL,000FH
	CALL	MOVCPY
	JP	L73DA

ERRVEC3:
	LD	BC,07800H
	LD	DE,ERMES2
	LD	HL,001DH
	CALL	MOVCPY
	JP	L73DA

;------------------------------------------------------------------------
; Utility routines
;------------------------------------------------------------------------

SUB_2E:
	PUSH	HL
	INC	HL
	EX	DE,HL
	LD	BC,070C3H
	LD	HL,0004H
	CALL	SUB_5C
	POP	HL
	JP	Z,SUB_4F
	RET

SUB_3E:
	PUSH	HL
	INC	HL
	EX	DE,HL
	LD	BC,070C8H
	LD	HL,0004H
	CALL	SUB_5C
	POP	HL
	JP	Z,SUB_4F
	RET

SUB_4F:
	PUSH	HL
	INC	HL
	LD	DE,0007H
	ADD	HL,DE
	LD	A,(HL)
	AND	03FH
	CP	013H
	POP	HL
	RET

; Memory compare routine
SUB_5C:
	LD	A,(DE)
	LD	H,A
	LD	A,(BC)
	CP	H
	RET	NZ
	INC	DE
	INC	BC
	DEC	L
	JP	NZ,SUB_5C
	RET

; Memory copy routine
MOVCPY:
	LD	A,(DE)
	LD	(BC),A
	INC	BC
	INC	DE
	DEC	L
	JP	NZ,MOVCPY
	RET

;------------------------------------------------------------------------
; Error message strings
;------------------------------------------------------------------------
RC700TXT:
	DB	' RC700'
RC702TXT:
	DB	' RC702'
ERMES1:
	DB	' **NO SYSTEM FILES** '

ERMES2:
	DB	' **NO DISKETTE NOR LINEPROG** '

ERMES3:
	DB	' **NO KATALOG** '

NULLB:	DB	002H, 0C3H, 0C8H			;Control byte

	; JP	073C8H			;Jump table entry

FNAME1:	DB	'SYSM '			;System file name
FNAME2:	DB	'SYSC '

	DB	0C3H, 062H
	;JP	07362H			;Jump table entry

;------------------------------------------------------------------------
; INITIALIZATION ENTRY POINT at 070D0H
; Hardware and display initialization
;------------------------------------------------------------------------

INIT:
	DB	073H ; -- FIXME DI
	LD	SP,0BFFFH		;Reset stack
	LD	A,073H			;Interrupt vector high byte
	LD	I,A			;Set interrupt vector register
	IM	2			;Interrupt mode 2

; Initialize PIO for keyboard
	LD	C,0FFH
	LD	B,001H
	CALL	076B1H ; -- FIXME SUB_B1			;Wait routine

	LD	A,099H
	CALL	PIOINT			;PIO init
	LD	HL,00027H
	JP	(HL)

; PIO initialization
PIOINT:
	PUSH	AF
	LD	A,002H
	OUT	(012H),A		;PIO control
	LD	A,004H
	OUT	(013H),A
	LD	A,04FH
	OUT	(012H),A		;Set mode
	LD	A,00FH
	OUT	(013H),A
	LD	A,083H
	OUT	(012H),A		;Enable interrupts
	OUT	(013H),A
	JP	CTCINT

; CTC initialization
CTCINT:
	LD	A,008H
	OUT	(00CH),A		;CTC control
	POP	AF
	LD	A,046H
	OR	041H
	OUT	(00CH),A		;Channel 0
	LD	A,020H
	OUT	(00CH),A

	LD	A,046H
	OR	041H
	OUT	(00DH),A		;Channel 1
	LD	A,020H
	OUT	(00DH),A

	LD	A,0D7H
	OUT	(00EH),A		;Channel 2 (Display)
	LD	A,001H
	OUT	(00EH),A

	LD	A,0D7H
	OUT	(00FH),A		;Channel 3 (Floppy)
	LD	A,001H
	OUT	(00FH),A
	JP	DMAINT

; DMA initialization
DMAINT:
	LD	A,020H
	OUT	(0F8H),A		;DMA command

	LD	A,0C0H
	OUT	(0FBH),A		;Mode register
	LD	A,000H
	OUT	(0FAH),A		;Mask register

	LD	A,04AH
	OUT	(0FBH),A
	LD	A,04BH
	OUT	(0FBH),A
	JP	CRTINT

; CRT Controller (8275) initialization
CRTINT:
	LD	A,000H
	OUT	(001H),A		;Reset CRT

	LD	A,04FH
	OUT	(000H),A		;80 chars/row
	LD	A,098H
	OUT	(000H),A		;25 rows
	LD	A,09AH
	OUT	(000H),A		;Underline
	LD	A,05DH
	OUT	(000H),A		;Cursor format

	LD	A,080H
	OUT	(001H),A		;Load cursor
	XOR	A
	OUT	(000H),A		;Position 0
	OUT	(000H),A

	LD	A,0E0H
	OUT	(001H),A		;Preset counters
	JP	FDCINT

;------------------------------------------------------------------------
; Floppy disk controller (uPD765) initialization and status check
;------------------------------------------------------------------------

FDCDATA: ; -- FIXME EXPLAIN BYTES
	DB	003H, 003H, 04FH, 020H
FDCINT:
	LD	C,0FFH
	LD	B,001H
	CALL	076B1H ; -- FIXME SUB_B1			;Wait routine

	IN	A,(004H)		;FDC status
	AND	01FH
	JP	NZ,FDCINT

	LD	HL,FDCDATA
	LD	B,(HL)
FDCWAITNEXT:
	INC	HL
FDCWAIT:
	IN	A,(004H)
	AND	0C0H
	CP	080H
	JP	NZ,FDCWAIT

	LD	A,(HL)
	OUT	(005H),A		;FDC data
	DEC	B
	JP	NZ,FDCWAITNEXT
	JP	CLRSCR

; -- FDCDATA:
;FIXME	DB	03H,71H		;FDC command data

; FIXME FDCWAIT:
;	; FDC wait loop continues here

;------------------------------------------------------------------------
; Display screen clear and message display
;------------------------------------------------------------------------

CLRSCR:
	LD	HL,00000H
	EX	DE,HL
CLRLP1:
	LD	HL,07800H		;Display buffer
	ADD	HL,DE
	LD	A,020H			;Space character
	LD	(HL),A
	LD	A,E
	CP	0CFH
	JP	Z,NEXTLN
	INC	DE
	JP	CLRLP1

NEXTLN:
	LD	A,D
	CP	007H
	JP	Z,DISPMG
	INC	DE
	JP	CLRLP1

DISPMG:
	LD	DE,RC700TXT		;Message pointer
	LD	HL,0006H		;Length
	LD	BC,07800H		;Display buffer
	CALL	MOVCPY

; Initialize CRT DMA parameters
	LD	HL,00000H
	LD	(07FD2H),HL
	LD	(07FD9H),HL
	LD	(07FE4H),HL
	LD	(07FE2H),HL
	LD	(07FE0H),HL
	LD	(07FD7H),HL
	LD	(07FDEH),HL
	LD	(07FD5H),HL

	LD	HL,00780H
	LD	(07FDBH),HL

	LD	A,000H
	LD	(07FD1H),A
	LD	(07FD4H),A
	LD	(07FDDH),A
	LD	(07FE6H),A

	LD	A,023H
	OUT	(001H),A		;Start display
	RET

;------------------------------------------------------------------------
; MAIN BOOT SEQUENCE - Try hard disk, then floppy
;------------------------------------------------------------------------

BOOT:
	XOR	A
	LD	(L08032H),A
	INC	A
	LD	(L08033H),A
	LD	(L08034H),A

; Try hard disk boot
	CALL	074CBH ; --FIXME HDBOTT
	JP	C,L720B

	LD	HL,07320H		;Status flag
	LD	A,002H
	OR	(HL)
	LD	(HL),A

L720B:
	LD	HL,L08033H
	DEC	(HL)
	CALL	074CBH ; -- FIXME HDBOTT
	RET	NC

	LD	A,0FBH
	JP	072C4H;  -- FIXME ERRDSP

;------------------------------------------------------------------------
; Floppy disk boot sequence
;------------------------------------------------------------------------

FLDSK1:
	LD	B,001H
	LD	C,0FFH
	CALL	076B1H ; -- FIXME SUB_B1			;Wait routine
	CALL	07672H ; -- FIXME FLPRST
	LD	A,(L08010H)
	AND	023H
	LD	C,A
	LD	A,(L0801BH)
	ADD	A,020H
	CP	C
	JP	NZ,072C4H ; -- FIXME ERRDSP
	CALL	0770BH ; -- FIXME FLDSK2
	JP	C,072C4H ; -- FIXME ERRDSP
	JP	Z,0723DH; -- FIXME FLDSK3
	JP	072C4H; -- FIXME ERRDSP

FLDSK2:
	; Floppy disk read routine
	; FIXME RET

FLDSK3:
	CALL	BOOT ; -- FIXME CLRSCR
	LD	A,001H
	OUT	(018H),A		;Beeper
BOOT4:
	LD	HL,(L08067H)
	CALL	07425H ; -- BOOT2
	LD	A,(L08032H)
	OR	A
	JP	NZ,BOOT2
	CALL	074CBH ; -- FIXME HDBOTT
	JP	BOOT4

BOOT2:
	; Boot helper routine
;	RET

BOOT3:
	LD	A,001H
	LD	(L08060H),A
	CALL	BOOT7
	JP	07403H ; -- FIXME BOOT6


;------------------------------------------------------------------------
; Additional boot helper routines
;------------------------------------------------------------------------

BOOT7:
	LD	A,00AH
	LD	HL,00000H
	CALL	072aaH; -- FIXME CHKFIL
	JP	Z,0727ch ; -- fixme BOOT8
	LD	A,00BH
	CALL	072aaH; -- FIXME CHKFIL
	JP	Z,BOOT9
	JP	ERRVEC2

BOOT9:
	LD	HL,(00000H)
	JP	(HL)

	LD	HL, 0
	LD	DE, 0B60H
	ADD	HL, DE
L7283H: ; -- FIXME
	LD	DE, 20H
	ADD	HL, DE
	LD	BC, 0D00H
	LD	A,B
	CP	H
	JP	C, 07000H ; -- FIXME
	LD	A,(HL)
	OR	A
	JP	Z, L7283H
	CALL	SUB_2E
	JP	NZ, ERRVEC1
	LD	DE, 20h
	ADD	HL, DE
	LD	A, (HL)
	OR	A
	JP	Z, ERRVEC1
	CALL	SUB_3E
	JP	NZ, ERRVEC1
	RET

L72AA:
	LD	DE, 2
	ADD	HL, DE
	EX	DE, HL
	LD 	BC, RC700TXT
	LD	HL, 6
	CP	0AH
	JP	Z,L72C0
	LD	BC, RC702TXT
	LD	HL, 6
L72C0:
	CALL	SUB_5C
	RET

L72C4:
	LD	A, 0BH
	LD	HL, 02000H
	CALL	L72AA
	JP	Z, L72D2
	JP	ERRVEC3

L72D2:
	LD	HL,(02000H)
	JP	(HL)

;------------------------------------------------------------------------
; Disk format/geometry tables
;------------------------------------------------------------------------

; Mini (5.25") disk format
MINIFMT:
	DB	01AH,07H,34H,07H,0FH,0EH,1AH,0EH,08H,1BH,0FH,1BH,00H,00H
	DB	08H,35H,10H,07H,20H,07H,09H,0EH,10H,0EH,05H,1BH,09H,1BH,00H,00H
	DB	05H,35H

; Padding
	DB	00H,00H,00H,00H,00H,00H,00H,00H,00H,00H

;------------------------------------------------------------------------
; Interrupt vector table (16 entries)
;------------------------------------------------------------------------

INTVEC: ; -- FIXME REPLACE WITH LABELS
;	DW	L73C6,L73C6,L73C6,L73C6,L73C6,L73C6,L73BB,L73C2
;	DW	L73C6,L73C6,L73C6,L73C6,L73C6,L73C6H,L73C6,L73C6

	DW	073C6H,073C6H,073C6H,073C6H,073C6H,073C6H,073BBH,073C2H
	DW	073C6H,073C6H,073C6H,073C6H,073C6H,073C6H,073C6H,073C6H
L07320H:
	DB	00H
	DB	00H

;------------------------------------------------------------------------
; System call and interrupt handlers
; 
; *** MISMATCH WARNING ***
; The following sections may not assemble byte-exact due to:
; - Complex addressing modes
; - Self-modifying code
; - Embedded data tables
; Compare with original ROM at 0x7300+ for exact bytes
;------------------------------------------------------------------------
SYSCALL:
	LD	(L08065H),HL
	LD	HL,00000H
	ADD	HL,SP
	LD	(L0801EH),HL
	PUSH	BC
	EX	DE,HL
	LD	A,C
	AND	07FH
	LD	(L08034H),A
	LD	A,B
	AND	07FH
	LD	(L08032H),A
	CALL	Z, 074CBH ; -- FIXME
	LD	A,B
	AND	080H
	JP	Z,L7345
	LD	A,001H
L7345:
	LD	(L08033H),A
	CALL	07425H ; -- FIXME
	POP	BC
	PUSH	AF
	LD	A,B
	AND	07FH
	JP	NZ,0735bH ; -- FIXME
	LD	A,001H
	LD	(L08032H),A
	CALL	074CBH ; -- FIXME
	POP	AF
	XOR	A
	LD	HL,(L0801EH)
	LD	SP,HL
	RET

	if 0
L7362:
	PUSH	AF
	IN	A,(01)
	PUSH	HL
	PUSH	DE
	PUSH	BC
	LD	A,6
	OUT	(0FAH), A
	LD	A,7
	OUT	(0FAH), A

	DB	0



SYSC1:
	LD	A,001H
	RET

SYSC2:
	POP	AF
	RET

	endif

;------------------------------------------------------------------------
; Display interrupt handler
;------------------------------------------------------------------------
DISINT:
	PUSH	AF
	IN	A,(001H)
	PUSH	HL
	PUSH	DE
	PUSH	BC
	LD	A,006H
	OUT	(0FAH),A
	LD	A,007H
	OUT	(0FAH),A
	OUT	(0FCH),A
	LD	HL,(07FD5H)
	LD	DE,07800H
	ADD	HL,DE
	LD	A,L
	OUT	(0F4H),A
	LD	A,H
	OUT	(0F4H),A
	LD	A,L
	CPL
	LD	L,A
	LD	A,H
	CPL
	LD	H,A
	INC	HL
	LD	DE,007CFH
	ADD	HL,DE
	LD	DE,07800H
	ADD	HL,DE
	LD	A,L
	OUT	(0F5H),A
	LD	A,H
	OUT	(0F5H),A
	LD	HL,07800H
	LD	A,L
	OUT	(0F6H),A
	LD	A,H
	OUT	(0F6H),A
	LD	HL,007CFH
	LD	A,L
	OUT	(0F7H),A
	LD	A,H
	OUT	(0F7H),A
	LD	A,002H
	OUT	(0FAH),A
	LD	A,003H
	OUT	(0FAH),A
	POP	BC
	POP	DE
	POP	HL
	LD	A,0D7H
	OUT	(00EH),A
	LD	A,001H
	OUT	(00EH),A
	POP	AF
	RET

;------------------------------------------------------------------------
; Hard disk and floppy interrupt handlers
;------------------------------------------------------------------------

HDINT:
	DI
	CALL	DISINT
	EI
	RETI

FLPINT:
	DI
	JP	07770H ; -- FIXME

DUMINT:
	EI
	RETI

; ---- END OF DISASSEMBLY CONSTRUCTED BY CLAUDE.

; BLOCK 'errdsp' (start 0x73ca end 0x73f1)
errdsp_start:
	ld (L08003h),a		;73ca	32 03 80	2 . .
	ei			;73cd	fb		.
	ld a,(L08060h)		;73ce	3a 60 80	: ` .
	and 001h		;73d1	e6 01		. .
	jp nz,0735dh		;73d3	c2 5d 73	. ] s
	out (01ch),a		;73d6	d3 1c		. .
	call 073deh		;73d8	cd de 73	. . s
	or a			;73db	b7		.
	jp 073dah		;73dc	c3 da 73	. . s
	ld bc,07800h		;73df	01 00 78	. . x
	ld de,l73f0h		;73e2	11 f0 73	. . s
	ld hl,00012h		;73e5	21 12 00	! . .
	ld a,(de)		;73e8	1a		.
	ld (bc),a		;73e9	02		.
	inc bc			;73ea	03		.
	inc de			;73eb	13		.
	dec l			;73ec	2d		-
	jp nz,073e7h		;73ed	c2 e7 73	. . s
	ret			;73f0	c9		.
l73f0h:

; BLOCK 'errmsg' (start 0x73f1 end 0x7404)
DISKETTEERRORTXT:
	defb '**DISKETTE ERROR** '	;73f1-7403

; BLOCK 'main' (start 0x7404 end 0x7798)
main_start:
	ld a,(07320h)		;7404	3a 20 73	:   s
	and 080h		;7407	e6 80		. .
	ld hl,L08060h		;7409	21 60 80	! ` .
	or (hl)			;740c	b6		.
	ld (hl),a		;740d	77		w
	dec (hl)		;740e	35		5
	call sub_74cbh		;740f	cd cb 74	. . t
	ld hl,00000h		;7412	21 00 00	! . .
	ld (L08065h),hl		;7415	22 65 80	" e .
	ld hl,07300h		;7418	21 00 73	! . s
	call 07425h		;741b	cd 25 74	. % t
	ld a,001h		;741e	3e 01		> .
	ld (L08060h),a		;7420	32 60 80	2 ` .
	jp 01000h		;7423	c3 00 10	. . .
	ld a,000h		;7426	3e 00		> .
	ld (L08069h),hl		;7428	22 69 80	" i .
	call sub_7721h		;742b	cd 21 77	. ! w
	jp c,072c4h		;742e	da c4 72	. . r
	jp z,07438h		;7431	ca 38 74	. 8 t
	ld a,006h		;7434	3e 06		> .
	jp 073c9h		;7436	c3 c9 73	. . s
	call sub_7481h		;7439	cd 81 74	. . t
	ld a,006h		;743c	3e 06		> .
	ld c,005h		;743e	0e 05		. .
	call sub_7583h		;7440	cd 83 75	. . u
	jp nc,0744ah		;7443	d2 4a 74	. J t
	ld a,028h		;7446	3e 28		> (
	jp 073c9h		;7448	c3 c9 73	. . s
	ld hl,(L08067h)		;744b	2a 67 80	* g .
	ex de,hl		;744e	eb		.
	ld hl,(L08065h)		;744f	2a 65 80	* e .
	add hl,de		;7452	19		.
	ld (L08065h),hl		;7453	22 65 80	" e .
	ld l,000h		;7456	2e 00		. .
	ld h,l			;7458	65		e
	ld (L08067h),hl		;7459	22 67 80	" g .
	call 07466h		;745c	cd 66 74	. f t
	ld a,(L08061h)		;745f	3a 61 80	: a .
	or a			;7462	b7		.
	ret z			;7463	c8		.
	jp 0742ah		;7464	c3 2a 74	. * t
	ld a,001h		;7467	3e 01		> .
	ld (L08034h),a		;7469	32 34 80	2 4 .
	ld a,(07320h)		;746c	3a 20 73	:   s
	and 002h		;746f	e6 02		. .
	rrca			;7471	0f		.
	ld hl,L08033h		;7472	21 33 80	! 3 .
	cp (hl)			;7475	be		.
	jp z,l747ah		;7476	ca 7a 74	. z t
	inc (hl)		;7479	34		4
	ret			;747a	c9		.
l747ah:
	xor a			;747b	af		.
	ld (hl),a		;747c	77		w
	ld hl,L08032h		;747d	21 32 80	! 2 .
	inc (hl)		;7480	34		4
	ret			;7481	c9		.

sub_7481h:
	ld hl,(L08069h)		;7482	2a 69 80	* i .
	push hl			;7485	e5		.
	call sub_7547h		;7486	cd 47 75	. G u
	call sub_74aeh		;7489	cd ae 74	. . t
	pop de			;748c	d1		.
	add hl,de		;748d	19		.
	jp nc,l749eh		;748e	d2 9e 74	. . t
	ld a,h			;7491	7c		|
	or l			;7492	b5		.
	jp z,l749eh		;7493	ca 9e 74	. . t
	ld a,001h		;7496	3e 01		> .
	ld (L08061h),a		;7498	32 61 80	2 a .
	ld (L08069h),hl		;749b	22 69 80	" i .
	ret			;749e	c9		.

l749eh:
	ld a,000h		;749f	3e 00		> .
	ld (L08061h),a		;74a1	32 61 80	2 a .
	ld (L08069h),a		;74a4	32 69 80	2 i .
	ld (L0806ah),a		;74a7	32 6a 80	2 j .
	ex de,hl		;74aa	eb		.
	ld (L08067h),hl		;74ab	22 67 80	" g .
	ret			;74ae	c9		.

sub_74aeh:
	push af			;74af	f5		.
	ld a,l			;74b0	7d		}
	cpl			;74b1	2f		/
	ld l,a			;74b2	6f		o
	ld a,h			;74b3	7c		|
	cpl			;74b4	2f		/
	ld h,a			;74b5	67		g
	inc hl			;74b6	23		#
	pop af			;74b7	f1		.
	ret			;74b8	c9		.

sub_74b8h:
	ld a,(07320h)		;74b9	3a 20 73	:   s
	and 01ch		;74bc	e6 1c		. .
	rra			;74be	1f		.
	rra			;74bf	1f		.
	and 007h		;74c0	e6 07		. .
	ld (L08035h),a		;74c2	32 35 80	2 5 .
	call sub_750ah		;74c5	cd 0a 75	. . u
	call sub_7547h		;74c8	cd 47 75	. G u
	ret			;74cb	c9		.

sub_74cbh:
	ld a,(07320h)		;74cc	3a 20 73	:   s
	and 0feh		;74cf	e6 fe		. .
	ld (07320h),a		;74d1	32 20 73	2   s
	call sub_7721h		;74d4	cd 21 77	. ! w
	jp nz,l7508h		;74d7	c2 08 75	. . u
	ld l,004h		;74da	2e 04		. .
	ld h,000h		;74dc	26 00		& .
	ld (L08067h),hl		;74de	22 67 80	" g .
	ld a,00ah		;74e1	3e 0a		> .
	ld c,001h		;74e3	0e 01		. .
	call sub_7583h		;74e5	cd 83 75	. . u
	ld hl,07320h		;74e8	21 20 73	!   s
	jp nc,074f7h		;74eb	d2 f7 74	. . t
	ld a,(hl)		;74ee	7e		~
	and 001h		;74ef	e6 01		. .
	jp nz,l7508h		;74f1	c2 08 75	. . u
	inc (hl)		;74f4	34		4
	jp 074d3h		;74f5	c3 d3 74	. . t
	ld a,(L08016h)		;74f8	3a 16 80	: . .
	rlca			;74fb	07		.
	rlca			;74fc	07		.
	ld b,a			;74fd	47		G
	ld a,(hl)		;74fe	7e		~
	and 0e3h		;74ff	e6 e3		. .
	add a,b			;7501	80		.
	ld (hl),a		;7502	77		w
	call sub_74b8h		;7503	cd b8 74	. . t
	scf			;7506	37		7
	ccf			;7507	3f		?
	ret			;7508	c9		.
l7508h:
	scf			;7509	37		7
	ret			;750a	c9		.

sub_750ah:
	ld a,(L08035h)		;750b	3a 35 80	: 5 .
	rla			;750e	17		.
	rla			;750f	17		.
	ld e,a			;7510	5f		_
	ld d,000h		;7511	16 00		. .
	ld hl,072d6h		;7513	21 d6 72	! . r
	ld a,(07320h)		;7516	3a 20 73	:   s
	and 080h		;7519	e6 80		. .
	ld a,04ch		;751b	3e 4c		> L
	jp z,07524h		;751d	ca 24 75	. $ u
	ld a,023h		;7520	3e 23		> #
	ld hl,072e6h		;7522	21 e6 72	! . r
	ld (L0800ch),a		;7525	32 0c 80	2 . .
	add hl,de		;7528	19		.
	ld a,(07320h)		;7529	3a 20 73	:   s
	and 001h		;752c	e6 01		. .
	jp z,l7535h		;752e	ca 35 75	. 5 u
	ld e,002h		;7531	1e 02		. .
	ld d,000h		;7533	16 00		. .
	add hl,de		;7535	19		.

l7535h:
	ex de,hl		;7536	eb		.
	ld hl,L08036h		;7537	21 36 80	! 6 .
	ld a,(de)		;753a	1a		.
	ld (hl),a		;753b	77		w
	ld (L0800dh),a		;753c	32 0d 80	2 . .
	inc hl			;753f	23		#
	inc de			;7540	13		.
	ld a,(de)		;7541	1a		.
	ld (hl),a		;7542	77		w
	inc hl			;7543	23		#
	ld a,080h		;7544	3e 80		> .
	ld (hl),a		;7546	77		w
	ret			;7547	c9		.

sub_7547h:
	ld hl,00080h		;7548	21 80 00	! . .
	ld a,(L08035h)		;754b	3a 35 80	: 5 .
	or a			;754e	b7		.
	jp z,07556h		;754f	ca 56 75	. V u
	add hl,hl		;7552	29		)
	dec a			;7553	3d		=
	jp nz,07551h		;7554	c2 51 75	. Q u
	ld (L08039h),hl		;7557	22 39 80	" 9 .
	ex de,hl		;755a	eb		.
	ld a,(L08034h)		;755b	3a 34 80	: 4 .
	ld l,a			;755e	6f		o
	ld a,(L08036h)		;755f	3a 36 80	: 6 .
	sub l			;7562	95		.
	inc a			;7563	3c		<
	ld l,a			;7564	6f		o
	ld a,(L08060h)		;7565	3a 60 80	: ` .
	and 080h		;7568	e6 80		. .
	jp z,07576h		;756a	ca 76 75	. v u
	ld a,(L08033h)		;756d	3a 33 80	: 3 .
	xor 001h		;7570	ee 01		. .
	jp nz,07576h		;7572	c2 76 75	. v u
	ld l,00ah		;7575	2e 0a		. .
	ld a,l			;7577	7d		}
	ld l,000h		;7578	2e 00		. .
	ld h,l			;757a	65		e
l757ah:
	add hl,de		;757b	19		.
	dec a			;757c	3d		=
	jp nz,l757ah		;757d	c2 7a 75	. z u
	ld (L08067h),hl		;7580	22 67 80	" g .
	ret			;7583	c9		.

sub_7583h:
	push af			;7584	f5		.
	ld a,c			;7585	79		y
	ld (L08062h),a		;7586	32 62 80	2 b .
	call sub_769dh		;7589	cd 9d 76	. . v
	ld hl,(L08067h)		;758c	2a 67 80	* g .
	ld b,h			;758f	44		D
	ld c,l			;7590	4d		M
	dec bc			;7591	0b		.
	ld hl,(L08065h)		;7592	2a 65 80	* e .
	pop af			;7595	f1		.
	push af			;7596	f5		.
	and 00fh		;7597	e6 0f		. .
	cp 00ah			;7599	fe 0a		. .
	call nz,sub_7632h	;759b	c4 32 76	. 2 v
	pop af			;759e	f1		.
	ld c,a			;759f	4f		O
	call sub_75ddh		;75a0	cd dd 75	. . u
	ld a,0ffh		;75a3	3e ff		> .
	call sub_76c3h		;75a5	cd c3 76	. . v
	ret c			;75a8	d8		.
	ld a,c			;75a9	79		y
	call 075b3h		;75aa	cd b3 75	. . u
	ret nc			;75ad	d0		.
	ret z			;75ae	c8		.
	ld a,c			;75af	79		y
	push af			;75b0	f5		.
	jp 07588h		;75b1	c3 88 75	. . u
	ld hl,L08010h		;75b4	21 10 80	! . .
	ld a,(hl)		;75b7	7e		~
	and 0c3h		;75b8	e6 c3		. .
	ld b,a			;75ba	47		G
	ld a,(L0801bh)		;75bb	3a 1b 80	: . .
	cp b			;75be	b8		.
	jp nz,l75d4h		;75bf	c2 d4 75	. . u
	inc hl			;75c2	23		#
	ld a,(hl)		;75c3	7e		~
	cp 000h			;75c4	fe 00		. .
	jp nz,l75d4h		;75c6	c2 d4 75	. . u
	inc hl			;75c9	23		#
	ld a,(hl)		;75ca	7e		~
	and 0bfh		;75cb	e6 bf		. .
	cp 000h			;75cd	fe 00		. .
	jp nz,l75d4h		;75cf	c2 d4 75	. . u
	scf			;75d2	37		7
	ccf			;75d3	3f		?
	ret			;75d4	c9		.

l75d4h:
	ld a,(L08062h)		;75d5	3a 62 80	: b .
	dec a			;75d8	3d		=
	ld (L08062h),a		;75d9	32 62 80	2 b .
	scf			;75dc	37		7
	ret			;75dd	c9		.

sub_75ddh:
	push bc			;75de	c5		.
	push af			;75df	f5		.
	di			;75e0	f3		.
	ld a,0ffh		;75e1	3e ff		> .
	ld hl,L08030h		;75e3	21 30 80	! 0 .
	ld (L0800bh),a		;75e6	32 0b 80	2 . .
	ld a,(07320h)		;75e9	3a 20 73	:   s
	and 001h		;75ec	e6 01		. .
	jp z,075f2h		;75ee	ca f2 75	. . u
	ld a,040h		;75f1	3e 40		> @
	ld b,a			;75f3	47		G
	pop af			;75f4	f1		.
	push af			;75f5	f5		.
	add a,b			;75f6	80		.
	ld (hl),a		;75f7	77		w
	inc hl			;75f8	23		#
	call sub_76a4h		;75f9	cd a4 76	. . v
	ld (hl),a		;75fc	77		w
	dec hl			;75fd	2b		+
	pop af			;75fe	f1		.
	and 00fh		;75ff	e6 0f		. .
	cp 006h			;7601	fe 06		. .
	ld c,009h		;7603	0e 09		. .
	jp z,07609h		;7605	ca 09 76	. . v
	ld c,002h		;7608	0e 02		. .
	ld a,(hl)		;760a	7e		~
	inc hl			;760b	23		#
	call 0763ch		;760c	cd 3c 76	. < v
	dec c			;760f	0d		.
	jp nz,07609h		;7610	c2 09 76	. . v
	pop bc			;7613	c1		.
	ei			;7614	fb		.
	ret			;7615	c9		.
	ld a,005h		;7616	3e 05		> .
	di			;7618	f3		.
	out (0fah),a		;7619	d3 fa		. .
	ld a,049h		;761b	3e 49		> I
	out (0fbh),a		;761d	d3 fb		. .
	out (0fch),a		;761f	d3 fc		. .
	ld a,l			;7621	7d		}
	out (0f2h),a		;7622	d3 f2		. .
	ld a,h			;7624	7c		|
	out (0f2h),a		;7625	d3 f2		. .
	ld a,c			;7627	79		y
	out (0f3h),a		;7628	d3 f3		. .
	ld a,b			;762a	78		x
	out (0f3h),a		;762b	d3 f3		. .
	ld a,001h		;762d	3e 01		> .
	out (0fah),a		;762f	d3 fa		. .
	ei			;7631	fb		.
	ret			;7632	c9		.

sub_7632h:
	ld a,005h		;7633	3e 05		> .
	di			;7635	f3		.
	out (0fah),a		;7636	d3 fa		. .
	ld a,045h		;7638	3e 45		> E
	jp 0761ch		;763a	c3 1c 76	. . v
	push af			;763d	f5		.
	push bc			;763e	c5		.
	ld b,000h		;763f	06 00		. .
	ld c,000h		;7641	0e 00		. .
	inc b			;7643	04		.
	call z,sub_766ah	;7644	cc 6a 76	. j v
	in a,(004h)		;7647	db 04		. .
	and 0c0h		;7649	e6 c0		. .
	cp 080h			;764b	fe 80		. .
	jp nz,07642h		;764d	c2 42 76	. B v
	pop bc			;7650	c1		.
	pop af			;7651	f1		.
	out (005h),a		;7652	d3 05		. .
	ret			;7654	c9		.

sub_7654h:
	push bc			;7655	c5		.
	ld b,000h		;7656	06 00		. .
	ld c,000h		;7658	0e 00		. .
	inc b			;765a	04		.
	call z,sub_766ah	;765b	cc 6a 76	. j v
	in a,(004h)		;765e	db 04		. .
	and 0c0h		;7660	e6 c0		. .
	cp 0c0h			;7662	fe c0		. .
	jp nz,07659h		;7664	c2 59 76	. Y v
	pop bc			;7667	c1		.
	in a,(005h)		;7668	db 05		. .
	ret			;766a	c9		.

sub_766ah:
	ld b,000h		;766b	06 00		. .
	inc c			;766d	0c		.
	ret nz			;766e	c0		.
	ei			;766f	fb		.
	jp 072c4h		;7670	c3 c4 72	. . r
	ld a,004h		;7673	3e 04		> .
	call 0763ch		;7675	cd 3c 76	. < v
	ld a,(L0801bh)		;7678	3a 1b 80	: . .
	call 0763ch		;767b	cd 3c 76	. < v
	call sub_7654h		;767e	cd 54 76	. T v
	ld (L08010h),a		;7681	32 10 80	2 . .
	ret			;7684	c9		.

sub_7684h:
	ld a,008h		;7685	3e 08		> .
	call 0763ch		;7687	cd 3c 76	. < v
	call sub_7654h		;768a	cd 54 76	. T v
	ld (L08010h),a		;768d	32 10 80	2 . .
	and 0c0h		;7690	e6 c0		. .
	cp 080h			;7692	fe 80		. .
	jp z,0769ch		;7694	ca 9c 76	. . v
	call sub_7654h		;7697	cd 54 76	. T v
	ld (L08011h),a		;769a	32 11 80	2 . .
	ret			;769d	c9		.

sub_769dh:
	di			;769e	f3		.
	xor a			;769f	af		.
	ld (L08041h),a		;76a0	32 41 80	2 A .
	ei			;76a3	fb		.
	ret			;76a4	c9		.

sub_76a4h:
	push de			;76a5	d5		.
	ld a,(L08033h)		;76a6	3a 33 80	: 3 .
	rla			;76a9	17		.
	rla			;76aa	17		.
	ld d,a			;76ab	57		W
	ld a,(L0801bh)		;76ac	3a 1b 80	: . .
	add a,d			;76af	82		.
	pop de			;76b0	d1		.
	ret			;76b1	c9		.

sub_76b1h:
	push af			;76b2	f5		.
	push hl			;76b3	e5		.
l76b3h:
	ld h,c			;76b4	61		a
	ld l,0ffh		;76b5	2e ff		. .
	dec hl			;76b7	2b		+
	ld a,l			;76b8	7d		}
	or h			;76b9	b4		.
	jp nz,076b6h		;76ba	c2 b6 76	. . v
	dec b			;76bd	05		.
	jp nz,l76b3h		;76be	c2 b3 76	. . v
	pop hl			;76c1	e1		.
	pop af			;76c2	f1		.
	ret			;76c3	c9		.

sub_76c3h:
	push bc			;76c4	c5		.
l76c4h:
	dec a			;76c5	3d		=
	scf			;76c6	37		7
	jp z,076dfh		;76c7	ca df 76	. . v
	ld b,001h		;76ca	06 01		. .
	ld c,001h		;76cc	0e 01		. .
	call sub_76b1h		;76ce	cd b1 76	. . v
	ld b,a			;76d1	47		G
	ld a,(L08041h)		;76d2	3a 41 80	: A .
	and 002h		;76d5	e6 02		. .
	ld a,b			;76d7	78		x
	jp z,l76c4h		;76d8	ca c4 76	. . v
	scf			;76db	37		7
	ccf			;76dc	3f		?
	call sub_769dh		;76dd	cd 9d 76	. . v
	pop bc			;76e0	c1		.
	ret			;76e1	c9		.

sub_76e1h:
	ld a,0ffh		;76e2	3e ff		> .
	call sub_76c3h		;76e4	cd c3 76	. . v
	ld a,(L08010h)		;76e7	3a 10 80	: . .
	ld b,a			;76ea	47		G
	ld a,(L08011h)		;76eb	3a 11 80	: . .
	ld c,a			;76ee	4f		O
	ret			;76ef	c9		.

sub_76efh:
	ld a,007h		;76f0	3e 07		> .
	call 0763ch		;76f2	cd 3c 76	. < v
	ld a,(L0801bh)		;76f5	3a 1b 80	: . .
	call 0763ch		;76f8	cd 3c 76	. < v
	ret			;76fb	c9		.

sub_76fbh:
	ld a,00fh		;76fc	3e 0f		> .
	call 0763ch		;76fe	cd 3c 76	. < v
	ld a,d			;7701	7a		z
	and 007h		;7702	e6 07		. .
	call 0763ch		;7704	cd 3c 76	. < v
	ld a,e			;7707	7b		{
	call 0763ch		;7708	cd 3c 76	. < v
	ret			;770b	c9		.
	call sub_76efh		;770c	cd ef 76	. . v
	call sub_76e1h		;770f	cd e1 76	. . v
	ret c			;7712	d8		.
	ld a,(L0801bh)		;7713	3a 1b 80	: . .
	add a,020h		;7716	c6 20		.
	cp b			;7718	b8		.
	jp nz,0771eh		;7719	c2 1e 77	. . w
	ld a,c			;771c	79		y
	cp 000h			;771d	fe 00		. .
	scf			;771f	37		7
	ccf			;7720	3f		?
	ret			;7721	c9		.

sub_7721h:
	ld a,(L08032h)		;7722	3a 32 80	: 2 .
	ld e,a			;7725	5f		_
	call sub_76a4h		;7726	cd a4 76	. . v
	ld d,a			;7729	57		W
	call sub_76fbh		;772a	cd fb 76	. . v
	call sub_76e1h		;772d	cd e1 76	. . v
	ret c			;7730	d8		.
	ld a,(L0801bh)		;7731	3a 1b 80	: . .
	add a,020h		;7734	c6 20		.
	cp b			;7736	b8		.
	jp nz,l773dh		;7737	c2 3d 77	. = w
	ld a,(L08032h)		;773a	3a 32 80	: 2 .
	cp c			;773d	b9		.
l773dh:
	scf			;773e	37		7
	ccf			;773f	3f		?
	ret			;7740	c9		.
sub_7740h:
	ld hl,L08010h		;7741	21 10 80	! . .
	ld b,007h		;7744	06 07		. .
	ld a,b			;7746	78		x
	ld (L0800bh),a		;7747	32 0b 80	2 . .
	call sub_7654h		;774a	cd 54 76	. T v
	ld (hl),a		;774d	77		w
	inc hl			;774e	23		#
	ld a,(L0801dh)		;774f	3a 1d 80	: . .
	dec a			;7752	3d		=
	jp nz,07751h		;7753	c2 51 77	. Q w
	in a,(004h)		;7756	db 04		. .
	and 010h		;7758	e6 10		. .
	jp z,07765h		;775a	ca 65 77	. e w
	dec b			;775d	05		.
	jp nz,07749h		;775e	c2 49 77	. I w
	ld a,0feh		;7761	3e fe		> .
	jp 073c9h		;7763	c3 c9 73	. . s
	in a,(0f8h)		;7766	db f8		. .
	ld (hl),a		;7768	77		w
	dec b			;7769	05		.
	ret z			;776a	c8		.
	ei			;776b	fb		.
	ld a,0fdh		;776c	3e fd		> .
	jp 073c9h		;776e	c3 c9 73	. . s
L7771:
	push af			;7771	f5		.
	push bc			;7772	c5		.
	push hl			;7773	e5		.
	ld a,002h		;7774	3e 02		> .
	ld (L08041h),a		;7776	32 41 80	2 A .
	ld a,(L0801ch)		;7779	3a 1c 80	: . .
	dec a			;777c	3d		=
	jp nz,0777bh		;777d	c2 7b 77	. { w
	in a,(004h)		;7780	db 04		. .
	and 010h		;7782	e6 10		. .
	jp nz,0778ch		;7784	c2 8c 77	. . w
	call sub_7684h		;7787	cd 84 76	. . v
	jp 0778fh		;778a	c3 8f 77	. . w
	call sub_7740h		;778d	cd 40 77	. @ w
	pop hl			;7790	e1		.
	pop bc			;7791	c1		.
	pop af			;7792	f1		.
	ei			;7793	fb		.
	reti			;7794	ed 4d		. M
	nop			;7796	00		.
	nop			;7797	00		.
main_last:
	dephase

	; DATA AREA
	ORG	08000H
	DS	03H
L08003H:
	DS	1
	DS	7
L0800BH:
	DS	1
L0800CH:
	DS	1
L0800DH:
	DS	1
	DS	2
L08010H:
	DS	1H
L08011H:
	DS	5
L08016H:
	DS	1
	DS	4
L0801BH:
	DS	1
L0801CH:
	DS	1
L0801DH:
	DS	1
L0801EH:
	DS	12H
L08030H:
	DS	1
	DS	1
L08032H:
	DS	1
L08033H:
	DS	1
L08034H:
	DS	1
L08035H:
	DS	1
L08036H:
	DS	1
	DS	2
L08039H:
	DS	1

	DS	7
L08041H:
	DS	1
L08042H:
	DS	1

	DS	29
L08060H:
	DS	1
L08061H:
	DS	1
L08062H:
	DS	1
L08063H:
	DS	1

	DS	1
L08065H:
	DS	1
	DS	1
L08067H:
	DS	1
	DS	1
L08069H:
	DS	1
L0806AH:
	DS	1





	END
