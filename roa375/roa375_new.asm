;************************************************************************
;*									*
;* AUTOLOAD-FILE FOR THE RC702 MICROCOMPUTER				*
;*  									*
;* REGNECENTRALEN 1982							*
;*									*
;* Reconstructed from ROM dump - Disassembled for readability		*
;*									*
;************************************************************************
.Z80

;========================================================================
; BOOT CODE - Executes from ROM at 0x0000-0x0066
;========================================================================

	ORG	0000H

BEGIN:
	DI				;Disable interrupts
	LD	SP,0BFFFH		;Set stack pointer
	LD	HL,0068H		;Point to relocatable code start

; Scan for actual code start (skip zeros)
SCANLP:
	LD	A,(HL)			;Get byte
	OR	A			;Zero?
	INC	HL
	JP	Z,SCANLP		;Keep scanning
	CP	0FFH			;Found 0xFF marker?
	JP	Z,FOUND
	DEC	HL			;Back up to non-zero
FOUND:
	EX	DE,HL			;DE = source address

; Copy 0x798 bytes from ROM to RAM at 0x7000
	LD	HL,07000H		;Destination
	LD	BC,0798H		;Count = 1944 bytes
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
	LD	(0801CH),A
	INC	A
	LD	(0801DH),A
	LD	(08042H),A

	LD	A,000H
	LD	B,A
	IN	A,(014H)		;Read switch settings
	AND	080H			;Mask mini/maxi bit
	ADD	A,B
	LD	(07320H),A

	XOR	A			;Clear A
	LD	(08033H),A
	LD	(0801BH),A
	LD	(08060H),A
	LD	(08061H),A
	LD	(08041H),A

	LD	C,008H
	LD	HL,08063H
CLRLP:
	LD	(HL),A
	INC	HL
	DEC	C
	JP	NZ,CLRLP

	EI				;Enable interrupts
	LD	A,001H
	OUT	(014H),A		;ROM disable port
	LD	A,005H
	LD	(08062H),A
	JP	07218H

	RETN				;Padding

;========================================================================
; RELOCATED CODE SECTION - Loaded to 0x7000, executed from there
;========================================================================

MOVADR:
	phase	07000H

; This code gets copied from ROM offset 0x0068 to RAM at 0x7000
; From here on, all addresses are runtime addresses (0x7000+)

;------------------------------------------------------------------------
; Interrupt vectors and error handlers
;------------------------------------------------------------------------

	DB	0FFH			;0xFF marker byte

; Error message display vectors
ERRVEC1:
	LD	BC,07800H		;Display buffer
	LD	DE,ERMES1		;Error message 1
	LD	HL,0014H		;Length
	CALL	MOVCPY			;Copy to screen
	JP	ERRDSP			;Display error

ERRVEC2:
	LD	BC,07800H
	LD	DE,ERMES3
	LD	HL,000FH
	CALL	MOVCPY
	JP	ERRDSP

ERRVEC3:
	LD	BC,07800H
	LD	DE,ERMES2
	LD	HL,001DH
	CALL	MOVCPY
	JP	ERRDSP

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

; Memory compare/copy routines
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

MOVCPY:				;Copy routine
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

ERMES1:
	DB	' RC700 RC702 **NO SYSTEM FILES**  '

ERMES2:
	DB	'**NO DISKETTE NOR LINEPROG**  '

ERMES3:
	DB	'**NO KATALOG** '

NULLB:	DB	002H			;Control byte

	JP	073C8H			;Jump table entry

FNAME1:	DB	'SYSM '			;System file name
FNAME2:	DB	'SYSC '

	JP	07362H			;Jump table entry

;------------------------------------------------------------------------
; INITIALIZATION ENTRY POINT at 070D0H
; Hardware and display initialization
;------------------------------------------------------------------------

INIT:
	LD	SP,0BFFFH		;Reset stack
	LD	A,073H			;Interrupt vector high byte
	LD	I,A			;Set interrupt vector register
	IM	2			;Interrupt mode 2

; Initialize PIO for keyboard
	LD	C,0FFH
	LD	B,001H
	CALL	SUB_B1			;Wait routine

	LD	A,099H
	CALL	SUB_E9			;PIO init
	LD	HL,0007000H		;Entry point??
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
	LD	A,087H
	OUT	(012H),A		;Enable interrupts
	LD	A,083H
	OUT	(012H),A
	OUT	(013H),A
	JP	07103H

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
	JP	0712FH

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
	JP	07146H

; CRT Controller (8275) initialization
CRTINIT:
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
	JP	0716EH

;------------------------------------------------------------------------
; Floppy disk controller (uPD765) initialization and status check
;------------------------------------------------------------------------

FDCINT:
	INC	BC
	INC	BC
	LD	C,04FH
	JR	NZ,$+2

	LD	C,0FFH
	LD	B,001H
	CALL	SUB_B1

	IN	A,(004H)		;FDC status
	AND	01FH
	JP	NZ,0716EH

	LD	HL,0716AH
	LD	B,(HL)
	INC	HL
	IN	A,(004H)
	AND	0C0H
	CP	080H
	JP	NZ,07181H

	LD	A,(HL)
	OUT	(005H),A		;FDC data
	DEC	B
	JP	NZ,07180H
	JP	07194H

;------------------------------------------------------------------------
; Display screen clear and message display
;------------------------------------------------------------------------

CLRSCR:
	LD	HL,00000H
	EX	DE,HL
	LD	HL,07800H		;Display buffer
	ADD	HL,DE

	LD	A,020H			;Space character
	LD	(HL),A
	LD	E,L
	CP	0CFH
	JP	Z,071A9H
	INC	DE
	JP	07198H

NEXTLN:
	LD	A,D
	CP	007H
	JP	Z,071B3H
	INC	DE
	JP	07198H

DISPMG:
	LD	DE,07071H		;Message pointer
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
	LD	(08032H),A
	INC	A
	LD	(08033H),A
	LD	(08034H),A

; Try hard disk boot
	CALL	HDBOTT
	JP	C,FLDSK1

	LD	HL,07320H		;Status flag
	LD	A,002H
	OR	(HL)
	LD	(HL),A

	LD	HL,08033H
	DEC	(HL)
	CALL	HDBOTT
	RET	NC

	LD	A,0FBH
	JP	ERRDSP

;------------------------------------------------------------------------
; Floppy disk boot sequence
;------------------------------------------------------------------------

FLDSK1:
	LD	B,001H
	LD	C,0FFH
	CALL	SUB_B1
	CALL	FLPRST
	LD	A,(08010H)
	AND	023H
	LD	C,A
	LD	A,(0801BH)
	ADD	A,020H
	CP	C
	JP	NZ,ERRDSP
	CALL	FLDSK2
	JP	C,ERRDSP
	JP	Z,FLDSK3
	JP	ERRDSP

FLDSK3:
	CALL	CLRSCR
	LD	A,001H
	OUT	(018H),A
	LD	HL,(08067H)
	CALL	BOOT2
	LD	A,(08032H)
	OR	A
	JP	NZ,BOOT3
	CALL	HDBOTT
	JP	BOOT4

BOOT3:
	LD	A,001H
	LD	(08060H),A
	CALL	BOOT5
	JP	BOOT6

;------------------------------------------------------------------------
; Additional boot helper routines
;------------------------------------------------------------------------

BOOT7:
	LD	A,00AH
	LD	HL,00000H
	CALL	CHKFIL
	JP	Z,BOOT8
	LD	A,00BH
	CALL	CHKFIL
	JP	Z,BOOT8
	JP	ERRVEC1

BOOT9:
	LD	HL,(00000H)
	JP	(HL)

BOOT10:
	LD	HL,00000H
	LD	DE,00B60H
	ADD	HL,DE
	LD	DE,00020H
	ADD	HL,DE
	LD	BC,00D00H
BOOTLP:
	LD	A,B
	CP	H
	JP	C,ERRVEC1
	LD	A,(HL)
	OR	A
	JP	Z,BOOTOK
	CALL	SUB_2E
	JP	NZ,ERRVEC1
	LD	DE,00020H
	ADD	HL,DE
	LD	A,(HL)
	OR	A
	JP	Z,ERRVEC1
	CALL	SUB_3E
	JP	NZ,ERRVEC1
	RET

BOOTOK:
	LD	DE,00002H
	ADD	HL,DE
	EX	DE,HL
	LD	BC,07071H
	LD	HL,0006H
	CP	00AH
	JP	Z,BOOTX1
	LD	BC,07077H
	LD	HL,0006H
	CALL	SUB_5C
	RET

BOOTX1:
	LD	A,00BH
	LD	HL,02000H
	CALL	CHKFIL
	JP	Z,BOOTX2
	JP	ERRVEC2

BOOTX2:
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

INTVEC:
	DW	073C6H,073C6H,073C6H,073C6H,073C6H,073C6H,073BBH,073C2H
	DW	073C6H,073C6H,073C6H,073C6H,073C6H,073C6H,073C6H,073C6H
	DW	0000H

;------------------------------------------------------------------------
; System call handlers
;------------------------------------------------------------------------

SYSCALL:
	LD	(08065H),HL
	LD	HL,00000H
	ADD	HL,SP
	LD	(0801EH),HL
	PUSH	BC
	EX	DE,HL
	LD	A,C
	AND	07FH
	LD	(08034H),A
	LD	A,B
	AND	07FH
	LD	(08032H),A
	CALL	Z,HDBOTT
	LD	A,B
	AND	080H
	JP	Z,SYSC1
	LD	A,001H
	LD	(08033H),A
	CALL	BOOT2
	POP	BC
	PUSH	AF
	LD	A,B
	AND	07FH
	JP	NZ,SYSC2
	LD	A,001H
	LD	(08032H),A
	CALL	HDBOTT
	POP	AF
	XOR	A
	LD	HL,(0801EH)
	LD	SP,HL
	RET

SYSC1:
	LD	A,001H

SYSC2:
	PUSH	AF

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
; CRT vertical retrace interrupt handler
;------------------------------------------------------------------------

CRTINT:
	DI
	CALL	DISINT
	EI
	RETI

;------------------------------------------------------------------------
; Floppy interrupt handler
;------------------------------------------------------------------------

FLPINT:
	DI
	JP	FLPHAND

;------------------------------------------------------------------------
; Dummy interrupt handler
;------------------------------------------------------------------------

DUMINT:
	EI
	RETI
	LD	(08003H),A
	EI
	LD	A,(08060H)
	AND	001H
	JP	NZ,DUMI1
	OUT	(01CH),A
	CALL	DUMI2
	OR	A
	JP	ERRDSP

DUMI1:
	LD	BC,07800H
	LD	DE,ERMES4
	LD	HL,0012H
DUMI3:
	LD	A,(DE)
	LD	(BC),A
	INC	BC
	INC	DE
	DEC	L
	JP	NZ,DUMI3
	RET

ERMES4:
	DB	'**DISKETTE ERROR** '

DUMI2:
	LD	A,(07320H)
	AND	080H
	LD	HL,08060H
	OR	(HL)
	LD	(HL),A
	DEC	(HL)
	CALL	HDBOTT
	LD	HL,00000H
	LD	(08065H),HL
	LD	HL,07300H
	CALL	BOOT2
	LD	A,001H
	LD	(08060H),A
	JP	01000H

;------------------------------------------------------------------------
; Disk I/O routines
;------------------------------------------------------------------------

DISKIO:
	LD	A,000H
	LD	(08069H),HL
	CALL	DISKRD
	JP	C,ERRDSP
	JP	Z,DISKIO1
	LD	A,006H
	JP	DISKIO2

DISKIO1:
	CALL	DISKIO3
	LD	A,006H
	LD	C,005H
	CALL	DISKIO4
	JP	NC,DISKIO5
	LD	A,028H
	JP	DISKIO2

DISKIO2:
	LD	HL,(08067H)
	EX	DE,HL
	LD	HL,(08065H)
	ADD	HL,DE
	LD	(08065H),HL
	LD	L,000H
	LD	H,L
	LD	(08067H),HL
	CALL	DISKIO6
	LD	A,(08061H)
	OR	A
	RET	Z
	JP	DISKIO7

DISKIO3:
	LD	A,001H
	LD	(08034H),A
	LD	A,(07320H)
	AND	002H
	RRCA
	LD	HL,08033H
	CP	(HL)
	JP	Z,DISKIO8
	INC	(HL)
	RET

DISKIO4:
	XOR	A
	LD	(HL),A
	LD	HL,08032H
	INC	(HL)
	RET

DISKIO5:
	LD	HL,(08069H)
	PUSH	HL
	CALL	DISKIO9
	CALL	DISKIO10
	POP	DE
	ADD	HL,DE
	JP	NC,DISKIO11
	LD	A,H
	OR	L
	JP	Z,DISKIO11
	LD	A,001H
	LD	(08061H),A
	LD	(08069H),HL
	RET

DISKIO6:
	LD	A,000H
	LD	(08061H),A
	LD	(08069H),A
	LD	(0806AH),A
	EX	DE,HL
	LD	(08067H),HL
	RET

DISKIO7:
	PUSH	AF
	LD	A,L
	CPL
	LD	L,A
	LD	A,H
	CPL
	LD	H,A
	INC	HL
	POP	AF
	RET

DISKIO8:
	LD	A,(07320H)
	AND	01CH
	RRA
	RRA
	AND	007H
	LD	(08035H),A
	CALL	DISKIO12
	CALL	DISKIO9
	RET

DISKIO9:
	LD	A,(07320H)
	AND	0FEH
	LD	(07320H),A
	CALL	DISKRD
	JP	NZ,DISKIO13
	LD	L,004H
	LD	H,000H
	LD	(08067H),HL
	LD	A,00AH
	LD	C,001H
	CALL	DISKIO4
	LD	HL,07320H
	JP	NC,DISKIO14
	LD	A,(HL)
	AND	001H
	JP	NZ,DISKIO13
	INC	(HL)
	JP	DISKIO15

DISKIO10:
	LD	A,(08016H)
	RLCA
	RLCA
	LD	B,A
	LD	A,(HL)
	AND	0E3H
	ADD	A,B
	LD	(HL),A
	CALL	DISKIO16
	SCF
	CCF
	RET

DISKIO11:
	SCF
	RET

DISKIO12:
	LD	A,(08035H)
	RLA
	RLA
	LD	E,A
	LD	D,000H
	LD	HL,MINIFMT
	LD	A,(07320H)
	AND	080H
	LD	A,04CH
	JP	Z,DISKIO17
	LD	A,023H
	LD	HL,MINIFMT+16
	LD	(0800CH),A
	ADD	HL,DE
	LD	A,(07320H)
	AND	001H
	JP	Z,DISKIO18
	LD	E,002H
	LD	D,000H
	ADD	HL,DE
	EX	DE,HL
	LD	HL,08036H
	LD	A,(DE)
	LD	(HL),A
	LD	(0800DH),A
	INC	HL
	INC	DE
	LD	A,(DE)
	LD	(HL),A
	INC	HL
	LD	A,080H
	LD	(HL),A
	RET

DISKIO13:
	LD	HL,00080H
	LD	A,(08035H)
	OR	A
	JP	Z,DISKIO19
	ADD	HL,HL
	DEC	A
	JP	NZ,DISKIO20
	LD	(08039H),HL
	EX	DE,HL
	LD	A,(08034H)
	LD	L,A
	LD	A,(08036H)
	SUB	L
	INC	A
	LD	L,A
	LD	A,(08060H)
	AND	080H
	JP	Z,DISKIO21
	LD	A,(08033H)
	XOR	001H
	JP	NZ,DISKIO21
	LD	L,00AH
	LD	A,L
	LD	L,000H
	LD	H,L
	ADD	HL,DE
	DEC	A
	JP	NZ,DISKIO22
	LD	(08067H),HL
	RET

DISKIO14:
	PUSH	AF

DISKIO15:
	LD	A,C

DISKIO16:
	LD	(08062H),A

DISKIO17:
	CALL	DISKIO23

DISKIO18:
	LD	HL,(08067H)

DISKIO19:
	LD	B,H

DISKIO20:
	LD	C,L

DISKIO21:
	DEC	BC

DISKIO22:
	LD	HL,(08065H)

DISKIO23:
	POP	AF
	PUSH	AF
	AND	00FH
	CP	00AH
	CALL	NZ,DISKIO24
	POP	AF
	LD	C,A
	CALL	DISKIO25
	LD	A,0FFH
	CALL	DISKIO26
	RET	C
	LD	A,C
	CALL	DISKIO27
	RET	NC
	RET	Z
	LD	A,C
	PUSH	AF
	JP	DISKIO28

DISKIO24:
	LD	HL,08010H
	LD	A,(HL)
	AND	0C3H
	LD	B,A
	LD	A,(0801BH)
	CP	B
	JP	NZ,DISKIO29
	INC	HL
	LD	A,(HL)
	CP	000H
	JP	NZ,DISKIO29
	INC	HL
	LD	A,(HL)
	AND	0BFH
	CP	000H
	JP	NZ,DISKIO29
	SCF
	CCF
	RET

DISKIO25:
	LD	A,(08062H)
	DEC	A
	LD	(08062H),A
	SCF
	RET

DISKIO26:
	PUSH	BC
	PUSH	AF
	DI
	LD	A,0FFH
	LD	HL,08030H
	LD	(0800BH),A
	LD	A,(07320H)
	AND	001H
	JP	Z,DISKIO30
	LD	A,040H
	LD	B,A
	POP	AF
	PUSH	AF
	ADD	A,B
	LD	(HL),A
	INC	HL
	CALL	SUB_B1
	LD	(HL),A
	DEC	HL
	POP	AF
	AND	00FH
	CP	006H
	LD	C,009H
	JP	Z,DISKIO31
	LD	C,002H
	LD	A,(HL)
	INC	HL
	CALL	FDCOUT
	DEC	C
	JP	NZ,DISKIO31
	POP	BC
	EI
	RET

DISKIO27:
	LD	A,005H
	DI
	OUT	(0FAH),A
	LD	A,049H
	OUT	(0FBH),A
	OUT	(0FCH),A
	LD	A,L
	OUT	(0F2H),A
	LD	A,H
	OUT	(0F2H),A
	LD	A,C
	OUT	(0F3H),A
	LD	A,B
	OUT	(0F3H),A
	LD	A,001H
	OUT	(0FAH),A
	EI
	RET

DISKIO28:
	LD	A,005H
	DI
	OUT	(0FAH),A
	LD	A,045H
	JP	DISKIO32

DISKIO29:
	PUSH	AF
	PUSH	BC
	LD	B,000H
	LD	C,000H
	INC	B
	CALL	Z,FDCWAIT
	IN	A,(004H)
	AND	0C0H
	CP	080H
	JP	NZ,DISKIO33
	POP	BC
	POP	AF
	OUT	(005H),A
	RET

DISKIO30:
	PUSH	BC
	LD	B,000H
	LD	C,000H
	INC	B
	CALL	Z,FDCWAIT
	IN	A,(004H)
	AND	0C0H
	CP	0C0H
	JP	NZ,DISKIO34
	POP	BC
	IN	A,(005H)
	RET

DISKIO31:
	LD	B,000H
	INC	C
	RET	NZ
	EI
	JP	ERRDSP

DISKIO32:
	LD	A,004H
	CALL	FDCOUT
	LD	A,(0801BH)
	CALL	FDCOUT
	CALL	FDCIN
	LD	(08010H),A
	RET

DISKIO33:
	LD	A,008H
	CALL	FDCOUT
	CALL	FDCIN
	LD	(08010H),A
	AND	0C0H
	CP	080H
	JP	Z,DISKIO35
	CALL	FDCIN
	LD	(08011H),A
	RET

DISKIO34:
	DI
	XOR	A
	LD	(08041H),A
	EI
	RET

; Additional helper routines
SUB_B1:
	PUSH	DE
	LD	A,(08033H)
	RLA
	RLA
	LD	D,A
	LD	A,(0801BH)
	ADD	A,D
	POP	DE
	RET

SUB_E9:
	PUSH	AF
	PUSH	HL
	LD	H,C
	LD	L,0FFH
WAITLP:
	DEC	HL
	LD	A,L
	OR	H
	JP	NZ,WAITLP
	DEC	B
	JP	NZ,WAITLP-3
	POP	HL
	POP	AF
	RET

FDCWAIT:
	PUSH	BC
	DEC	A
	SCF
	JP	Z,FDCRET
	LD	B,001H
	LD	C,001H
	CALL	SUB_B1
	LD	B,A
	LD	A,(08041H)
	AND	002H
	LD	A,B
	JP	Z,FDCOK
	SCF
	CCF
	CALL	FLPRST-3
	POP	BC
	RET

FDCOK:
	LD	A,0FFH
	CALL	FDCWT2
	LD	A,(08010H)
	LD	B,A
	LD	A,(08011H)
	LD	C,A
	RET

FDCRET:
	LD	A,007H
	CALL	FDCOUT
	LD	A,(0801BH)
	CALL	FDCOUT
	RET

FDCOUT:
	LD	A,00FH
	CALL	FDCOUT-3
	LD	A,D
	AND	007H
	CALL	FDCOUT-3
	LD	A,E
	CALL	FDCOUT-3
	RET

FDCIN:
	CALL	FLPRST
	CALL	FLPRST-14
	RET	C
	LD	A,(0801BH)
	ADD	A,020H
	CP	B
	JP	NZ,FDCIN-21
	LD	A,C
	CP	000H
	SCF
	CCF
	RET

FLPRST:
	LD	A,(08032H)
	LD	E,A
	CALL	SUB_B1
	LD	D,A
	CALL	FLPRST+9
	CALL	FLPRST-14
	RET	C
	LD	A,(0801BH)
	ADD	A,020H
	CP	B
	JP	NZ,FLPRST-12
	LD	A,(08032H)
	CP	C
	SCF
	CCF
	RET

FLPRST+9:
	LD	HL,08010H
	LD	B,007H
	LD	A,B
	LD	(0800BH),A
	CALL	FDCIN-3
	LD	(HL),A
	INC	HL
	LD	A,(0801DH)
	DEC	A
	JP	NZ,FLPRST+18
	IN	A,(004H)
	AND	010H
	JP	Z,FLPRST+38
	DEC	B
	JP	NZ,FLPRST+9
	LD	A,0FEH
	JP	DISKIO2

FLPRST+38:
	IN	A,(0F8H)
	LD	(HL),A
	DEC	B
	RET	Z
	EI
	LD	A,0FDH
	JP	DISKIO2

;------------------------------------------------------------------------
; Floppy interrupt service routine
;------------------------------------------------------------------------

FLPHAND:
	PUSH	AF
	PUSH	BC
	PUSH	HL
	LD	A,002H
	LD	(08041H),A
	LD	A,(0801CH)
	DEC	A
	JP	NZ,FLPHAN1
	IN	A,(004H)
	AND	010H
	JP	NZ,FLPHAN2
	CALL	FLPHAN3
	JP	FLPHAN4

FLPHAN1:
	CALL	FLPHAN5

FLPHAN2:
	POP	HL

FLPHAN3:
	POP	BC

FLPHAN4:
	POP	AF

FLPHAN5:
	EI
	RETI

;------------------------------------------------------------------------
; File lookup and utility routines
;------------------------------------------------------------------------

CHKFIL:
	PUSH	BC
	PUSH	AF
	DI
	LD	A,0FFH
	LD	HL,08030H
	LD	(0800BH),A
	LD	A,(07320H)
	AND	001H
	JP	Z,CHKFIL1
	LD	A,040H
	LD	B,A
	POP	AF
	PUSH	AF
	ADD	A,B
	LD	(HL),A
	INC	HL
	CALL	SUB_B1
	LD	(HL),A
	DEC	HL
	POP	AF
	AND	00FH
	CP	006H
	LD	C,009H
	JP	Z,CHKFIL2
	LD	C,002H
	LD	A,(HL)
	INC	HL
	CALL	FDCOUT
	DEC	C
	JP	NZ,CHKFIL2
	POP	BC
	EI
	RET

CHKFIL1:
	LD	A,005H
	DI
	OUT	(0FAH),A
	LD	A,049H
	OUT	(0FBH),A
	OUT	(0FCH),A
	LD	A,L
	OUT	(0F2H),A
	LD	A,H
	OUT	(0F2H),A
	LD	A,C
	OUT	(0F3H),A
	LD	A,B
	OUT	(0F3H),A
	LD	A,001H
	OUT	(0FAH),A
	EI
	RET

CHKFIL2:
	LD	A,005H
	DI
	OUT	(0FAH),A
	LD	A,045H
	OUT	(0FBH),A
	OUT	(0FCH),A
	LD	A,L
	OUT	(0F2H),A
	LD	A,H
	OUT	(0F2H),A
	LD	A,C
	OUT	(0F3H),A
	LD	A,B
	OUT	(0F3H),A
	LD	A,001H
	OUT	(0FAH),A
	EI
	RET

;------------------------------------------------------------------------
; Disk read routine wrappers
;------------------------------------------------------------------------

DISKRD:
	PUSH	AF
	PUSH	BC
	LD	B,000H
	LD	C,000H
	INC	B
	CALL	Z,FDCWAIT
	IN	A,(004H)
	AND	0C0H
	CP	080H
	JP	NZ,DISKRD1
	POP	BC
	POP	AF
	OUT	(005H),A
	RET

DISKRD1:
	PUSH	BC
	LD	B,000H
	LD	C,000H
	INC	B
	CALL	Z,FDCWAIT
	IN	A,(004H)
	AND	0C0H
	CP	0C0H
	JP	NZ,DISKRD2
	POP	BC
	IN	A,(005H)
	RET

DISKRD2:
	LD	B,000H
	INC	C
	RET	NZ
	EI
	JP	ERRDSP

;------------------------------------------------------------------------
; Hard disk boot attempt (stub - returns carry set)
;------------------------------------------------------------------------

HDBOTT:
	SCF				;Set carry = no HD
	RET

;------------------------------------------------------------------------
; Additional boot helpers
;------------------------------------------------------------------------

BOOT2:
	LD	A,(08032H)
	OR	A
	RET	NZ
	LD	A,001H
	RET

BOOT4:
	LD	A,(08033H)
	OR	A
	RET	Z
	LD	A,001H
	RET

BOOT5:
	LD	A,(08034H)
	OR	A
	RET	Z
	LD	A,001H
	RET

BOOT6:
	LD	A,(08035H)
	OR	A
	RET	Z
	LD	A,001H
	RET

BOOT8:
	LD	A,(08036H)
	OR	A
	RET	Z
	LD	A,001H
	RET

;------------------------------------------------------------------------
; Error display routine
;------------------------------------------------------------------------

ERRDSP:
	PUSH	AF
	CALL	CLRSCR
	POP	AF
	HALT
	JP	ERRDSP

; Fill to end of block
	DB	00H,00H

	dephase
	END
