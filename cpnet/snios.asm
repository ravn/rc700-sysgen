; RC702 CP/NET SNIOS (Slave Network I/O System)
; Serial hex-encoded CRC-16 protocol over BIOS READER/PUNCH/READS
;
; Adapted from cpnet-z80/src/serial/snios.asm
; Rewritten in native Z80 mnemonics for zmac assembler
;
; Character I/O calls BIOS READER/PUNCH/READS through the standard
; jump table at DA00h (56K system). No direct hardware access.
;
; Assembled at ORG 0000h for SPR relocation.
; build_snios.py assembles twice and generates the relocation bitmap.
;

	.Z80

; BIOS entry points (56K system, BIOS base = DA00h)
B$COUT	EQU	0DA0CH		; BIOS CONOUT (patched by NDOS to NCONOT hook)
B$PUNCH	EQU	0DA12H		; BIOS PUNCH (send byte in C via SIO Ch.A)
B$READ	EQU	0DA15H		; BIOS READER (receive byte from SIO Ch.A)
B$RSTA	EQU	0DA4DH		; BIOS READS (reader status, 0=not ready)

; Timeout loop counts for receive polling
STTIMO	EQU	8000H		; START TIMEOUT (FINITE FOR DEBUGGING)
CHTIMO	EQU	0800H		; CHAR TIMEOUT (BETWEEN ADJACENT CHARS)

; Network status byte flags
ACTIVE	EQU	00010000B	; SLAVE LOGGED IN ON NETWORK
RCVERR	EQU	00000010B	; ERROR IN RECEIVED MESSAGE
SNDERR	EQU	00000001B	; UNABLE TO SEND MESSAGE

; CRC-16 polynomial (CCITT reversed)
CRCPOLY	EQU	8408H

	ORG	0

;================================================
;= SNIOS JUMP TABLE (MUST BE FIRST)             =
;= NDOS calls through these offsets              =
;================================================
	JP	NTWKIN		; +00 NETWORK INITIALIZATION
	JP	NTWKST		; +03 NETWORK STATUS
	JP	CNFTBL		; +06 RETURN CONFIG TABLE ADDRESS
	JP	SNDMSG		; +09 SEND MESSAGE ON NETWORK
	JP	RCVMSG		; +0C RECEIVE MESSAGE FROM NETWORK
	JP	NTWKER		; +0F NETWORK ERROR
	JP	NTWKBT		; +12 NETWORK WARM BOOT
	JP	NTWKDN		; +15 NETWORK SHUTDOWN

;================================================
;= SLAVE CONFIGURATION TABLE                    =
;= MUST MATCH CP/NET CFGTBL LAYOUT              =
;================================================
CFGTBL:	DB	0		; +0  NETWORK STATUS BYTE
	DS	1		; +1  SLAVE PROCESSOR ID
	DS	2		; +2  A: DISK DEVICE (BIT7=0 = LOCAL)
	DS	2		; +4  B:
	DS	2		; +6  C:
	DS	2		; +8  D:
	DS	2		; +10 E:
	DS	2		; +12 F:
	DS	2		; +14 G:
	DS	2		; +16 H:
	DS	2		; +18 I:
	DS	2		; +20 J:
	DS	2		; +22 K:
	DS	2		; +24 L:
	DS	2		; +26 M:
	DS	2		; +28 N:
	DS	2		; +30 O:
	DS	2		; +32 P:
	DS	2		; +34 CONSOLE DEVICE (BIT7=0 = LOCAL)
	DS	2		; +36 LIST DEVICE (BIT7=0 = LOCAL)
	DS	1		; +38 BUFFER INDEX
	DB	0		; +39 FMT
	DB	0		; +40 DID
	DB	0FFH		; +41 SID (CP/NOS MUST STILL INITIALIZE)
	DB	5		; +42 FNC (LST: FUNCTION CODE)
	DS	1		; +43 SIZ
	DS	1		; +44 MSG(0) LIST NUMBER
MSGBUF:				; +45 MSG(1)..MSG(128)
	DS	128		; (don't disturb LST: header above)

HOSTID:	DB	0		; SERVER NODE ID

;================================================
;= CHARACTER I/O WRAPPERS                       =
;= Call BIOS through standard jump table         =
;================================================

; SENDBY - Send byte in A via BIOS PUNCH
; Destroys: C
SENDBY:	LD	C,A
	JP	B$PUNCH		; BIOS PUNCH WAITS FOR TX READY

; RECVBY - Receive one byte with char timeout
; Returns: A = byte, CY clear on success; CY set on timeout
; Destroys: C
RECVBY:	PUSH	DE
	PUSH	HL
	LD	HL,CHTIMO
	JR	RCVWT0

; RECVBT - Receive first byte with start timeout
; Returns: A = byte, CY clear on success; CY set on timeout
; Destroys: C
RECVBT:	PUSH	DE
	PUSH	HL
	LD	HL,STTIMO

RCVWT0:	LD	A,H		; CHECK IF TIMEOUT = 0 (WAIT FOREVER)
	OR	L
	JR	Z,RCVWT2	; ZERO = INFINITE WAIT

	; Finite timeout: poll with countdown
RCVWT1:	CALL	B$RSTA		; BIOS READER STATUS
	OR	A
	JR	NZ,RCVWT3	; DATA AVAILABLE
	DEC	HL
	LD	A,H
	OR	L
	JR	NZ,RCVWT1	; KEEP POLLING
	; Timeout expired
	POP	HL
	POP	DE
	SCF			; SIGNAL TIMEOUT
	RET

	; Infinite wait: poll until data arrives
RCVWT2:	CALL	B$RSTA
	OR	A
	JR	Z,RCVWT2

RCVWT3:	CALL	B$READ		; READ BYTE FROM RING BUFFER
	POP	HL
	POP	DE
	OR	A		; CLEAR CARRY (SUCCESS)
	RET

;================================================
;= HEX ENCODING/DECODING                        =
;================================================

; SNDHEX - Send byte in A as 2 ASCII hex digits
; Destroys: C, E
SNDHEX:	LD	E,A		; SAVE BYTE
	RRCA			; HIGH NIBBLE FIRST
	RRCA
	RRCA
	RRCA
	CALL	SNDDIG
	LD	A,E		; LOW NIBBLE
SNDDIG:	AND	0FH
	ADD	A,90H		; DAA TRICK: BINARY TO ASCII HEX
	DAA
	ADC	A,40H
	DAA
	JP	SENDBY		; SEND AND RETURN

; RCVHEX - Receive 2 ASCII hex digits, return byte in A
; Returns: CY set on timeout or invalid hex
; Destroys: C, E
RCVHEX:	CALL	RCVDIG		; HIGH NIBBLE
	RET	C		; TIMEOUT
	RLCA			; SHIFT TO HIGH NIBBLE
	RLCA
	RLCA
	RLCA
	LD	E,A		; SAVE
	CALL	RCVDIG		; LOW NIBBLE
	RET	C		; TIMEOUT
	OR	E		; COMBINE
	RET

RCVDIG:	CALL	RECVBY		; GET ASCII CHAR
	RET	C		; TIMEOUT
	SUB	'0'
	RET	C		; < '0'
	CP	10
	JR	NC,RCVDG1	; >= 10, TRY A-F
	OR	A		; CLEAR CARRY
	RET
RCVDG1:	SUB	'A'-'0'		; CONVERT A-F
	RET	C		; INVALID
	ADD	A,10
	RET

;================================================
;= CRC-16 CALCULATION                           =
;================================================

; CRC - Update CRC with byte in A
; HL = cumulative CRC, A = new byte
; Destroys: C, E, A
CRC:	LD	E,8		; 8 BITS
CRC0:	LD	C,A		; SAVE BYTE
	XOR	L		; CLEARS CARRY
	RR	H		; SHIFT CRC RIGHT
	RR	L
	AND	1		; CHECK LSB OF (BYTE XOR CRC_LOW)
	JR	Z,CRC1
	LD	A,L		; XOR WITH POLYNOMIAL
	XOR	LOW CRCPOLY
	LD	L,A
	LD	A,H
	XOR	HIGH CRCPOLY
	LD	H,A
CRC1:	LD	A,C		; RESTORE BYTE
	RRA			; SHIFT BYTE RIGHT
	DEC	E
	JR	NZ,CRC0
	OR	A		; CLEAR CARRY ON RETURN
	RET

;================================================
;= SEND/RECEIVE MESSAGE HEADER                  =
;================================================

; SNDHDR - Send "++" sync, then 5-byte header with CRC
; IX = message pointer (advanced by 5 on return)
; Returns: HL = CRC after header, A=0/CY clear on success
; Destroys: B, C, D, E
SNDHDR:	LD	A,'+'		; SYNC BYTE 1
	CALL	SENDBY
	LD	A,'+'		; SYNC BYTE 2
	CALL	SENDBY
	LD	HL,0FFFFH	; INIT CRC
	LD	B,5		; 5 HEADER BYTES
SNDH0:	LD	A,(IX+0)
	INC	IX
	LD	D,A		; SAVE FOR CRC
	CALL	SNDHEX		; SEND AS HEX
	LD	A,D
	CALL	CRC		; UPDATE CRC
	DEC	B
	JR	NZ,SNDH0
	XOR	A		; SUCCESS
	RET

; RCVHDR - Receive 5-byte header, store via IX, compute CRC
; IX = destination buffer (advanced by 5 on return)
; Returns: HL = CRC after header, CY set on error
; Destroys: B, C, E
RCVHDR:	LD	HL,0FFFFH	; INIT CRC
	LD	B,5		; 5 HEADER BYTES
RCVH0:	CALL	RCVHEX		; GET ONE BYTE
	RET	C		; TIMEOUT
	LD	(IX+0),A	; STORE IN BUFFER
	INC	IX
	CALL	CRC		; UPDATE CRC
	DEC	B
	JR	NZ,RCVH0
	RET			; CY CLEAR FROM CRC

;================================================
;= SNDMSG - SEND MESSAGE ON NETWORK             =
;================================================
; BC = message buffer address
; Returns: A = 0 on success, 0FFh on error
SNDMSG:	LD	A,(CFGTBL)	; CHECK NETWORK STATUS
	AND	ACTIVE
	JP	Z,NETERR	; NOT ACTIVE
SNDMS0:	PUSH	BC
	POP	IX		; IX = MESSAGE START
	LD	A,(CFGTBL+1)	; OUR SLAVE ID
	LD	(IX+2),A	; ENSURE SID IS CORRECT
	CALL	SNDHDR		; SEND "++" AND 5-BYTE HEADER (IX ADVANCES BY 5)
	OR	A
	JP	NZ,NETERR
	; IX now points past header (original+5)
	; (IX-1) = original+4 = SIZ field
	LD	B,(IX-1)	; SIZ FIELD
	INC	B		; 0 MEANS 1 BYTE (UP TO 256)
	; Send payload bytes starting at (IX+0)
SNDM1:	LD	A,(IX+0)
	INC	IX
	LD	D,A		; SAVE FOR CRC
	CALL	SNDHEX		; SEND BYTE AS HEX
	LD	A,D
	CALL	CRC		; UPDATE CRC
	DEC	B
	JR	NZ,SNDM1
	; Send CRC (low byte first)
	LD	A,L
	CALL	SNDHEX
	LD	A,H
	CALL	SNDHEX
	; Send end-of-message "--"
	LD	A,'-'
	CALL	SENDBY
	LD	A,'-'
	CALL	SENDBY
	XOR	A		; SUCCESS
	RET

;================================================
;= RCVMSG - RECEIVE MESSAGE FROM NETWORK        =
;================================================
; BC = message buffer address
; Returns: A = 0 on success, 0FFh on error
RCVMSG:	LD	A,(CFGTBL)	; CHECK NETWORK STATUS
	AND	ACTIVE
	JP	Z,NETERR	; NOT ACTIVE
RCVMS0:	PUSH	BC
	POP	IX		; IX = MESSAGE BUFFER

	; Wait for "++" sync sequence
RCVSYN:	LD	B,2		; NEED 2 CONSECUTIVE '+' CHARS
RCVSY0:	CALL	RECVBT		; USE START TIMEOUT
	JR	C,RCVERR1	; TIMEOUT
	CP	'+'
	JR	NZ,RCVSYN	; NOT '+', RESET COUNT
	DEC	B
	JR	NZ,RCVSY0	; NEED ONE MORE '+'

	; Got "++", receive 5-byte header (IX advances by 5)
	CALL	RCVHDR
	JR	C,RCVERR1
	; (IX-1) = original+4 = SIZ field
	LD	B,(IX-1)	; SIZ FIELD
	INC	B		; 0 MEANS 1 (UP TO 256)
	; Receive payload bytes starting at (IX+0) = original+5
RCVM1:	CALL	RCVHEX
	JR	C,RCVERR1
	LD	(IX+0),A	; STORE PAYLOAD BYTE
	INC	IX
	CALL	CRC		; UPDATE CRC
	DEC	B
	JR	NZ,RCVM1

	; Receive and verify CRC
	CALL	RCVHEX		; CRC LOW
	JR	C,RCVERR1
	CALL	CRC
	CALL	RCVHEX		; CRC HIGH
	JR	C,RCVERR1
	CALL	CRC
	LD	A,H		; CRC SHOULD BE 0000
	OR	L
	JR	NZ,RCVERR1

	; Verify end-of-message "--"
	CALL	RECVBY
	CP	'-'
	JR	NZ,RCVERR1
	CALL	RECVBY
	CP	'-'
	JR	NZ,RCVERR1
	XOR	A		; SUCCESS
	RET

RCVERR1:
NETERR:	LD	A,0FFH
NTWKER:	RET			; NETWORK ERROR (STUB)

;================================================
;= NTWKIN - NETWORK INITIALIZATION               =
;================================================
; Sends FNC=FFh handshake to server, receives node IDs.
; Uses MSGBUF area as scratch for the init message.
; Returns: A = 0 on success, 0FFh on error
NTWKIN:
	; Build init request at MSGBUF (5-byte header + 0 data bytes)
	LD	IX,MSGBUF
	LD	(IX+0),0	; FMT = 0
	LD	(IX+3),0FFH	; FNC = 255 (INIT REQUEST)
	LD	(IX+4),0	; SIZ = 0
	LD	BC,MSGBUF
	CALL	SNDMS0		; SEND (BYPASS ACTIVE CHECK)
	OR	A
	JR	NZ,NTKERR1	; SEND FAILED

	LD	BC,MSGBUF	; RECEIVE RESPONSE INTO SAME AREA
	CALL	RCVMS0		; RECEIVE (BYPASS ACTIVE CHECK)
	OR	A
	JR	NZ,NTKERR2	; RECEIVE FAILED

	; Response header: DID=our ID, SID=server ID
	LD	A,(MSGBUF+1)	; DID = OUR NODE ID
	LD	B,A
	LD	A,(MSGBUF+2)	; SID = HOST NODE ID
	LD	C,A

	; Store in config table
	LD	A,ACTIVE
	LD	(CFGTBL+0),A	; NETWORK STATUS = ACTIVE
	LD	A,B
	LD	(CFGTBL+1),A	; OUR SLAVE (CLIENT) ID
	LD	A,C
	LD	(HOSTID),A	; SERVER NODE ID
	XOR	A
	LD	(CFGTBL+43),A	; CLEAR SIZ - DISCARD LST OUTPUT
	RET			; A=0 SUCCESS

NTKERR1:			; SEND FAILED
NTKERR2:			; RECV FAILED
	JR	NETERR

;================================================
;= REMAINING SNIOS ENTRY POINTS                  =
;================================================

; NTWKST - Return network status
; Returns: A = status byte (errors cleared after read)
NTWKST:	LD	A,(CFGTBL+0)
	LD	B,A
	AND	NOT (RCVERR+SNDERR)
	LD	(CFGTBL+0),A	; CLEAR ERROR BITS
	LD	A,B		; RETURN ORIGINAL STATUS
	RET

; CNFTBL - Return configuration table address
; Returns: HL = CFGTBL address
CNFTBL:	LD	HL,CFGTBL
	RET

; NTWKBT - Called when CCP is reloaded from disk (warm boot)
NTWKBT:	XOR	A
	RET

; NTWKDN - Network shutdown
; Sends FNC=FEh to notify server
NTWKDN:	LD	IX,MSGBUF
	LD	(IX+0),0	; FMT = 0
	LD	(IX+3),0FEH	; FNC = 254 (SHUTDOWN)
	LD	(IX+4),0	; SIZ = 0
	LD	BC,MSGBUF
	CALL	SNDMS0		; SEND (BYPASS ACTIVE CHECK)
	XOR	A
	RET

SNIOS_END:

	END
