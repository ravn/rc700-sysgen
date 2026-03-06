; CHKSUM.COM — Print CRC-16 checksum of a CP/M file
; Usage: A>CHKSUM FILENAME.EXT
; Output: 4 hex digits (CRC-16 of all bytes in all 128-byte records)
;
; CRC-16: polynomial 0x8408 (CCITT reversed), init 0xFFFF
; Same polynomial as used by SNIOS serial protocol.

	.Z80
	ORG	100H

BDOS	EQU	5
FCB	EQU	5CH
DMA	EQU	80H

	; Check that a filename was given (FCB byte 1 != space)
	LD	A,(FCB+1)
	CP	' '
	JR	Z,NOFILE

	; Open file (CCP already set up FCB from command line)
	LD	C,15		; BDOS F15 = OPEN FILE
	LD	DE,FCB
	CALL	BDOS
	INC	A		; A=FF on error -> becomes 0
	JR	Z,NOFILE

	; Clear current record (FCB+32)
	XOR	A
	LD	(FCB+32),A

	; Initialize CRC-16 to FFFF
	LD	HL,0FFFFH

	; Read loop: read 128-byte records, update CRC for all bytes
RDLOOP:	LD	C,20		; BDOS F20 = READ SEQUENTIAL
	LD	DE,FCB
	PUSH	HL
	CALL	BDOS
	POP	HL
	OR	A
	JR	NZ,DONE		; Non-zero = EOF or error

	; CRC 128 bytes at DMA buffer
	LD	DE,DMA
	LD	B,128
CRCLP:	LD	A,(DE)
	INC	DE
	CALL	CRC16
	DJNZ	CRCLP
	JR	RDLOOP

DONE:	; Print CRC as 4 uppercase hex digits
	PUSH	HL
	LD	A,H
	CALL	PRHEX
	POP	HL
	LD	A,L
	CALL	PRHEX
	; CR LF
	LD	E,13
	LD	C,2
	CALL	BDOS
	LD	E,10
	LD	C,2
	CALL	BDOS
	RET

NOFILE:	LD	E,'?'
	LD	C,2
	CALL	BDOS
	RET

; CRC16 - Update CRC-16 with byte in A
; HL = current CRC (updated in place)
; Polynomial: 0x8408 (CCITT reversed)
CRC16:	XOR	L		; A = byte XOR CRC_low
	LD	L,A
	LD	E,8		; 8 bits
CRC0:	SRL	H		; shift CRC right through carry
	RR	L
	JR	NC,CRC1		; if no carry, skip XOR
	LD	A,H
	XOR	84H		; polynomial high
	LD	H,A
	LD	A,L
	XOR	08H		; polynomial low
	LD	L,A
CRC1:	DEC	E
	JR	NZ,CRC0
	RET

; Print A as 2 hex digits (uppercase)
PRHEX:	PUSH	AF
	RRCA
	RRCA
	RRCA
	RRCA
	CALL	PRDIG
	POP	AF
PRDIG:	AND	0FH
	ADD	A,'0'
	CP	'9'+1
	JR	C,PRDG1
	ADD	A,7		; 'A'-'0'-10
PRDG1:	LD	E,A
	LD	C,2		; BDOS F2 = CONSOLE OUTPUT
	JP	BDOS

	END
