; AUTOEXEC.COM — RC700/RC855 Autoexec Utility
; Version 1.0, 10.01.83
; COPYRIGHT (C) 1979 DIGITAL RESEARCH
;
; Disassembled from SW1711-I8.imd system disk (1024 bytes)
;
; PURPOSE:
;   Patches a user-specified command into the CCP's command buffer on the
;   system disk (Track 1, Sector 0). On subsequent boots, the CCP finds
;   the pre-loaded command and executes it automatically.
;
; MECHANISM:
;   The CCP image on disk starts at Track 1, Sector 0. WBOOT reads it
;   directly into CPMB (CC00h for 56K). The CCP layout at CPMB:
;     +0: JP ccpmain   (entry with command pre-loaded in buffer)
;     +3: JP ccpclear  (entry that clears buffer, shows A> prompt)
;     +7: command buffer length
;     +8: (unused byte)
;     +9: command text (up to ~80 chars)
;     +9+len: CW flag  (0=cold boot only, 1=cold+warm boot)
;
;   GOCPM in the BIOS checks CPMB+7 on each warm boot. If a command is
;   present and CW=1, it executes. If CW=0, GOCPM jumps to CPMB+3
;   (CCPCLR) to clear the command after the first boot.
;
; MACHINE DETECTION:
;   Reads MTYPE variable at BIOS+36h (DA36h for 56K). This is the
;   machine type byte: 0=RC700, 1=RC850/RC855, 2=ITT3290, 3=RC703.
;   AUTOEXEC checks for 01h (RC855) to select the banner string.
;
; BIOS ADDRESSES (56K, DA00h jump table):
;   DA1Bh = SELDSK    DA1Eh = SETTRK    DA21h = SETSEC
;   DA24h = SETDMA    DA27h = READ      DA2Ah = WRITE
;   DA36h = MTYPE (machine type variable)

MTYPE	EQU	0DA36H		; BIOS MTYPE: 01h = RC850/RC855

BDOS	EQU	0005H		; CP/M BDOS entry point
WBOOT	EQU	0000H		; CP/M warm boot entry

	ORG	0100H

;========================================================
;= ENTRY POINT                                          =
;========================================================

	JP	MAIN		; 0100

;========================================================
;= STRING DATA ($-terminated for BDOS function 9)       =
;========================================================

S_RC855:	DB	'RC855$'			; 0103
S_RC700:	DB	'RC700$'			; 0109
S_VER:	DB	'  Autoexec vers. 1.0  10.01.83'	; 010F
	DB	0DH,0AH,0AH,'$'

S_CMD:	DB	'Enter command line to auto-execute,'	; 0131
	DB	' then press <return>',0DH,0AH,'$'

S_WHEN_DO_YOU_WISH:	DB	0DH,0AH					; 016B
	DB	'When do you wish to auto-execute'
	DB	' the command line ?',0DH,0AH,0AH
	DB	09H,'1 - after each cold- and warm-boot'
	DB	0DH,0AH
	DB	09H,'2 - after a cold boot only'
	DB	0DH,0AH,0AH
	DB	'Select option: $'

S_INS1:	DB	0DH,0AH					; 01F6
	DB	'Insert CP/M system disk to modify'
	DB	' in drive A, then press <return>$'

S_INS2:	DB	0DH,0AH					; 023A
	DB	'Insert CP/M system disk in drive A,'
	DB	' then press <return>$'

S_BAD:	DB	0DH,0AH,'Bad sector$'			; 0274

S_NOSY:	DB	0DH,0AH,'No system$'			; 0281

S_ABORT:	DB	' on disk in drive A'			; 028D
	DB	0DH,0AH,'Autoexec ABORTED$'

S_COPY:	DB	'COPYRIGHT (C) 1979 DIGITAL RESEARCH '	; 02B3
COPYLN	EQU	$ - S_COPY	; 36 bytes (24h)

;========================================================
;= BDOS CALL TRAMPOLINES                                =
;========================================================

PRINT:	LD	C,09H		; BDOS function 9: print string	; 02D7
	JP	BDOS

RDCON:	LD	C,0AH		; BDOS function 10: read console buf ; 02DC
	JP	BDOS

;========================================================
;= BIOS CALL TRAMPOLINES (56K addresses)                =
;= Derived from 56 Kb BIOS names.                       =
;========================================================

SELDSK:	JP	0DA1BH		; 02E1
SETTRK:	JP	0DA1EH		; 02E4
SETSEC:	JP	0DA21H		; 02E7
SETDMA:	JP	0DA24H		; 02EA
READ:	JP	0DA27H		; 02ED
WRITE:	JP	0DA2AH		; 02F0

; Machine type: read MTYPE variable at BIOS+36h.
; Returns 01h for RC855, 00h for RC700.
GMTYPE:	LD	A,(MTYPE)	; 02F3
	RET			; 02F6

;========================================================
;= MAIN PROGRAM                                         =
;========================================================

MAIN:	LD	SP,STACK	; 02F7  set up stack

;-- Detect machine and print banner --

	LD	DE,S_RC855	; "RC855$" (assume RC855)
	CALL	GMTYPE		; read MTYPE variable
	CP	01H		; RC855?
	JR	Z,PNAME		; yes: print "RC855"
	LD	DE,S_RC700	; no: use "RC700"
PNAME:	CALL	PRINT		; print machine name
	LD	DE,S_VER	; " Autoexec vers. 1.0 ..."
	CALL	PRINT

;-- Get command from user --

	LD	DE,S_CMD	; "Enter command line..."
	CALL	PRINT
	LD	DE,CMDBUF	; console input buffer
	CALL	RDCON		; read command

;-- Convert command to uppercase --

	LD	HL,CMDLEN	; pointer to actual length
	LD	B,(HL)		; B = character count
	INC	B		; \
	DEC	B		;  > test B for zero (sets Z flag)
	JR	Z,ASKOPT	; skip if empty input
UCLOOP:	INC	HL		; advance to next char
	LD	A,(HL)
	CP	60H		; below '`'?
	JR	C,UCSKIP	; skip non-lowercase
	AND	5FH		; convert to uppercase
	LD	(HL),A
UCSKIP:	DJNZ	UCLOOP

;-- Ask cold/warm boot option --

ASKOPT:	LD	DE,S_WHEN_DO_YOU_WISH	; "When do you wish..."
	CALL	PRINT
	LD	DE,OPTBUF	; 1-char console buffer
	CALL	RDCON		; read option
	LD	A,(OPTCHR)	; get typed character
	CP	'1'		; option 1?
	JR	Z,OPT1
	CP	'2'		; option 2?
	JR	NZ,ASKOPT	; invalid: re-prompt
	LD	A,00H		; option 2: cold boot only (CW=0)
	JR	SAVOPT
OPT1:	LD	A,01H		; option 1: cold+warm boot (CW=1)
SAVOPT:	LD	(CWFLAG),A	; save cold/warm flag

;-- Prompt to insert target disk --

	LD	DE,S_INS1	; "Insert CP/M system disk to modify..."
	CALL	PRINT
	LD	DE,OPTBUF	; wait for <return>
	CALL	RDCON

;-- Read Track 1, Sector 0 (first 128 bytes of CCP on disk) --

	LD	C,00H		; drive A
	CALL	SELDSK
	LD	BC,SECBUF	; DMA address = sector buffer
	CALL	SETDMA
	LD	BC,1		; track 1
	CALL	SETTRK
	LD	BC,0		; sector 0
	CALL	SETSEC
	CALL	READ
	OR	A
	JR	NZ,BADSEC	; read error

;-- Verify sector contains CCP (two JP instructions) --

	LD	IX,SECBUF
	LD	A,0C3H		; JP opcode
	CP	(IX+0)		; byte 0 = JP?
	JR	NZ,NOSYS	; no: not a system disk
	CP	(IX+3)		; byte 3 = JP?
	JR	NZ,NOSYS	; no: not a system disk

;-- Patch command into CCP sector --
; Layout: [7 bytes preserved][len][cmd text][00][CW flag][COPYRIGHT...][00-fill]

	LD	DE,SECBUF+7	; destination: CCP command buffer area
	LD	HL,CMDLEN	; source: length byte from user input
	LD	B,00H
	LD	C,(HL)		; C = command length
	INC	BC		; include length byte
	LDIR			; copy length + command text
	EX	DE,HL
	LD	(HL),00H	; null terminator after command
	INC	HL
	LD	A,(CWFLAG)	; cold/warm flag
	LD	(HL),A		; store after command text
	INC	HL
	EX	DE,HL

;-- Append copyright string and zero-fill remainder --

	LD	HL,S_COPY	; "COPYRIGHT (C) 1979 DIGITAL RESEARCH "
	LD	BC,COPYLN	; 36 bytes
	LDIR
	LD	HL,SECEND	; end of 128-byte sector
	OR	A
	SBC	HL,DE		; remaining bytes
	LD	B,L		; count
	EX	DE,HL
ZFILL:	LD	(HL),00H	; zero fill
	INC	HL
	DJNZ	ZFILL

;-- Write patched sector back to Track 1, Sector 0 --

	LD	C,01H		; C=1 (directory-type write: no deblocking)
	CALL	WRITE
	OR	A
	JR	NZ,BADSEC	; write error

;-- Verification read on Track 2 (flush write buffer / sanity check) --

	LD	BC,2
	CALL	SETTRK		; track 2
	CALL	READ		; read (same sector 0, same DMA)
	OR	A
	JR	Z,DONE		; success

;-- Error handlers --

BADSEC:	LD	DE,S_BAD	; "Bad sector"
	CALL	PRINT
	JR	ABORT
NOSYS:	LD	DE,S_NOSY	; "No system"
	CALL	PRINT
ABORT:	LD	DE,S_ABORT	; " on disk in drive A / Autoexec ABORTED"
	CALL	PRINT

;-- Done: prompt for system disk and warm boot --

DONE:	LD	DE,S_INS2	; "Insert CP/M system disk in drive A..."
	CALL	PRINT
	LD	DE,OPTBUF	; wait for <return>
	CALL	RDCON
	JP	WBOOT		; warm boot (CCP will execute patched command)

;========================================================
;= DATA AREA                                            =
;========================================================

CWFLAG:	DB	00H		; 03EA  cold/warm flag (0=cold only, 1=both)

; Console input buffer for command (BDOS fn 10 format)
CMDBUF:	DB	50H		; 03EB  max length (80 chars)
CMDLEN:	DB	00H		; 03EC  actual length (filled by BDOS)
CMDTXT:	DS	80		; 03ED  command text

; Console input buffer for option / return key
OPTBUF:	DB	01H		; 043D  max length (1 char)
OPTLEN:	DB	00H		; 043E  actual length
OPTCHR:	DB	00H		; 043F  typed character

; Sector buffer (128 bytes for Track 1, Sector 0)
SECBUF:	DS	128		; 0440-04BF
SECEND	EQU	$		; 04C0

; Stack area
	DS	20		; 04C0-04D3
STACK	EQU	$		; 04D4

	END
