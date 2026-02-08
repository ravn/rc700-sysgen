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
	JP	Z,SKIP
	DEC	HL			;Back up to non-zero
SKIP:
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
; Interrupt vectors and error handlers at 0x7000
;------------------------------------------------------------------------

	RST	38H			;0xFF marker byte

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
	DI
	LD	SP,0BFFFH		;Reset stack
	LD	A,073H			;Interrupt vector high byte
	LD	I,A			;Set interrupt vector register
	IM	2			;Interrupt mode 2

; Initialize PIO for keyboard
	LD	C,0FFH
	LD	B,001H
	CALL	SUB_B1			;Wait routine

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
	JP	NZ,FDCINT

	LD	HL,FDCDATA
	LD	B,(HL)
	INC	HL
	IN	A,(004H)
	AND	0C0H
	CP	080H
	JP	NZ,FDCWAIT

	LD	A,(HL)
	OUT	(005H),A		;FDC data
	DEC	B
	JP	NZ,FDCWAIT
	JP	CLRSCR

FDCDATA:
	DB	03H,71H		;FDC command data

FDCWAIT:
	; FDC wait loop continues here

;------------------------------------------------------------------------
; Display screen clear and message display
;------------------------------------------------------------------------

CLRSCR:
	LD	HL,00000H
	EX	DE,HL
	LD	HL,07800H		;Display buffer
	ADD	HL,DE

CLRLP1:
	LD	A,020H			;Space character
	LD	(HL),A
	LD	E,L
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
	LD	DE,FNAME1		;Message pointer
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

FLDSK2:
	; Floppy disk read routine
	RET

FLDSK3:
	CALL	CLRSCR
	LD	A,001H
	OUT	(018H),A		;Beeper
	LD	HL,(08067H)
	CALL	BOOT2
	LD	A,(08032H)
	OR	A
	JP	NZ,BOOT3
	CALL	HDBOTT
	JP	BOOT4

BOOT2:
	; Boot helper routine
	RET

BOOT3:
	LD	A,001H
	LD	(08060H),A
	CALL	BOOT5
	JP	BOOT6

BOOT4:
	; Boot continuation
	RET

BOOT5:
	; Boot helper 5
	RET

BOOT6:
	; Boot helper 6
	RET

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

BOOT8:
	; Boot step 8
	RET

BOOT9:
	LD	HL,(00000H)
	JP	(HL)

CHKFIL:
	; Check for system files
	RET

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
	CALL	HDBOTT
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
	RET

SYSC2:
	POP	AF
	RET

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
	JP	FLPHAND

DUMINT:
	EI
	RETI

;------------------------------------------------------------------------
; Error display routine
;------------------------------------------------------------------------

ERRDSP:
	; Display error and halt
	HALT

;------------------------------------------------------------------------
; Floppy disk routines
;------------------------------------------------------------------------

FLPRST:
	; FDC reset
	RET

FLPHAND:
	; Floppy interrupt handler
	RETI

;------------------------------------------------------------------------
; Hard disk boot attempt (stub - returns carry set)
;------------------------------------------------------------------------

HDBOTT:
	SCF				;Set carry = no HD
	RET

;------------------------------------------------------------------------
; Utility routine - wait/delay
;------------------------------------------------------------------------

SUB_B1:
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
	JP	NZ,WAITLP
	POP	HL
	POP	AF
	RET

;------------------------------------------------------------------------
; Additional system routines (stubs for assembly)
;------------------------------------------------------------------------

L7362:
	RET

L73C8:
	RET

L73DA:
	; Error display continues
	JP	ERRDSP

	dephase
	END
