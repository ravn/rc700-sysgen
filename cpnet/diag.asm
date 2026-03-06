; CP/NET diagnostic: check BDOS version and CP/NET detection
; Assemble: zmac -z diag.asm -o diag.cim
; Usage: rename diag.cim to DIAG.COM and run on CP/M

	.Z80
	ORG	100H

BDOS	EQU	5
CONOUT	EQU	2
GETVER	EQU	12
PRTSTR	EQU	9

START:
	; Print header
	LD	DE,MSG1
	LD	C,PRTSTR
	CALL	BDOS

	; Call BDOS function 12 (get version)
	LD	E,0
	LD	C,GETVER
	CALL	BDOS
	; Returns: L = version, H = system type

	PUSH	HL		; save result

	; Print L (version)
	LD	A,L
	CALL	PRHEX

	; Print " H="
	LD	DE,MSG2
	LD	C,PRTSTR
	CALL	BDOS

	; Print H (system type)
	POP	HL
	PUSH	HL
	LD	A,H
	CALL	PRHEX

	; Check CP/NET bit (H bit 1 = 0x02)
	POP	HL
	LD	A,H
	AND	02H
	JR	Z,NOTNET

	; CP/NET detected
	LD	DE,MSG3
	LD	C,PRTSTR
	CALL	BDOS
	JR	DONE

NOTNET:	; CP/NET not detected
	LD	DE,MSG4
	LD	C,PRTSTR
	CALL	BDOS

DONE:	; Also show byte at 0006h-0007h (BDOS entry vector)
	LD	DE,MSG5
	LD	C,PRTSTR
	CALL	BDOS
	LD	A,(7)		; high byte of BDOS entry
	CALL	PRHEX
	LD	A,(6)		; low byte
	CALL	PRHEX

	; Show what CPNETLDR checks: replicate its exact logic
	LD	DE,MSG6
	LD	C,PRTSTR
	CALL	BDOS

	; Redo BDOS function 12
	LD	E,0
	LD	C,GETVER
	CALL	BDOS
	; HL = result

	; ANHLDE: HL = HL AND DE where DE=0200h
	LD	DE,0200H
	LD	A,E		; A = 00
	AND	L		; A = 00 AND L = 0
	LD	L,A		; L = 0
	LD	A,D		; A = 02
	AND	H		; A = 02 AND H
	LD	H,A		; H = result

	; Show H after AND
	PUSH	HL
	LD	A,H
	CALL	PRHEX
	POP	HL

	; SUBYHL: HL = 0 - HL
	LD	A,0
	SUB	L
	LD	L,A
	LD	A,0
	SBC	A,H
	LD	H,A
	; Now A = -H, L should be 0

	; ORA L equivalent
	OR	L

	; Show result
	PUSH	AF
	LD	DE,MSG7
	LD	C,PRTSTR
	CALL	BDOS
	POP	AF
	PUSH	AF
	CALL	PRHEX

	; Show verdict
	POP	AF
	OR	A		; re-set flags
	JR	NZ,WOULDLOAD

	LD	DE,MSG8		; "=OK, would load"
	LD	C,PRTSTR
	CALL	BDOS
	JR	FIN

WOULDLOAD:
	LD	DE,MSG9		; "=FAIL, already loaded"
	LD	C,PRTSTR
	CALL	BDOS

FIN:
	; Newline
	LD	E,0DH
	LD	C,CONOUT
	CALL	BDOS
	LD	E,0AH
	LD	C,CONOUT
	CALL	BDOS

	RET			; return to CCP

; Print byte in A as 2 hex digits
PRHEX:	PUSH	AF
	RRCA
	RRCA
	RRCA
	RRCA
	CALL	PRDIG
	POP	AF
PRDIG:	AND	0FH
	ADD	A,30H
	CP	3AH
	JR	C,PRD1
	ADD	A,7
PRD1:	LD	E,A
	LD	C,CONOUT
	JP	BDOS

MSG1:	DB	'BDOS F12: L=$'
MSG2:	DB	' H=$'
MSG3:	DB	' ** CPNET DETECTED **$'
MSG4:	DB	' (no cpnet)$'
MSG5:	DB	0DH,0AH,'BDOS@=$'
MSG6:	DB	0DH,0AH,'CPNETLDR check: H&02=$'
MSG7:	DB	' ORA=$'
MSG8:	DB	' OK(would load)$'
MSG9:	DB	' FAIL(already loaded)$'

	END
