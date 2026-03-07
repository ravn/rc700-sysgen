; CHKSUM.COM — Print 16-bit sum of a CP/M file
; Usage: A>CHKSUM FILENAME.EXT
; Output: 4 uppercase hex digits (sum of all bytes in all 128-byte records)

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

	; Initialize 16-bit sum to 0
	LD	HL,0

	; Read loop: read 128-byte records, accumulate sum of all bytes
RDLOOP:	LD	C,20		; BDOS F20 = READ SEQUENTIAL
	LD	DE,FCB
	PUSH	HL
	CALL	BDOS
	POP	HL
	OR	A
	JR	NZ,DONE		; Non-zero = EOF or error

	; Sum 128 bytes at DMA buffer
	LD	DE,DMA
	LD	B,128
SUMLP:	LD	A,(DE)
	INC	DE
	ADD	A,L
	LD	L,A
	ADC	A,H
	SUB	L
	LD	H,A
	DJNZ	SUMLP
	JR	RDLOOP

DONE:	; Print sum as 4 uppercase hex digits
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
