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
; HARDWARE CONSTANT DEFINITIONS
; (cf. rob358.mac for RC700/RC703 equivalents)
;========================================================================

; System ports
SW1	EQU	014H		;Mini/maxi switch (read), ROM disable (write)
BIB	EQU	01CH		;Beeper/sound port
BEEPER	EQU	018H		;RC702 beeper port (additional)

; Z80 PIO ports
KEYDAT	EQU	010H		;PIO Port A data (keyboard)
KEYCON	EQU	012H		;PIO Port A control
PIOBDT	EQU	011H		;PIO Port B data
PIOBCN	EQU	013H		;PIO Port B control

; AM9517A DMA controller ports
CH1ADR	EQU	0F2H		;DMA Channel 1 address (floppy)
WCREG1	EQU	0F3H		;DMA Channel 1 word count
CH2ADR	EQU	0F4H		;DMA Channel 2 address (display)
WCREG2	EQU	0F5H		;DMA Channel 2 word count
CH3ADR	EQU	0F6H		;DMA Channel 3 address (display)
WCREG3	EQU	0F7H		;DMA Channel 3 word count
DMACOM	EQU	0F8H		;DMA command register
SMSK	EQU	0FAH		;DMA single mask register
DMAMOD	EQU	0FBH		;DMA mode register
CLBP	EQU	0FCH		;DMA clear byte pointer

; DMA command/mode values
COMV	EQU	020H		;DMA command value
MODE1	EQU	045H		;DMA mode: disk to memory CH1 (single)
CLR1	EQU	001H		;Clear CH1 mask (enable)
SET1	EQU	005H		;Set CH1 mask (disable)

; Z80 CTC ports
CTCCH0	EQU	00CH		;CTC Channel 0
CTCCH1	EQU	00DH		;CTC Channel 1
CTCCH2	EQU	00EH		;CTC Channel 2 (display interrupt)
CTCCH3	EQU	00FH		;CTC Channel 3 (floppy interrupt)
CTCMOD	EQU	0D7H		;CTC mode: interrupt after one count
CTCCNT	EQU	001H		;CTC count value

; Intel 8275 CRT controller ports
CRTDAT	EQU	000H		;CRT data register
CRTCOM	EQU	001H		;CRT command/control register

; CRT command values
CRTRES	EQU	000H		;Reset CRT controller
LCURS	EQU	080H		;Load cursor command
PRECC	EQU	0E0H		;Preset counters
STDISP	EQU	023H		;Start display

; CRT parameters (RC702-specific)
PARAM1	EQU	04FH		;80 chars/row
PARAM2	EQU	098H		;25 rows/frame

; NEC uPD765 FDC ports
FDC	EQU	004H		;FDC main status register
FDD	EQU	005H		;FDC data register

; Display buffer
DSPSTR	EQU	07800H		;Display memory buffer address

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
	LD	(FDCTMO),A
	INC	A
	LD	(FDCWAI),A
	LD	(FLPWAI),A

	LD	A,000H
	LD	B,A
	IN	A,(SW1)		;Read switch settings
	AND	080H			;Mask mini/maxi bit
	ADD	A,B
	LD	(L07320H),A

	XOR	A			;Clear A
	LD	(CURHED),A
	LD	(DRVSEL),A
	LD	(DSKTYP),A
	LD	(MOREFL),A
	LD	(FLPFLG),A

	LD	C,008H
	LD	HL,CLRBLK
CLRLP:
	LD	(HL),A
	INC	HL
	DEC	C
	JP	NZ,CLRLP

	EI				;Enable interrupts
	LD	A,001H
	OUT	(SW1),A		;ROM disable port
	LD	A,005H
	LD	(REPTIM),A
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
	CALL	COMSTR
	POP	HL
	JP	Z,SUB_4F
	RET

SUB_3E:
	PUSH	HL
	INC	HL
	EX	DE,HL
	LD	BC,070C8H
	LD	HL,0004H
	CALL	COMSTR
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
COMSTR:
	LD	A,(DE)
	LD	H,A
	LD	A,(BC)
	CP	H
	RET	NZ
	INC	DE
	INC	BC
	DEC	L
	JP	NZ,COMSTR
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
	OUT	(KEYCON),A		;PIO control
	LD	A,004H
	OUT	(PIOBCN),A
	LD	A,04FH
	OUT	(KEYCON),A		;Set mode
	LD	A,00FH
	OUT	(PIOBCN),A
	LD	A,083H
	OUT	(KEYCON),A		;Enable interrupts
	OUT	(PIOBCN),A
	JP	CTCINT

; CTC initialization
CTCINT:
	LD	A,008H
	OUT	(CTCCH0),A		;CTC control
	POP	AF
	LD	A,046H
	OR	041H
	OUT	(CTCCH0),A		;Channel 0
	LD	A,020H
	OUT	(CTCCH0),A

	LD	A,046H
	OR	041H
	OUT	(CTCCH1),A		;Channel 1
	LD	A,020H
	OUT	(CTCCH1),A

	LD	A,0D7H
	OUT	(CTCCH2),A		;Channel 2 (Display)
	LD	A,001H
	OUT	(CTCCH2),A

	LD	A,0D7H
	OUT	(CTCCH3),A		;Channel 3 (Floppy)
	LD	A,001H
	OUT	(CTCCH3),A
	JP	DMAINT

; DMA initialization
DMAINT:
	LD	A,020H
	OUT	(DMACOM),A		;DMA command

	LD	A,0C0H
	OUT	(DMAMOD),A		;Mode register
	LD	A,000H
	OUT	(SMSK),A		;Mask register

	LD	A,04AH
	OUT	(DMAMOD),A
	LD	A,04BH
	OUT	(DMAMOD),A
	JP	CRTINT

; CRT Controller (8275) initialization
CRTINT:
	LD	A,000H
	OUT	(CRTCOM),A		;Reset CRT

	LD	A,04FH
	OUT	(CRTDAT),A		;80 chars/row
	LD	A,098H
	OUT	(CRTDAT),A		;25 rows
	LD	A,09AH
	OUT	(CRTDAT),A		;Underline
	LD	A,05DH
	OUT	(CRTDAT),A		;Cursor format

	LD	A,080H
	OUT	(CRTCOM),A		;Load cursor
	XOR	A
	OUT	(CRTDAT),A		;Position 0
	OUT	(CRTDAT),A

	LD	A,0E0H
	OUT	(CRTCOM),A		;Preset counters
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

	IN	A,(FDC)		;FDC status
	AND	01FH
	JP	NZ,FDCINT

	LD	HL,FDCDATA
	LD	B,(HL)
FDCWAITNEXT:
	INC	HL
FDCWAIT:
	IN	A,(FDC)
	AND	0C0H
	CP	080H
	JP	NZ,FDCWAIT

	LD	A,(HL)
	OUT	(FDD),A		;FDC data
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
	OUT	(CRTCOM),A		;Start display
	RET

;------------------------------------------------------------------------
; MAIN BOOT SEQUENCE - Try hard disk, then floppy
;------------------------------------------------------------------------

BOOT:
	XOR	A
	LD	(CURCYL),A
	INC	A
	LD	(CURHED),A
	LD	(CURREC),A

; Try hard disk boot
	CALL	074CBH ; --FIXME HDBOTT
	JP	C,L720B

	LD	HL,07320H		;Status flag
	LD	A,002H
	OR	(HL)
	LD	(HL),A

L720B:
	LD	HL,CURHED
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
	LD	A,(FDCRES)
	AND	023H
	LD	C,A
	LD	A,(DRVSEL)
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
	OUT	(BEEPER),A		;Beeper
BOOT4:
	LD	HL,(TRBYT)
	CALL	07425H ; -- BOOT2
	LD	A,(CURCYL)
	OR	A
	JP	NZ,BOOT2
	CALL	074CBH ; -- FIXME HDBOTT
	JP	BOOT4

BOOT2:
	; Boot helper routine
;	RET

BOOT3:
	LD	A,001H
	LD	(DSKTYP),A
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
	CALL	COMSTR
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

INTVEC:
	DW	DUMINT		; +0:  Dummy
	DW	DUMINT		; +2:  PIO Port A (keyboard) - not used on RC702
	DW	DUMINT		; +4:  PIO Port B - not used
	DW	DUMINT		; +6:  Dummy
	DW	DUMINT		; +8:  CTC CH0 - not used
	DW	DUMINT		; +10: CTC CH1 - not used
	DW	HDINT		; +12: CTC CH2 - Display interrupt
	DW	FLPINT		; +14: CTC CH3 - Floppy interrupt
	DW	DUMINT		; +16: Dummy
	DW	DUMINT		; +18: Dummy
	DW	DUMINT		; +20: Dummy
	DW	DUMINT		; +22: Dummy
	DW	DUMINT		; +24: Dummy
	DW	DUMINT		; +26: Dummy
	DW	DUMINT		; +28: Dummy
	DW	DUMINT		; +30: Dummy
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
	LD	(MEMADR),HL
	LD	HL,00000H
	ADD	HL,SP
	LD	(SPSAV),HL
	PUSH	BC
	EX	DE,HL
	LD	A,C
	AND	07FH
	LD	(CURREC),A
	LD	A,B
	AND	07FH
	LD	(CURCYL),A
	CALL	Z, 074CBH ; -- FIXME
	LD	A,B
	AND	080H
	JP	Z,L7345
	LD	A,001H
L7345:
	LD	(CURHED),A
	CALL	07425H ; -- FIXME
	POP	BC
	PUSH	AF
	LD	A,B
	AND	07FH
	JP	NZ,0735bH ; -- FIXME
	LD	A,001H
	LD	(CURCYL),A
	CALL	074CBH ; -- FIXME
	POP	AF
	XOR	A
	LD	HL,(SPSAV)
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
	OUT	(SMSK), A
	LD	A,7
	OUT	(SMSK), A

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
	IN	A,(CRTCOM)
	PUSH	HL
	PUSH	DE
	PUSH	BC
	LD	A,006H
	OUT	(SMSK),A
	LD	A,007H
	OUT	(SMSK),A
	OUT	(CLBP),A
	LD	HL,(07FD5H)
	LD	DE,07800H
	ADD	HL,DE
	LD	A,L
	OUT	(CH2ADR),A
	LD	A,H
	OUT	(CH2ADR),A
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
	OUT	(WCREG2),A
	LD	A,H
	OUT	(WCREG2),A
	LD	HL,07800H
	LD	A,L
	OUT	(CH3ADR),A
	LD	A,H
	OUT	(CH3ADR),A
	LD	HL,007CFH
	LD	A,L
	OUT	(WCREG3),A
	LD	A,H
	OUT	(WCREG3),A
	LD	A,002H
	OUT	(SMSK),A
	LD	A,003H
	OUT	(SMSK),A
	POP	BC
	POP	DE
	POP	HL
	LD	A,0D7H
	OUT	(CTCCH2),A
	LD	A,001H
	OUT	(CTCCH2),A
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

;------------------------------------------------------------------------
; Error display procedure (cf. rob358 ERR)
; Entry: A = error code
;------------------------------------------------------------------------

ERRDSP:
	LD	(ERRSAV),A		;Save error code
	EI
	LD	A,(DSKTYP)
	AND	001H
	JP	NZ,0735DH		; -- FIXME (return to caller)
	OUT	(BIB),A			;Sound beeper
	CALL	ERRCPY			;Copy error text to display
ERRHLT:
	OR	A
	JP	ERRHLT			;Halt loop
ERRCPY:
	LD	BC,DSPSTR		;Display buffer address
	LD	DE,ERRTXTPTR
	LD	HL,00012H		;18 characters
ERRCPLP:
	LD	A,(DE)			;Copy error text to display
	LD	(BC),A
	INC	BC
	INC	DE
	DEC	L
	JP	NZ,ERRCPLP
	RET
ERRTXTPTR:

;------------------------------------------------------------------------
; Error message text
;------------------------------------------------------------------------

DISKETTEERRORTXT:
	DEFB	'**DISKETTE ERROR** '

;------------------------------------------------------------------------
; FLOPPY BOOT - main entry point (0x7404)
; Called after hard disk boot fails or is skipped
; (cf. rob358 FLOPPY section)
;------------------------------------------------------------------------

FLBOOT:
	LD	A,(L07320H)		;Get status flags
	AND	080H			;Mask mini/maxi bit
	LD	HL,DSKTYP
	OR	(HL)			;Combine with current type
	LD	(HL),A
	DEC	(HL)
	CALL	DSKAUTO			;Auto-detect disk density
	LD	HL,00000H
	LD	(MEMADR),HL		;Memory pointer := 0
	LD	HL,INTVEC
	CALL	RDTRK0			;Read track 0 side 0
	LD	A,001H
	LD	(DSKTYP),A		;Set floppy boot flag
	JP	01000H			;Jump to ID-COMAL boot address
RDTRK0:
	LD	A,000H
	LD	(TRKOVR),HL		;Clear track overflow
L0742AH:
	CALL	FLSEEK			;Seek to track
	JP	C,L72C4 		;Error: display error
	JP	Z,RDTRK1		;Seek OK: read track
	LD	A,006H			;Error code
	JP	ERRDSP
RDTRK1:
	CALL	CALCTX			;Calculate transfer with overflow
	LD	A,006H			;Read track command
	LD	C,005H			;5 retries
	CALL	READTK			;Read track with retry
	JP	NC,RDTROK		;Read OK
	LD	A,028H			;Error code
	JP	ERRDSP
RDTROK:
	LD	HL,(TRBYT)		;Get transfer byte count
	EX	DE,HL
	LD	HL,(MEMADR)		;Update memory pointer
	ADD	HL,DE
	LD	(MEMADR),HL
	LD	L,000H			;Clear transfer count
	LD	H,L
	LD	(TRBYT),HL
	CALL	NXTHDS			;Advance to next head/side
	LD	A,(MOREFL)		;More data to transfer?
	OR	A
	RET	Z			;No: return
	JP	L0742AH			;Yes: read more (skip LD A,000H)
NXTHDS:
	LD	A,001H			;Advance head/side
	LD	(CURREC),A		;Record := 1
	LD	A,(L07320H)
	AND	002H			;Check dual-sided bit
	RRCA
	LD	HL,CURHED
	CP	(HL)			;Same head?
	JP	Z,NXTCYL		;Yes: advance cylinder
	INC	(HL)			;No: switch to other head
	RET
NXTCYL:
	XOR	A
	LD	(HL),A			;Head := 0
	LD	HL,CURCYL
	INC	(HL)			;Cylinder++
	RET

;------------------------------------------------------------------------
; CALCTX - Calculate track transfer with overflow check
; Sets MOREFL if more data needs to be transferred
;------------------------------------------------------------------------

CALCTX:
	LD	HL,(TRKOVR)		;Get remaining overflow
	PUSH	HL
	CALL	CALCTB			;Calculate transfer byte count
	CALL	NEGHL			;Negate HL
	POP	DE
	ADD	HL,DE			;Overflow - track bytes
	JP	NC,CALCTX2		;No overflow: clear flags
	LD	A,H
	OR	L
	JP	Z,CALCTX2		;Zero: clear flags
	LD	A,001H
	LD	(MOREFL),A		;More data to transfer
	LD	(TRKOVR),HL		;Save remaining overflow
	RET

CALCTX2:
	LD	A,000H
	LD	(MOREFL),A		;No more data
	LD	(TRKOVR),A		;Clear overflow
	LD	(TRKOV2),A
	EX	DE,HL
	LD	(TRBYT),HL		;Set transfer byte count
	RET

;------------------------------------------------------------------------
; NEGHL - Two's complement negate HL
; HL := -HL
;------------------------------------------------------------------------

NEGHL:
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

;------------------------------------------------------------------------
; SETFMT - Set disk format parameters from status flags
; Extracts density info and looks up format tables
;------------------------------------------------------------------------

SETFMT:
	LD	A,(L07320H)		;Get status flags
	AND	01CH			;Extract density bits
	RRA
	RRA
	AND	007H
	LD	(RECLEN),A		;Set record length (N)
	CALL	FMTLKP			;Look up format parameters
	CALL	CALCTB			;Calculate transfer byte count
	RET

;------------------------------------------------------------------------
; DSKAUTO - Auto-detect disk density
; Seeks to track 0, reads ID, determines format
; Returns: CF=1 on error
;------------------------------------------------------------------------

DSKAUTO:
	LD	A,(L07320H)		;Get status flags
	AND	0FEH			;Clear side bit
	LD	(L07320H),A
DSKAUTO1:
	CALL	FLSEEK			;Seek to current cylinder
	JP	NZ,DSKFAIL		;Seek failed: error
	LD	L,004H
	LD	H,000H
	LD	(TRBYT),HL		;Transfer 4 bytes (ID field)
	LD	A,00AH			;Read ID command
	LD	C,001H			;1 retry
	CALL	READTK			;Read track
	LD	HL,L07320H
	JP	NC,DSKDET		;Read OK: detect format
	LD	A,(HL)			;Read failed
	AND	001H			;Already tried other side?
	JP	NZ,DSKFAIL		;Yes: give up
	INC	(HL)			;Try other side
	JP	DSKAUTO1		;Retry seek
DSKDET:
	LD	A,(FDCRS6)		;Get N from FDC result
	RLCA				;Shift to density bits position
	RLCA
	LD	B,A
	LD	A,(HL)			;Get status flags
	AND	0E3H			;Clear old density bits
	ADD	A,B			;Insert new density
	LD	(HL),A
	CALL	SETFMT			;Set format from detected density
	SCF
	CCF				;Clear carry = success
	RET
DSKFAIL:
	SCF				;Set carry = error
	RET

;------------------------------------------------------------------------
; FMTLKP - Format table lookup by density
; Looks up EOT, GAP3, DTL from format tables based on mini/maxi
; and current density setting
;------------------------------------------------------------------------

FMTLKP:
	LD	A,(RECLEN)		;Get record length (N)
	RLA				;Multiply by 4 (table entry size)
	RLA
	LD	E,A
	LD	D,000H
	LD	HL,MINIFMT		;Default: mini format table
	LD	A,(L07320H)
	AND	080H			;Check mini/maxi bit
	LD	A,04CH			;Maxi: EOT = 76
	JP	Z,FMTLK2
	LD	A,023H			;Mini: EOT = 35
	LD	HL,MINIFMT+16		;Point to maxi format table
FMTLK2:
	LD	(EPTS),A		;Store sectors per track
	ADD	HL,DE			;Index into table
	LD	A,(L07320H)
	AND	001H			;Check side bit
	JP	Z,FMTLK3
	LD	E,002H			;Side 1: offset by 2
	LD	D,000H
	ADD	HL,DE
FMTLK3:
	EX	DE,HL
	LD	HL,CUREOT		;Copy EOT and GAP3 from table
	LD	A,(DE)
	LD	(HL),A			;CUREOT = table[0]
	LD	(TRKSZ),A		;Also save as track size
	INC	HL
	INC	DE
	LD	A,(DE)
	LD	(HL),A			;GAP3 = table[1]
	INC	HL
	LD	A,080H
	LD	(HL),A			;DTL = 80H
	RET

;------------------------------------------------------------------------
; CALCTB - Calculate transfer byte count
; Computes total bytes = sector_size * sector_count
; Sets TRBYT with result
;------------------------------------------------------------------------

CALCTB:
	LD	HL,00080H		;Base sector size = 128
	LD	A,(RECLEN)		;Get N (record length code)
	OR	A
	JP	Z,CALCT2		;N=0: 128 bytes/sector
CALCT1:	ADD	HL,HL			;Double for each N level
	DEC	A
	JP	NZ,CALCT1
CALCT2:	LD	(SECBYT),HL		;Save bytes per sector
	EX	DE,HL
	LD	A,(CURREC)		;Current record number
	LD	L,A
	LD	A,(CUREOT)		;End of track
	SUB	L			;Sectors remaining = EOT - REC
	INC	A
	LD	L,A
	LD	A,(DSKTYP)		;Check mini/maxi
	AND	080H
	JP	Z,CALCT3		;Maxi: use calculated count
	LD	A,(CURHED)		;Mini: check head
	XOR	001H
	JP	NZ,CALCT3		;Head 0: use calculated count
	LD	L,00AH			;Mini head 1: 10 sectors
CALCT3:	LD	A,L			;Multiply sectors * bytes/sector
	LD	L,000H
	LD	H,L
CALCT4:	ADD	HL,DE			;HL += sector_size
	DEC	A
	JP	NZ,CALCT4
	LD	(TRBYT),HL		;Store transfer byte count
	RET

;------------------------------------------------------------------------
; READTK - Read track with retry
; Entry: A = FDC command, C = retry count
; (cf. rob358 READ/READOK)
;------------------------------------------------------------------------

READTK:
	PUSH	AF			;Save FDC command
	LD	A,C
	LD	(REPTIM),A		;Set retry count
	CALL	CLRFLF			;Clear floppy interrupt flag
	LD	HL,(TRBYT)		;Get transfer byte count
	LD	B,H
	LD	C,L
	DEC	BC			;BC = count - 1
	LD	HL,(MEMADR)		;Get DMA target address
	POP	AF
	PUSH	AF
	AND	00FH			;Mask command type
	CP	00AH			;Read ID command?
	CALL	NZ,STPDMA		;Set up DMA (read mode) if not Read ID
	POP	AF
	LD	C,A			;Save command in C
	CALL	FLRTRK			;Send FDC command
	LD	A,0FFH
	CALL	WAITFL			;Wait for floppy interrupt
	RET	C			;Return if timeout
	LD	A,C
	CALL	075B3H			;Check FDC result (CHKRES)
	RET	NC			;Return if no error
	RET	Z			;Return if retries exhausted
	LD	A,C
	PUSH	AF
	JP	07588H			;Retry (back to CLRFLF)

;------------------------------------------------------------------------
; Check FDC result status bytes (entry at 075B3H via overlapping code)
; Returns: NC if OK, C+NZ if error with retries, C+Z if retries exhausted
;------------------------------------------------------------------------

	LD	HL,FDCRES		;Point to result status bytes
	LD	A,(HL)			;Get ST0
	AND	0C3H			;Mask command/drive bits
	LD	B,A
	LD	A,(DRVSEL)		;Expected drive select
	CP	B			;Match?
	JP	NZ,CHKERR		;No: error
	INC	HL
	LD	A,(HL)			;Get ST1
	CP	000H
	JP	NZ,CHKERR		;Non-zero: error
	INC	HL
	LD	A,(HL)			;Get ST2
	AND	0BFH			;Mask bit 6 (control mark)
	CP	000H
	JP	NZ,CHKERR		;Non-zero: error
	SCF				;Set carry
	CCF				;Clear carry = success
	RET

CHKERR:
	LD	A,(REPTIM)		;Decrement retry count
	DEC	A
	LD	(REPTIM),A
	SCF				;Set carry = error
	RET

;------------------------------------------------------------------------
; FLRTRK - Send FDC read/write command (cf. rob358 FLRTRK)
; Builds and sends command buffer to FDC
;------------------------------------------------------------------------

FLRTRK:
	PUSH	BC
	PUSH	AF
	DI
	LD	A,0FFH
	LD	HL,COMBUF		;Command buffer
	LD	(FDCFLG),A		;Set FDC busy flag
	LD	A,(L07320H)		;Get status flags
	AND	001H			;Check side bit
	JP	Z,075F2H		;Side 0: skip MFM flag
	LD	A,040H			;Side 1: set MFM flag
	LD	B,A
	POP	AF
	PUSH	AF
	ADD	A,B			;Add MFM flag to command
	LD	(HL),A			;Store in command buffer
	INC	HL
	CALL	MKDHB			;Make drive/head byte
	LD	(HL),A			;Store drive/head
	DEC	HL
	POP	AF
	AND	00FH			;Mask command type
	CP	006H			;Format command?
	LD	C,009H			;Format: 9 bytes to send
	JP	Z,07609H		;Jump to send loop
	LD	C,002H			;Non-format: 2 bytes
	LD	A,(HL)			;Load command byte
	INC	HL
	CALL	0763CH			;Wait FDC write ready (FLO2)
	DEC	C
	JP	NZ,07609H		;Loop: send remaining bytes
	POP	BC
	EI
	RET
;------------------------------------------------------------------------
; DMA setup - Write mode entry
; HL = memory address, BC = byte count - 1
; (cf. rob358 STPDMA - shared code between read/write modes)
;------------------------------------------------------------------------

DMAWRT:
	LD	A,005H			;Mask channel 1
	DI
	OUT	(SMSK),A		;Set channel mask
	LD	A,049H			;Mode: write, channel 1, auto-init
	OUT	(DMAMOD),A		;Set DMA mode
	OUT	(CLBP),A		;Clear byte pointer flip-flop
	LD	A,L
	OUT	(CH1ADR),A		;Set address low byte
	LD	A,H
	OUT	(CH1ADR),A		;Set address high byte
	LD	A,C
	OUT	(WCREG1),A		;Set word count low
	LD	A,B
	OUT	(WCREG1),A		;Set word count high
	LD	A,001H
	OUT	(SMSK),A		;Enable DMA channel 1
	EI
	RET

;------------------------------------------------------------------------
; STPDMA - Set up DMA for read (cf. rob358 STPDMA)
; HL = memory address, BC = byte count - 1
;------------------------------------------------------------------------

STPDMA:
	LD	A,005H			;Mask channel 1
	DI
	OUT	(SMSK),A		;Set channel mask
	LD	A,045H			;Mode: read, channel 1, auto-init
	JP	0761CH			;Share DMA setup code

;------------------------------------------------------------------------
; Wait FDC ready to write + send byte (entry at 0763CH via overlapping)
; Waits for FDC RQM=1/DIO=0, then writes A to FDD
; (cf. rob358 FLO2)
;------------------------------------------------------------------------

	PUSH	AF
	PUSH	BC
	LD	B,000H			;Timeout counter high
	LD	C,000H			;Timeout counter low
	INC	B			;Increment counter
	CALL	Z,FDCTOUT		;Timeout if B overflows to 0
	IN	A,(FDC)			;Read FDC main status
	AND	0C0H			;Mask RQM and DIO bits
	CP	080H			;Ready for write? (RQM=1, DIO=0)
	JP	NZ,07642H		;No: keep waiting
	POP	BC
	POP	AF
	OUT	(FDD),A			;Write data byte to FDC
	RET

;------------------------------------------------------------------------
; FLO3 - Wait FDC ready to read (cf. rob358 FLO3)
; Returns data byte from FDC in A
;------------------------------------------------------------------------

FLO3:
	PUSH	BC
	LD	B,000H			;Timeout counter high
	LD	C,000H			;Timeout counter low
	INC	B			;Increment counter
	CALL	Z,FDCTOUT		;Timeout if B overflows to 0
	IN	A,(FDC)			;Read FDC main status
	AND	0C0H			;Mask RQM and DIO bits
	CP	0C0H			;Ready for read? (RQM=1, DIO=1)
	JP	NZ,07659H		;No: keep waiting
	POP	BC
	IN	A,(FDD)			;Read data byte from FDC
	RET

;------------------------------------------------------------------------
; FDCTOUT - FDC timeout handler
;------------------------------------------------------------------------

FDCTOUT:
	LD	B,000H			;Reset high counter
	INC	C			;Increment group counter
	RET	NZ			;Return if not fully timed out
	EI				;Full timeout: enable interrupts
	JP	L72C4			;Jump to error handler

;------------------------------------------------------------------------
; Sense drive status (FDC command 04H)
;------------------------------------------------------------------------

SNSDRV:
	LD	A,004H			;Sense drive status command
	CALL	0763CH			;Wait FDC write ready (FLO2)
	LD	A,(DRVSEL)		;Drive select byte
	CALL	0763CH			;Wait FDC write ready (FLO2)
	CALL	FLO3			;Read ST3 result
	LD	(FDCRES),A		;Save ST3
	RET

;------------------------------------------------------------------------
; FLO6 - Sense interrupt status (cf. rob358 FLO6)
;------------------------------------------------------------------------

FLO6:
	LD	A,008H			;Sense interrupt status command
	CALL	0763CH			;Wait FDC write ready (FLO2)
	CALL	FLO3			;Read ST0
	LD	(FDCRES),A		;Save ST0
	AND	0C0H			;Check status bits
	CP	080H			;Invalid command?
	JP	Z,0769CH		;Yes: skip reading PCN
	CALL	FLO3			;Read present cylinder number
	LD	(FDCRS1),A		;Save PCN
	RET

;------------------------------------------------------------------------
; CLRFLF - Clear floppy interrupt flag
;------------------------------------------------------------------------

CLRFLF:
	DI
	XOR	A
	LD	(FLPFLG),A		;Clear flag
	EI
	RET

;------------------------------------------------------------------------
; MKDHB - Make drive/head byte
; Returns A = (head << 2) | drive
;------------------------------------------------------------------------

MKDHB:
	PUSH	DE
	LD	A,(CURHED)		;Get current head
	RLA				;Shift head to bit 2
	RLA
	LD	D,A
	LD	A,(DRVSEL)		;Get drive select
	ADD	A,D			;Combine drive and head
	POP	DE
	RET

;------------------------------------------------------------------------
; DELAY - Delay loop (cf. rob358 FDSTAR W1/W2)
; B = outer count, C = inner count
;------------------------------------------------------------------------

DELAY:
	PUSH	AF
	PUSH	HL
DELY1:	LD	H,C			;Inner loop count
	LD	L,0FFH
	DEC	HL			;Decrement inner counter
	LD	A,L
	OR	H
	JP	NZ,076B6H		;Inner loop
	DEC	B			;Decrement outer counter
	JP	NZ,DELY1		;Outer loop
	POP	HL
	POP	AF
	RET

;------------------------------------------------------------------------
; WAITFL - Wait for floppy interrupt
; Entry: A = timeout count
; Returns: C flag if timeout, NC if interrupt received
;------------------------------------------------------------------------

WAITFL:
	PUSH	BC
WAIT1:	DEC	A			;Decrement timeout counter
	SCF
	JP	Z,076DFH		;Timed out: clear flag and return C
	LD	B,001H
	LD	C,001H
	CALL	DELAY			;Short delay
	LD	B,A			;Save counter
	LD	A,(FLPFLG)		;Check floppy interrupt flag
	AND	002H			;Interrupt occurred?
	LD	A,B			;Restore counter
	JP	Z,WAIT1			;No: keep waiting
	SCF				;Set carry
	CCF				;Clear carry = success
	CALL	CLRFLF			;Clear flag for next time
	POP	BC
	RET

;------------------------------------------------------------------------
; FLWRES - Wait for floppy result
; Returns: B = ST0, C = PCN/ST1
;------------------------------------------------------------------------

FLWRES:
	LD	A,0FFH
	CALL	WAITFL			;Wait for floppy interrupt
	LD	A,(FDCRES)		;Get ST0
	LD	B,A
	LD	A,(FDCRS1)		;Get PCN/ST1
	LD	C,A
	RET

;------------------------------------------------------------------------
; FLO4 - Recalibrate drive (cf. rob358 FLO4)
;------------------------------------------------------------------------

FLO4:
	LD	A,007H			;Recalibrate command
	CALL	0763CH			;Wait FDC write ready (FLO2)
	LD	A,(DRVSEL)		;Drive select
	CALL	0763CH			;Wait FDC write ready (FLO2)
	RET

;------------------------------------------------------------------------
; FLO7 - Seek track (cf. rob358 FLO7)
; Entry: D = drive/head byte, E = cylinder number
;------------------------------------------------------------------------

FLO7:
	LD	A,00FH			;Seek command
	CALL	0763CH			;Wait FDC write ready (FLO2)
	LD	A,D
	AND	007H			;Mask drive/head bits
	CALL	0763CH			;Wait FDC write ready (FLO2)
	LD	A,E			;Cylinder number
	CALL	0763CH			;Wait FDC write ready (FLO2)
	RET

;------------------------------------------------------------------------
; Recalibrate and verify result
; Returns: NC if successful
;------------------------------------------------------------------------

	CALL	FLO4			;Recalibrate drive
	CALL	FLWRES			;Wait for result
	RET	C			;Return if timeout
	LD	A,(DRVSEL)		;Check result
	ADD	A,020H			;Expected: seek end + drive
	CP	B			;Match ST0?
	JP	NZ,0771EH		;No: error
	LD	A,C
	CP	000H			;Cylinder 0?
	SCF				;Set carry
	CCF				;Clear carry = success
	RET

;------------------------------------------------------------------------
; FLSEEK - Seek to current cylinder with verify
; (cf. rob358 FLO7 with result check)
;------------------------------------------------------------------------

FLSEEK:
	LD	A,(CURCYL)		;Get target cylinder
	LD	E,A
	CALL	MKDHB			;Get drive/head byte
	LD	D,A
	CALL	FLO7			;Seek to cylinder
	CALL	FLWRES			;Wait for result
	RET	C			;Return if timeout
	LD	A,(DRVSEL)		;Check result
	ADD	A,020H			;Expected: seek end + drive
	CP	B			;Match ST0?
	JP	NZ,SEEKERR		;No: error
	LD	A,(CURCYL)		;Verify cylinder
	CP	C			;Match PCN?
SEEKERR:
	SCF				;Set carry
	CCF				;Clear carry = success
	RET

;------------------------------------------------------------------------
; RSULT - Read FDC result bytes (cf. rob358 RSULT)
; Reads up to 7 result bytes from FDC into FDCRES buffer
;------------------------------------------------------------------------

RSULT:
	LD	HL,FDCRES		;Result buffer
	LD	B,007H			;Max 7 result bytes
	LD	A,B
	LD	(FDCFLG),A		;Mark FDC busy
	CALL	FLO3			;Read first result byte
	LD	(HL),A			;Store in buffer
	INC	HL
	LD	A,(FDCWAI)		;FDC timing delay
	DEC	A
	JP	NZ,07751H		;Delay loop
	IN	A,(FDC)			;Check FDC status
	AND	010H			;Non-DMA execution mode?
	JP	Z,07765H		;No: check DMA status
	DEC	B			;More bytes to read?
	JP	NZ,07749H		;Yes: read next byte
	LD	A,0FEH			;Error: too many result bytes
	JP	073C9H			;Error handler (ERRDSP)
	IN	A,(DMACOM)		;Read DMA status
	LD	(HL),A			;Store in buffer
	DEC	B
	RET	Z			;All bytes read
	EI
	LD	A,0FDH			;Error: incomplete result
	JP	073C9H			;Error handler (ERRDSP)

;------------------------------------------------------------------------
; FLPBDY - Floppy interrupt handler body (cf. rob358 FLPINT)
;------------------------------------------------------------------------

FLPBDY:
	PUSH	AF
	PUSH	BC
	PUSH	HL
	LD	A,002H
	LD	(FLPFLG),A		;Set floppy interrupt flag
	LD	A,(FDCTMO)		;FDC timeout counter
	DEC	A
	JP	NZ,0777BH		;Delay loop
	IN	A,(FDC)			;Read FDC status
	AND	010H			;Non-DMA execution mode?
	JP	NZ,0778CH		;Yes: read full result
	CALL	FLO6			;Sense interrupt status
	JP	0778FH			;Exit
	CALL	RSULT			;Read full result
	POP	HL
	POP	BC
	POP	AF
	EI
	RETI
	NOP
	NOP
main_last:
	dephase

	; DATA AREA - RAM variables used by boot ROM
	; (cf. rob358.mac EQU block at 0xB000 for RC700/RC703 equivalents)
	ORG	08000H
TRK:	DS	03H		;Track count (cf. rob358 TRK at 0xB000)
ERRSAV:	DS	1		;Error code save (written in errdsp)
	DS	7		;(unused/padding)
FDCFLG:	DS	1		;FDC busy flag (0xFF=busy)
EPTS:	DS	1		;EOT / sectors per track
TRKSZ:	DS	1		;Track sector size byte
	DS	2		;(unused/padding)
FDCRES:	DS	1		;FDC result area: ST0 (7 bytes total)
FDCRS1:	DS	5		;FDC result: ST1/PCN through C,H,R
FDCRS6:	DS	1		;FDC result: N (record length)
	DS	4		;(unused/padding)
DRVSEL:	DS	1		;Drive select / head byte
FDCTMO:	DS	1		;FDC timeout counter (init=3)
FDCWAI:	DS	1		;FDC wait counter (init=4)
SPSAV:	DS	12H		;Stack pointer save + workspace
COMBUF:	DS	1		;FDC command buffer (9 bytes)
	DS	1		;  drive/head byte
CURCYL:	DS	1		;  current cylinder number
CURHED:	DS	1		;  current head address
CURREC:	DS	1		;  current record/sector number
RECLEN:	DS	1		;  record length (N)
CUREOT:	DS	1		;  current EOT (end of track)
	DS	2		;  GAP3 + DTL
SECBYT:	DS	1		;Sector byte count (word)
	DS	7		;(unused/padding)
FLPFLG:	DS	1		;Floppy interrupt flag (0=idle, 2=done)
FLPWAI:	DS	1		;Floppy wait counter (init=4)
	DS	29		;(unused/padding)
DSKTYP:	DS	1		;Disk type flag (bit7=mini, bit0=floppy boot)
MOREFL:	DS	1		;More data to transfer flag
REPTIM:	DS	1		;Repeat/retry counter (init=5)
CLRBLK:	DS	1		;Start of 8-byte cleared block
	DS	1
MEMADR:	DS	1		;Memory address pointer (word, DMA dest)
	DS	1
TRBYT:	DS	1		;Transfer byte count (word)
	DS	1
TRKOVR:	DS	1		;Track overflow count (word)
TRKOV2:	DS	1		;Track overflow high byte





	END
