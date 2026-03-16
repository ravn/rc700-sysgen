; RC702 CP/NET SNIOS (Slave Network I/O System)
; DRI binary serial protocol over BIOS READER/PUNCH/READS
;
; Implements the standard DRI CP/NET serial framing:
;   Send: ENQ → ACK → SOH+header+HCS → ACK → STX+data+ETX+CKS+EOT → ACK
;   Recv: ENQ → ACK → SOH+header+HCS → ACK → STX+data+ETX+CKS+EOT → ACK
;
; Character I/O calls BIOS READER/PUNCH/READS through the standard
; jump table at DA00h (56K system). No direct hardware access.
;
; Assembled at ORG 0000h for SPR relocation.
; build_snios.py assembles twice and generates the relocation bitmap.
;

	.Z80

; BIOS entry points (56K system, BIOS base = DA00h)
B$PUNCH	EQU	0DA12H		; BIOS PUNCH (send byte in C via SIO Ch.A)
B$READ	EQU	0DA15H		; BIOS READER (receive byte from SIO Ch.A)
B$RSTA	EQU	0DA4DH		; BIOS READS (reader status, 0=not ready)

; Protocol constants
SOH	EQU	01H		; Start of Header
STX	EQU	02H		; Start of Data
ETX	EQU	03H		; End of Data
EOT	EQU	04H		; End of Transmission
ENQ	EQU	05H		; Enquire
ACK	EQU	06H		; Acknowledge
NAK	EQU	15H		; Negative Acknowledge

; Slave node ID (must match server configuration)
SLAVEID	EQU	01H		; our node on the network

; Retry and timeout parameters
MAXRETRY EQU	10		; max send/receive retries
TMRETRY	EQU	100		; timeout retries per attempt

; Network status byte flags
ACTIVE	EQU	00010000B	; SLAVE LOGGED IN ON NETWORK
RCVERR	EQU	00000010B	; ERROR IN RECEIVED MESSAGE
SNDERR	EQU	00000001B	; UNABLE TO SEND MESSAGE

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
	DB	0FFH		; +1  SLAVE PROCESSOR ID (FFh = accept any DID during init)
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

MSGADR:	DS	2		; MESSAGE ADDRESS (SCRATCH)
RETCNT:	DS	1		; RETRY COUNTER

;================================================
;= CHARACTER I/O WRAPPERS                       =
;= Call BIOS through standard jump table         =
;================================================

; SENDBY - Send byte in A via BIOS PUNCH
SENDBY:	LD	C,A
	JP	B$PUNCH		; BIOS PUNCH WAITS FOR TX READY

; RECVBY - Receive one byte (busy wait, no timeout)
; Returns: A = byte, CY clear
; Preserves: HL, DE (BIOS READER/READS use HL internally)
RECVBY:	PUSH	HL
	PUSH	DE
RCVBY1:	CALL	B$RSTA		; BIOS READER STATUS
	OR	A
	JR	Z,RCVBY1
	CALL	B$READ		; READ BYTE FROM RING BUFFER
	POP	DE
	POP	HL
	OR	A		; CLEAR CARRY
	RET

; RECVBT - Receive one byte with timeout
; Returns: A = byte, CY clear on success; CY set on timeout
RECVBT:	PUSH	DE
	PUSH	HL
	LD	HL,8000H	; TIMEOUT COUNTER
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
RCVWT3:	CALL	B$READ		; READ BYTE FROM RING BUFFER
	POP	HL
	POP	DE
	OR	A		; CLEAR CARRY (SUCCESS)
	RET

;================================================
;= CHECKSUM UTILITIES                           =
;= D = running checksum accumulator             =
;================================================

; NETOUT - Send byte C, accumulate checksum in D
NETOUT:	LD	A,D
	ADD	A,C
	LD	D,A		; UPDATE CHECKSUM
	LD	A,C
	JP	SENDBY		; SEND RAW BYTE

; NETIN - Receive byte, accumulate checksum in D
; Returns: A = byte, D updated, Z flag reflects checksum
; CY set on timeout
NETIN:	CALL	RECVBY		; GET RAW BYTE
	LD	B,A
	ADD	A,D		; ADD TO CHECKSUM
	LD	D,A
	OR	A		; SET Z FLAG FROM CHECKSUM
	LD	A,B		; RESTORE BYTE
	RET

; MSGIN - Receive E bytes into (HL), accumulate checksum
; Returns: CY set on timeout
MSGIN:	CALL	NETIN
	RET	C		; TIMEOUT
	LD	(HL),A
	INC	HL
	DEC	E
	JR	NZ,MSGIN
	RET

; MSGOUT - Send preamble C, then E bytes from (HL), init checksum
; D = 0 on entry (initialized here), accumulates checksum
MSGOUT:	LD	D,0		; INIT CHECKSUM
	CALL	PREOUT		; SEND PREAMBLE (C), UPDATE D
MSOLP:	LD	C,(HL)
	INC	HL
	CALL	NETOUT
	DEC	E
	JR	NZ,MSOLP
	RET

; PREOUT - Send byte C, accumulate checksum in D
PREOUT:	LD	A,D
	ADD	A,C
	LD	D,A		; UPDATE CHECKSUM
	LD	A,C
	JP	SENDBY		; SEND RAW BYTE

;================================================
;= SNDMSG - SEND MESSAGE ON NETWORK             =
;================================================
; BC = message buffer address
; Returns: A = 0 on success, 0FFh on error
SNDMSG:	LD	A,(CFGTBL)	; CHECK NETWORK STATUS
	AND	ACTIVE
	JP	Z,SNDERR1	; NOT ACTIVE
SNDMS0:	LD	H,B
	LD	L,C		; HL = MESSAGE ADDRESS
	LD	(MSGADR),HL
	; Ensure SID is correct
	LD	A,(CFGTBL+1)
	INC	BC
	INC	BC
	LD	(BC),A		; STORE SID

RESEND:	LD	A,MAXRETRY
	LD	(RETCNT),A
SEND:	LD	HL,(MSGADR)
	; Send ENQ
	LD	A,ENQ
	CALL	SENDBY
	; Wait for ACK (with timeout retries)
	LD	D,TMRETRY
ENQRSP:	CALL	RECVBT
	JR	NC,GOTENQ
	DEC	D
	JR	NZ,ENQRSP
	JR	SNDTMO		; TIMEOUT
GOTENQ:	CALL	CHKACK
	; Send SOH + 5 header bytes + HCS
	LD	C,SOH
	LD	E,5
	CALL	MSGOUT		; SEND SOH FMT DID SID FNC SIZ
	; Send header checksum (two's complement)
	XOR	A
	SUB	D
	LD	C,A
	CALL	NETOUT		; SEND HCS
	; Wait for ACK
	CALL	GETACK
	; Send STX + data bytes + ETX + CKS + EOT
	DEC	HL		; BACK TO SIZ FIELD
	LD	E,(HL)
	INC	HL
	INC	E		; 0 MEANS 1 BYTE
	LD	C,STX
	CALL	MSGOUT		; SEND STX + DATA
	LD	C,ETX
	CALL	PREOUT		; SEND ETX (PART OF CHECKSUM)
	; Send data checksum
	XOR	A
	SUB	D
	LD	C,A
	CALL	NETOUT		; SEND CKS
	; Send EOT
	LD	A,EOT
	CALL	SENDBY
	; Wait for final ACK
	CALL	GETACK
	RET			; A=0 SUCCESS (FROM CHKACK)

; GETACK - Wait for ACK, retry on timeout or NAK
GETACK:	CALL	RECVBT
	JR	C,SNDRET	; TIMEOUT → RETRY
CHKACK:	AND	7FH
	SUB	ACK
	RET	Z		; GOT ACK, A=0
; Fall through to retry
SNDRET:	POP	HL		; DISCARD RETURN ADDRESS
	LD	HL,RETCNT
	DEC	(HL)
	JR	NZ,SEND		; RETRY
SNDTMO:	LD	A,SNDERR
	JP	ERRRTN

;================================================
;= RCVMSG - RECEIVE MESSAGE FROM NETWORK        =
;================================================
; BC = message buffer address
; Returns: A = 0 on success, 0FFh on error
RCVMSG:	LD	A,(CFGTBL)	; CHECK NETWORK STATUS
	AND	ACTIVE
	JP	Z,SNDERR1	; NOT ACTIVE
RCVMS0:	LD	H,B
	LD	L,C		; HL = MESSAGE ADDRESS
	LD	(MSGADR),HL

RERCV:	LD	A,MAXRETRY
	LD	(RETCNT),A
RECALL:	CALL	RECV		; ON RETURN = RECEIVE ERROR
	; Retry
	LD	HL,RETCNT
	DEC	(HL)
	JR	NZ,RECALL
RCVTMO:	LD	A,RCVERR
	JP	ERRRTN

RECV:	LD	HL,(MSGADR)
	; Wait for ENQ (with timeout retries)
	LD	D,TMRETRY
RCVFST:	CALL	RECVBT
	JR	NC,GOTFST
	DEC	D
	JR	NZ,RCVFST
	POP	HL		; DISCARD RECALL RETURN
	JR	RCVTMO
GOTFST:	AND	7FH
	CP	ENQ		; ENQUIRE?
	JR	NZ,RECV		; NOT ENQ, KEEP LOOKING

	; Got ENQ, send ACK
	LD	A,ACK
	CALL	SENDBY

	; Receive SOH
	CALL	RECVBY
	RET	C		; TIMEOUT → RECALL RETRY
	AND	7FH
	CP	SOH
	RET	NZ		; NOT SOH → RETRY
	LD	D,A		; INIT HCS WITH SOH

	; Receive 5 header bytes
	LD	E,5
	CALL	MSGIN
	RET	C		; TIMEOUT → RETRY

	; Receive and check HCS
	CALL	NETIN
	RET	C
	JR	NZ,BADCKS	; BAD HEADER CHECKSUM

	; Header OK, send ACK
	CALL	SNDACK

	; Receive STX
	CALL	RECVBY
	RET	C
	AND	7FH
	CP	STX
	RET	NZ		; NOT STX → RETRY
	LD	D,A		; INIT CKS WITH STX

	; Get data length from SIZ field (HL points past header)
	DEC	HL
	LD	E,(HL)
	INC	HL
	INC	E		; 0 MEANS 1 BYTE

	; Receive data bytes
	CALL	MSGIN
	RET	C

	; Receive ETX
	CALL	RECVBY
	RET	C
	AND	7FH
	CP	ETX
	RET	NZ
	ADD	A,D
	LD	D,A		; UPDATE CKS WITH ETX

	; Receive and check data checksum
	CALL	NETIN
	RET	C
	; Receive EOT
	CALL	RECVBY
	RET	C
	AND	7FH
	CP	EOT
	RET	NZ
	; Verify CKS
	LD	A,D
	OR	A
	JR	NZ,BADCKS

	; Message received OK
	POP	HL		; DISCARD RECALL RETURN
	; Check DID matches our node
	LD	HL,(MSGADR)
	INC	HL		; POINT TO DID
	LD	A,(CFGTBL+1)
	INC	A		; FF → 00 (UNINITIALIZED = ACCEPT ALL)
	JR	Z,SNDACK	; ACCEPT ANY DID DURING INIT
	DEC	A		; RESTORE VALUE
	SUB	(HL)
	JR	Z,SNDACK	; DID MATCHES, A=0
	LD	A,0FFH		; BAD DID
SNDACK:	PUSH	AF		; SAVE RETURN CODE
	LD	A,ACK
	CALL	SENDBY
	POP	AF		; RESTORE RETURN CODE
	RET

BADCKS:	LD	A,NAK
	JP	SENDBY		; SEND NAK AND RETURN TO RETRY

;================================================
;= ERROR HANDLING                                =
;================================================
ERRRTN:	LD	HL,CFGTBL
	OR	(HL)
	LD	(HL),A		; SET ERROR BIT IN STATUS
	CALL	NTWKER		; DEVICE RE-INIT IF NEEDED
SNDERR1:
	LD	A,0FFH
	RET

;================================================
;= NTWKIN - NETWORK INITIALIZATION               =
;================================================
; CP/NET 1.2: no handshake needed.  Just drain stale bytes,
; set slave ID and ACTIVE flag.  Login is handled by NDOS (FNC=64).
; Returns: A = 0 on success
NTWKIN:
	; Drain any bytes buffered during boot (e.g. null_modem init zeros).
	; The C-BIOS ring buffer captures all received bytes from SIO init;
	; these must be consumed before the protocol exchange starts.
NTWKDR:	CALL	B$RSTA		; reader status
	OR	A
	JR	Z,NTWKD1	; buffer empty
	CALL	B$READ		; consume and discard
	JR	NTWKDR
NTWKD1:
	; Set slave ID (must match server expectation)
	LD	A,SLAVEID
	LD	(CFGTBL+1),A
	; Mark network active
	LD	A,ACTIVE
	LD	(CFGTBL+0),A
	XOR	A
	LD	(CFGTBL+43),A	; CLEAR SIZ - DISCARD LST OUTPUT
	RET			; A=0 SUCCESS

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

; NTWKER - Network error handler (device re-init if needed)
NTWKER:	RET

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
