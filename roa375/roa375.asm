;************************************************************************
;*									*
;* AUTOLOAD-FILE FOR THE RC702 MICROCOMPUTER				*
;*  									*
;* REGNECENTRALEN 1982							*
;*									*
;* Reverse engineered in the style of ROB358.MAC by tran@ravnand.dk	*
;* 2026 with the help of Claude Opus 4.6.				*
;************************************************************************
;
; NOTE:  It is assumed for now that a modern assembler is used that accepts
; very long label names.  This will most likely be remidied when the work
; is finished.

.Z80

;========================================================================
; HARDWARE CONSTANT DEFINITIONS - see https://www.jbox.dk/rc702/manuals.shtm for PDFs
; (cf. rob358.mac for RC700/RC703 equivalents)
;========================================================================

; System ports (see hardware manual page 15)
; Note: RC702 uses incomplete address decoding — ports are mirrored in groups of 4:
;   0x14-0x17 = SW1, 0x18-0x1B = RAMEN, 0x1C-0x1F = BIB
; The RC703 likely refines this; rob358.mac uses 0x19 for RAMEN instead of 0x18.
SW1	EQU	014H		; Mini/maxi switch (read), mini floppy motor (write)
RAMEN	EQU	018H		; PROM disable: write disables PROM0+PROM1, enables RAM
BIB	EQU	01CH		; Beeper/sound port

; Z80 PIO ports -
KEYDAT	EQU	010H		; PIO Port A data (keyboard)
KEYCON	EQU	012H		; PIO Port A control
PIOBDT	EQU	011H		; PIO Port B data
PIOBCN	EQU	013H		; PIO Port B control

; AM9517A DMA controller ports
CH1ADR	EQU	0F2H		; DMA Channel 1 address (floppy)
WCREG1	EQU	0F3H		; DMA Channel 1 word count
CH2ADR	EQU	0F4H		; DMA Channel 2 address (display)
WCREG2	EQU	0F5H		; DMA Channel 2 word count
CH3ADR	EQU	0F6H		; DMA Channel 3 address (display)
WCREG3	EQU	0F7H		; DMA Channel 3 word count
DMACOM	EQU	0F8H		; DMA command register
SMSK	EQU	0FAH		; DMA single mask register
DMAMOD	EQU	0FBH		; DMA mode register
CLBP	EQU	0FCH		; DMA clear byte pointer

; DMA command/mode values
COMV	EQU	020H		; DMA command value
MODE1	EQU	045H		; DMA mode: disk to memory CH1 (single)
CLR1	EQU	001H		; Clear CH1 mask (enable)
SET1	EQU	005H		; Set CH1 mask (disable)

; Z80 CTC ports -
CTCCH0	EQU	00CH		; CTC Channel 0
CTCCH1	EQU	00DH		; CTC Channel 1
CTCCH2	EQU	00EH		; CTC Channel 2 (display interrupt)
CTCCH3	EQU	00FH		; CTC Channel 3 (floppy interrupt)
CTCMOD	EQU	0D7H		; CTC mode: interrupt after one count
CTCCNT	EQU	001H		; CTC count value

; Intel 8275 CRT controller ports
CRTDAT	EQU	000H		; CRT data register
CRTCOM	EQU	001H		; CRT command/control register

; CRT command values
CRTRES	EQU	000H		; Reset CRT controller
LCURS	EQU	080H		; Load cursor command
PRECC	EQU	0E0H		; Preset counters
STDISP	EQU	023H		; Start display

; CRT parameters (RC702-specific)
PARAM1	EQU	04FH		; 80 chars/row
PARAM2	EQU	098H		; 25 rows/frame

; NEC uPD765 FDC ports
FDC	EQU	004H		; FDC main status register
FDD	EQU	005H		; FDC data register

; Directory and disk constants
ATTOFF	EQU	007H		; File attribute offset from filename start
SECSZ0	EQU	080H		; Base sector size in bytes (N=0, 128 bytes)

; Memory layout constants
FLOPPYDATA EQU	00000H		; Boot sector load address in RAM
COMALBOOT EQU	01000H		; ID-COMAL bootstrap entry point
PROM1 EQU	02000H		; PROM1 address: optional line program ROM
DIROFF	EQU	0B60H		; Directory area offset from boot base
DIREND	EQU	0D00H		; Directory end boundary (high byte)
DSPCHRS	EQU	00780H		; Visible display characters (80*24=1920)


;========================================================================
; BOOT CODE - Executes from ROM at 0x0000-0x0066, relocates the payload
; to 0x7000, and executes it
;========================================================================

	ORG	0000H

BEGIN:
	DI				; Disable interrupts
	LD	SP,TOPSTACK		; Set stack pointer
	LD	HL,MOVADR		; Point to relocatable code start

; Scan for actual code start (skip zeros)
SCANLP:
	LD	A,(HL)			; Get byte
	OR	A			; Zero?
	INC	HL
	JP	Z,SCANLP		; Keep scanning
	CP	0FFH			; Found 0xFF marker?
	JP	Z,SKIP
	DEC	HL			; Back up to non-zero
SKIP:
	EX	DE,HL			; DE = source address

; Copy 0x798 bytes from ROM to RAM at 0x7000
	LD	HL,PAYLOAD		; Destination
	LD	BC,PAYLOADLEN		; Count = 1944 bytes
COPYLP:
	LD	A,(DE)			; Get source
	LD	(HL),A			; Store
	INC	DE
	INC	HL
	DEC	BC
	LD	A,C
	OR	B
	JP	NZ,COPYLP
	JP	INIT			; Jump to relocated init

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
	IN	A,(SW1)		; Read switch settings
	AND	10000000b		; Mask mini/maxi bit
	ADD	A,B
	LD	(DISKBITS),A

	XOR	A			; A := 0
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

	EI				; Enable interrupts
	LD	A,001H
	OUT	(SW1),A			; Start mini floppy motor (A=1, cf. rob358 FDSTAR)
	LD	A,005H
	LD	(REPTIM),A
	JP	FLDSK1

; FIXME NMIRETURN must be precise
	RETN				; NMI-RETURN

MOVADR:
	DB	0FFH			; 0xFF marker byte indicating start of code to relocate
					; This is most likely a hack to ensure that the label is given
					; a non-relocated address (we are at a phase boundary)
					; regardless of the assembler used

;========================================================================
; RELOCATED CODE SECTION - Loaded to 0x7000, executed from there
;========================================================================

; This code gets copied from ROM offset 0x0068 to RAM at 0x7000
; From here on, all addresses are runtime addresses (0x7000+)

	phase	07000H
PAYLOAD:

;------------------------------------------------------------------------
; Interrupt vectors and error handlers at 0x7000
;------------------------------------------------------------------------

; Error message display and halt routines

NOSYSTEMFILESERR:
	LD	BC,DSPSTR		; Display buffer
	LD	DE,NOSYSTEMFILESTXT	;
	LD	HL,NOSYSTEMFILESTXTLEN	; Length
	CALL	MOVCPY			; Copy to screen
	JP	ERRHLT			; Halt with error displayed

NOKATALOGERR:
	LD	BC,DSPSTR
	LD	DE,NOKATALOGMSG
	LD	HL,NOKATALOGMSGLEN
	CALL	MOVCPY
	JP	ERRHLT

NODISKLINEPROGERR:
	LD	BC,DSPSTR
	LD	DE,NODISKLINEPROGMSG
	LD	HL,NODISKLINEPROGMSGLEN
	CALL	MOVCPY
	JP	ERRHLT

;------------------------------------------------------------------------
; Utility routines
;------------------------------------------------------------------------

; Check for the pre-CP/M diskette catalogue.  Z=yes, NZ=no
; Look for four character file name in HL+1..HL+5 and, if
;
CHKSYSM:
	PUSH	HL
	INC	HL
	EX	DE,HL
	LD	BC,FNAME1
	LD	HL,FNAME1LEN
	CALL	COMSTR
	POP	HL
	JP	Z,SUB_4F
	RET

CHKSYSC:
	PUSH	HL
	INC	HL
	EX	DE,HL
	LD	BC,FNAME2
	LD	HL,FNAME2LEN
	CALL	COMSTR
	POP	HL
	JP	Z,SUB_4F
	RET

; The bit value 7 positions after the first character in the filename
; must be on the form xx010003.  Probably a file attribute check.
SUB_4F:
	PUSH	HL
	INC	HL
	LD	DE,ATTOFF
	ADD	HL,DE
	LD	A,(HL)
	AND	00111111b
	CP	013H
	POP	HL
	RET

; Memory compare routine of [BC] to [DE] for L characters, Z if equal, NZ if not equal
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

; Memory copy L characters from [DE] to [BC] routine
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
RC700TXTLEN	EQU	$ - RC700TXT

RC702TXT:
	DB	' RC702'
RC702TXTLEN	EQU	$ - RC702TXT + 1	; plus one in prom not needed

NOSYSTEMFILESTXT:
	DB	' **NO SYSTEM FILES** '
NOSYSTEMFILESTXTLEN	EQU	$ - NOSYSTEMFILESTXT - 1

NODISKLINEPROGMSG:
	DB	' **NO DISKETTE NOR LINEPROG** '
NODISKLINEPROGMSGLEN	EQU	$ - NODISKLINEPROGMSG - 1

NOKATALOGMSG:
	DB	' **NO KATALOG** '
NOKATALOGMSGLEN		EQU	$ - NOKATALOGMSG - 1

; [Claude Opus 4.6] NULLB: Purpose unclear.  The bytes 02H, C3H, C8H do not
; form a valid Z80 instruction sequence at this location.  C3H is the JP
; opcode and C8H is the RET Z opcode, but 02H preceding them makes no sense
; as code.  Possibly a data fragment, a jump table entry, or padding left
; over from the original build.  Needs verification against the original ROM.
NULLB:	DB	002H
	DB	0C3H
	DB	0C8H			; Control byte

FNAME1:	DB	'SYSM '			; System file name
FNAME1LEN 	EQU 	$ - FNAME1 - 1

FNAME2:	DB	'SYSC '
FNAME2LEN 	EQU 	$ - FNAME2 - 1

	JP	DISINT

;------------------------------------------------------------------------
; INITIALIZATION ENTRY POINT at 070D0H
; Hardware and display initialization
;------------------------------------------------------------------------

TOPSTACK	EQU	0BFFFH

INIT:
	LD	SP,TOPSTACK		; Reset stack
	LD	A,INTVEC/0100H		; Interrupt vector high byte
	LD	I,A			; Set interrupt vector register
	IM	2			; Interrupt mode 2

; Initialize PIO for keyboard
	LD	C,0FFH
	LD	B,001H
	CALL	DELAY				; Wait routine

	LD	A,099H
	CALL	PIOINT			; PIO init
	LD	HL,PREINIT
	JP	(HL)

; PIO initialization
; https://www.jbox.dk/rc702/hardware/zilog-um0081.pdf page 188-189
PIOINT:
	PUSH	AF
	; -- set interrupt vectors, page 188
	LD	A,002H			; Interrupt vector 2 (address = base + 002H)
	OUT	(KEYCON),A		; Port A interrupt vector (keyboard)
	LD	A,004H			; Interrupt vector 4 (address = base + 004H)
	OUT	(PIOBCN),A		; Port B interrupt vector
	; -- set operating modes, page 189
	LD	A,01001111b		; 01=input mode, 001111=I/O select follows
	OUT	(KEYCON),A		; Port A: input mode (keyboard reads)
	LD	A,00001111b		; 00=output mode, 001111=I/O select follows
	OUT	(PIOBCN),A		; Port B: output mode
	; -- set interrupt control words, page 190
	LD	A,10000011b		; 1=enable int, 0=OR mode, 0=low active, 0=no mask, 011=mask follows
	OUT	(KEYCON),A		; Port A: enable interrupts, OR-mode, low active
	OUT	(PIOBCN),A		; Port B: same interrupt control word
	JP	CTCINT

; CTC initialization - Counter/Timer Channels
;  CHANNEL0: NOT USED DURING BOOTSTRAP
;  CHANNEL1: NOT USED DURING BOOTSTRAP
;  CHANNEL2: INTERRUPT INPUT FOR DISPALY
;  CHANNEL3: INTERRUPT INPUT FOR FLOPPY CONTROLLER
;
; https://www.jbox.dk/rc702/hardware/zilog-um0081.pdf page 18-23
CTCINT:
	; -- Channel 0 --
	; -- set interrupt vector base (bit0=0 means interrupt vector word)
	LD	A,00001000b		; Interrupt vector 8 (bit0=0: vector word)
	OUT	(CTCCH0),A		; Ch0 sets base vector for all 4 channels (8,A,C,E)
	POP	AF
	; -- 47H = counter mode, falling edge, time constant follows, reset
	LD	A,01000110b
	OR	01000001b		; Result: 01000111b - counter, prescale=16, falling, TC follows, reset
	OUT	(CTCCH0),A		; Ch0: configure as counter with reset
	LD	A,020H			; Time constant = 32
	OUT	(CTCCH0),A		; Ch0: load time constant (counts 32 edges before interrupt)

	; -- Channel 1 --
	LD	A,01000110b
	OR	01000001b		; Result: 01000111b - same config as Ch0
	OUT	(CTCCH1),A		; Ch1: configure as counter with reset
	LD	A,020H			; Time constant = 32
	OUT	(CTCCH1),A		; Ch1: load time constant

	; -- Channel 2 (Display interrupt) --
	LD	A,11010111b		; Int enable, counter, prescale=16, falling, TC follows, reset
	OUT	(CTCCH2),A		; Ch2: configure for display interrupt
	LD	A,001H			; Time constant = 1 (interrupt on every edge)
	OUT	(CTCCH2),A		; Ch2: load time constant

	; -- Channel 3 (Floppy interrupt) --
	LD	A,11010111b		; Int enable, counter, prescale=16, falling, TC follows, reset
	OUT	(CTCCH3),A		; Ch3: configure for floppy interrupt
	LD	A,001H			; Time constant = 1 (interrupt on every edge)
	OUT	(CTCCH3),A		; Ch3: load time constant
	JP	DMAINT

; DMA initialization
DMAINT:
	LD	A,00100000b		; Fixed priority, normal timing, late write, DREQ high, DACK low
	OUT	(DMACOM),A		; Set DMA command register

	LD	A,11000000b		; Cascade mode, channel 0
	OUT	(DMAMOD),A		; Ch0: cascade mode (no DMA, passes through to slave)
	LD	A,000H			; Channel 0, bit2=0 -> unmask (enable)
	OUT	(SMSK),A		; Unmask (enable) DMA channel 0

	LD	A,01001010b		; Demand mode, addr increment, no auto-init, write, channel 2
	OUT	(DMAMOD),A		; Ch2: demand write mode (CRT display)
	LD	A,01001011b		; Demand mode, addr increment, no auto-init, write, channel 3
	OUT	(DMAMOD),A		; Ch3: demand write mode (CRT display)
	JP	CRTINT

; CRT Controller (8275) initialization
; https://www.jbox.dk/rc702/hardware/intel-8275.pdf - page 8-238 -
CRTINT:
	LD	A,000H			; Reset command (bits 7-5 = 000)
	OUT	(CRTCOM),A		; Reset CRT controller, expect 4 parameter bytes

	; -- 8275 screen format parameters (4 bytes after reset command)
	LD	A,04FH			; Param 1: S=0 (not spaced), H=79 -> 80 chars/row
	OUT	(CRTDAT),A		; Screen format: 80 characters per row
	LD	A,10011000b		; Param 2: V=2 (vretrace count), R=24 -> 25 rows/frame
	OUT	(CRTDAT),A		; Vertical retrace: 2 scan lines, 25 rows
	LD	A,9AH			; Param 3: L=9 (underline position), U=10 (lines/char row)
	OUT	(CRTDAT),A		; Underline on scan line 9, 10 scan lines per character
	LD	A,05DH			; Param 4: F=0 (non-offset), M=1 (transparent), C=01 (blink underline), Z=28
	OUT	(CRTDAT),A		; Field attr non-transparent, blinking underline cursor, 28 hretrace chars

	LD	A,10000000b		; Load cursor command (bits 7-5 = 100)
	OUT	(CRTCOM),A		; Load cursor position, expect 2 data bytes
	XOR	A			; A := 0
	OUT	(CRTDAT),A		; Cursor column = 0
	OUT	(CRTDAT),A		; Cursor row = 0

	LD	A,11100000b		; Preset counters command (bits 7-5 = 111)
	OUT	(CRTCOM),A		; Preset counters, CRT ready (but display not started)
	; -- note display is ready but not actually started.  Happens at end of initialization.
	JP	FDCINT

;------------------------------------------------------------------------
; Floppy disk controller (uPD765) initialization and status check
;------------------------------------------------------------------------

FDCDATA:				; FDC SPECIFY command buffer (cf. rob358 FDCINI)
	DB	003H
	DB	003H
	DB	04FH
	DB	020H
FDCINT:
	LD	C,0FFH
	LD	B,001H
	CALL	DELAY		; Wait routine

	IN	A,(FDC)		; FDC status
	AND	00011111b
	JP	NZ,FDCINT

	LD	HL,FDCDATA
	LD	B,(HL)
FDCWAITNEXT:
	INC	HL
FDCWAIT:
	IN	A,(FDC)
	AND	11000000b
	CP	10000000b
	JP	NZ,FDCWAIT

	LD	A,(HL)
	OUT	(FDD),A		; Write SPECIFY command byte to FDC data register
	DEC	B
	JP	NZ,FDCWAITNEXT
	JP	CLRSCR

;------------------------------------------------------------------------
; Display screen clear and message display
;------------------------------------------------------------------------

; [Claude Opus 4.6] CLRSCR clears 8 rows (D=0..7) of 208 bytes each (E=0..0CFH).
; The 8275 CRT controller uses an internal row buffer wider than the visible
; 80-column display.  Each row occupies 208 (0xD0) bytes in the display buffer,
; giving 8 * 208 = 1664 bytes cleared total.  The remaining buffer space
; (up to 2000 bytes) is left untouched.  After clearing, DISPMG writes the
; " RC700" identification string at the start of the buffer.
CLRSCR:
	LD	HL,00000H
	EX	DE,HL			; D=line (0..7), E=char (0..0CFH=207)
CLRLP1:
	LD	HL,DSPSTR		; Display buffer
	ADD	HL,DE
	LD	A,' '
	LD	(HL),A
	LD	A,E
	CP	0CFH			; End of row (208 bytes per row)?
	JP	Z,NEXTLN
	INC	DE
	JP	CLRLP1

NEXTLN:
	LD	A,D
	CP	007H			; Done 8 rows?
	JP	Z,DISPMG
	INC	DE
	JP	CLRLP1

DISPMG:
	LD	DE,RC700TXT		; Message pointer
	LD	HL,RC700TXTLEN		; Length
	LD	BC,DSPSTR		; Display buffer
	CALL	MOVCPY

; Zero out work area, possibly CRT DMA parameters
	LD	HL,00000H
	LD	(UNUSED2),HL
	LD	(UNUSED5),HL
	LD	(UNUSED11),HL
	LD	(UNUSED10),HL
	LD	(UNUSED9),HL
	LD	(UNUSED4),HL
	LD	(UNUSED8),HL
	LD	(SCROLLOFSET),HL

	LD	HL,DSPCHRS
	LD	(UNUSED6),HL

	LD	A,000H
	LD	(UNUSED1),A
	LD	(UNUSED3),A
	LD	(UNUSED7),A
	LD	(UNUSED12),A

	LD	A,00100011b		; Start display cmd (001), B=0 (0 clocks between DMA), E=3 (8 DMA cycles/burst)
	OUT	(CRTCOM),A		; Start display: burst mode with 8 DMA cycles per burst
	RET

;------------------------------------------------------------------------
; MAIN BOOT SEQUENCE - Try hard disk, then floppy
;------------------------------------------------------------------------
;
; [Claude Opus 4.6] RC702 PROM0 (ROA375) boot sequence:
;
; Phase 1 — ROM execution (0x0000-0x0066):
;   BEGIN:    Disable interrupts, set stack to TOPSTACK (0xBFFF).
;             Copy payload from ROM to RAM at 0x7000, jump to INIT.
;   INIT:     Set up Z80 interrupt mode 2 with vector table at INTVEC.
;             Initialize PIO (keyboard), CTC (timers), DMA, CRT (display).
;             Clear screen, display " RC700" identification.
;   PREINIT:  Read SW1 port to detect mini/maxi floppy.  Zero work area.
;             Start mini floppy motor via OUT (SW1).  Jump to FLDSK1.
;
; Phase 2 — Floppy boot (from RAM at 0x7000+):
;   FLDSK1:   Sense drive status, recalibrate.  On failure -> CHECKPROM1.
;   FLDSK3:   Call BOOT to auto-detect density on both heads.
;             Disable PROMs via OUT (RAMEN) — full RAM now available.
;   BOOT4:    Read track 0 data.  Loop until cylinder advances past 0.
;   BOOT2:    Set DSKTYP=1 (floppy), call BOOT7 to verify catalogue.
;             Then jump to FLBOOT for final boot.
;
; Phase 3 — Catalogue verification (BOOT7):
;   Check for "RC700" signature (A=0AH) at address 0x0000.
;     Found -> BOOT8: search 32-byte directory entries at DIROFF for
;              SYSM and SYSC files.  Error if not found -> NOSYSTEMFILESERR.
;   Check for "RC702" signature (A=0BH) at address 0x0000.
;     Found -> BOOT9: jump via vector at address 0 (new-style catalogue).
;   Neither found -> NOKATALOGERR.
;
; Phase 4 — FLBOOT (final floppy boot):
;   Combine mini/maxi bit with DSKTYP.  Auto-detect density again.
;   Read track 0 side 0 to address 0x0000.
;   Jump to COMALBOOT (0x1000) for ID-COMAL bootstrap.
;
; Fallback — CHECKPROM1:
;   Reached when all disk boot attempts fail.  Checks if optional PROM1
;   is installed at 0x2000 with "RC702" signature.  If present, jumps
;   via vector at 0x2000 (line program takes over).
;   If absent -> NODISKLINEPROGERR (system halts with error message).

BOOT:
	XOR	A			; A := 0
	LD	(CURCYL),A
	INC	A
	LD	(CURHED),A
	LD	(CURREC),A

; Try hard disk boot
	CALL	DSKAUTO
	JP	C,BOOT1

	LD	HL,DISKBITS		; Status flag, bit 7 = mini disk, bit 1 now set.
	LD	A,002H
	OR	(HL)
	LD	(HL),A

BOOT1:
	LD	HL,CURHED
	DEC	(HL)
	CALL	DSKAUTO
	RET	NC

	LD	A,0FBH
	JP	CHECKPROM1

;------------------------------------------------------------------------
; Floppy disk boot sequence
;------------------------------------------------------------------------

FLDSK1:
	LD	B,001H
	LD	C,0FFH
	CALL	DELAY				; Wait routine
	CALL	SNSDRV			; Sense drive status
	LD	A,(FDCRES)
	AND	00100011b
	LD	C,A
	LD	A,(DRVSEL)
	ADD	A,00100000b
	CP	C
	JP	NZ,CHECKPROM1
	CALL	RECALV			; Recalibrate and verify
	JP	C,CHECKPROM1
	JP	Z,FLDSK3
	JP	CHECKPROM1

FLDSK3:
	CALL	BOOT
	LD	A,001H			; Any value disables PROMs
	OUT	(RAMEN),A		; Disable PROM0+PROM1, enable full RAM
BOOT4:
	LD	HL,(TRBYT)
	CALL	RDTRK0
	LD	A,(CURCYL)
	OR	A
	JP	NZ,BOOT2
	CALL	DSKAUTO
	JP	BOOT4

BOOT2:
	LD	A,001H
	LD	(DSKTYP),A
	CALL	BOOT7
	JP	FLBOOT


;------------------------------------------------------------------------
; Additional boot helper routines
;------------------------------------------------------------------------

; BOOT7 — Check disk signature and dispatch to appropriate boot path.
;
; Two signature checks via ISRC70X (see HL accumulation trick there):
;   1st: A=0AH, HL=0x0000 → checks offset 0x0002 for " RC700" → BOOT8
;   2nd: A=0BH, HL=0x0006 (carried over) → checks offset 0x0008 for " RC702" → BOOT9
; Note: HL is NOT reloaded between calls — this is intentional.
BOOT7:
	LD	A,00AH
	LD	HL,FLOPPYDATA		; HL = 0x0000 (only set once!)
	CALL	ISRC70X			; check 0x0002 for " RC700"
	JP	Z,BOOT8			; → directory search for SYSM/SYSC
	LD	A,00BH			; HL = 0x0006 (carried from ISRC70X)
	CALL	ISRC70X			; check 0x0008 for " RC702"
	JP	Z,BOOT9			; → jump via vector at 0x0000
	JP	NOKATALOGERR

; Now look for system files
BOOT9:
	LD	HL,(FLOPPYDATA)
	JP	(HL)

BOOT8:
	LD	HL,FLOPPYDATA
	LD	DE,DIROFF
	ADD	HL, DE
CHKSYSMC:
; Looks like this examines 32 byte directory entries
; (until H exceeds 0DH-ish), looking for
; one where the first byte is not zero (system file?)
; This one must be SYSM and the next SYSC.  Returns if
; found, goes directly to ' ** NO SYSTEM FILES FOUND **' error
; screen otherwise.

	LD	DE, 20H
	ADD	HL, DE
	LD	BC,DIREND
	LD	A,B
	CP	H
	JP	C,NOSYSTEMFILESERR
	LD	A,(HL)
	OR	A
	JP	Z, CHKSYSMC
	CALL	CHKSYSM
	JP	NZ, NOSYSTEMFILESERR
	LD	DE, 20h
	ADD	HL, DE
	LD	A, (HL)
	OR	A
	JP	Z, NOSYSTEMFILESERR
	CALL	CHKSYSC
	JP	NZ, NOSYSTEMFILESERR
	RET

; ISRC70X — Check for " RC700" or " RC702" signature in disk data.
;
; Entry: HL = base pointer (FLOPPYDATA on first call, accumulated on second)
;        A  = 0x0A to check " RC700", 0x0B to check " RC702"
; Exit:  Z  = match, NZ = no match
;
; HL accumulation trick (size optimization, saves 3 bytes):
;   The function adds 2 to HL then loads HL=6 as the COMSTR length.
;   BOOT7 calls ISRC70X twice without reloading HL between calls.
;
;   First call:  HL = FLOPPYDATA (0x0000) → +2 → checks offset 0x0002
;                After failed COMSTR, HL = 0x0006 (from LD HL,6).
;                COMSTR returns at first mismatch before DEC L, so L=6.
;
;   Second call: HL = 0x0006 (carried over) → +2 → checks offset 0x0008
;                This is where " RC702" (CP/M+COMAL80 format) resides.
;
; Disk data layout at 0x0000:
;   Old format (ID-COMAL):  [JP vector][" RC700"]...     signature at 0x0002
;   New format (CP/M):      [JP vector][config  ][" RC702"]...  signature at 0x0008
ISRC70X:
	LD	DE, 2
	ADD	HL, DE
	EX	DE, HL
	LD 	BC, RC700TXT
	LD	HL, 6
	CP	0AH
	JP	Z,ISRC70X2
	LD	BC, RC702TXT
	LD	HL, 6
ISRC70X2:
	CALL	COMSTR
	RET

; [Claude Opus 4.6] PROM0 at 0x0000 is this ROA375 autoload PROM.  PROM1
; at 0x2000 is an optional second ROM (see hardware manual page 17).
; When installed, PROM1 contains a "lineprog" (linjeprogram) — a Danish
; term for the communication/network program used on RC700-series machines.
;
; CHECKPROM1 is the last-resort fallback when all disk boot attempts fail.
; It checks for an "RC702" signature at 0x2002 (skipping a 2-byte jump
; vector).  If found, PROM1 is present and the system jumps via the vector
; at 0x2000, handing control to the line program.  If not found, no boot
; medium exists and the system halts with "NO DISKETTE NOR LINEPROG".
CHECKPROM1:
	LD	A, 0BH
	LD	HL,PROM1
	CALL	ISRC70X			; Check for "RC702" at 0x2002
	JP	Z, PROM1PRESENT
	JP	NODISKLINEPROGERR

PROM1PRESENT:
	LD	HL,(PROM1)		; Load jump vector from PROM1
	JP	(HL)			; Jump to line program

;------------------------------------------------------------------------
; Disk format/geometry tables
;------------------------------------------------------------------------

; [Claude Opus 4.6] Format parameter tables, indexed by FMTLKP.
; Each table has 4-byte entries per density level (N=0,1,2), with 2 bytes
; per side: (EOT, GAP3).  FMTLKP computes offset = N*4 + side*2.
;
; GAP3 is the inter-sector gap length — the number of gap bytes (4EH in
; MFM, FFH in FM) between the end of one sector's data field and the next
; sector's ID address mark.  The FDC needs this value during read/write to
; know how much gap to skip.  The values here scale with sector size:
;   07H (7)  for N=0 (128-byte sectors, FM single density)
;   0EH (14) for N=1 (256-byte sectors, MFM double density)
;   1BH (27) for N=2 (512-byte sectors, MFM double density)
; Typical uPD765 systems use GAP3 values of 27-42 for 512-byte sectors;
; the value 1BH=27 here is at the low end of that range.
;
; MAXIFMT (8" / maxi, selected when DISKBITS bit7=0=maxi, max cyl=76):
;   N=0 (128B): side0=(1AH=26, 07H)  side1=(34H=52, 07H)
;   N=1 (256B): side0=(0FH=15, 0EH)  side1=(1AH=26, 0EH)
;   N=2 (512B): side0=(08H=8,  1BH)  side1=(0FH=15, 1BH)
;   N=3 (unused):                     (00H, 00H, 08H, 35H)
;
; MINIFMT (5.25" / mini, selected when DISKBITS bit7=1=mini, max cyl=35):
;   N=0 (128B): side0=(10H=16, 07H)  side1=(20H=32, 07H)
;   N=1 (256B): side0=(09H=9,  0EH)  side1=(10H=16, 0EH)
;   N=2 (512B): side0=(05H=5,  1BH)  side1=(09H=9,  1BH)
;   N=3 (unused):                     (00H, 00H, 05H, 35H)
MAXIFMT:
	DB	01AH,07H,34H,07H	; N=0: side0 EOT=26,GAP3=7  side1 EOT=52,GAP3=7
	DB	0FH,0EH,1AH,0EH	; N=1: side0 EOT=15,GAP3=14 side1 EOT=26,GAP3=14
	DB	08H,1BH,0FH,1BH	; N=2: side0 EOT=8, GAP3=27 side1 EOT=15,GAP3=27
	DB	00H,00H,08H,35H	; N=3: (unused)
MINIFMT:
	DB	10H,07H,20H,07H	; N=0: side0 EOT=16,GAP3=7  side1 EOT=32,GAP3=7
	DB	09H,0EH,10H,0EH	; N=1: side0 EOT=9, GAP3=14 side1 EOT=16,GAP3=14
	DB	05H,1BH,09H,1BH	; N=2: side0 EOT=5, GAP3=27 side1 EOT=9, GAP3=27
	DB	00H,00H,05H,35H	; N=3: (unused)

; Now pad so the interrupt vector can be correctly placed on a page boundary
	REPT	(1+($/100H))*100H - $
	DB	00H
	ENDM

;------------------------------------------------------------------------
; Interrupt vector table (16 entries).
; *Must* be on a page boundary (7300 for instance)
;------------------------------------------------------------------------

INTVEC:
	DW	DUMINT		; +0:  Dummy
	DW	DUMINT		; +2:  PIO Port A (keyboard) - not used during boot
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
; [Claude Opus 4.6] DISKBITS bitfield definition:
;   bit 7:   Diskette size (1=mini/5.25", 0=maxi/8"). Set from SW1 dip switch.
;   bit 4-2: Density/record-length (N value shifted left 2). Set by DSKAUTO/DSKDET.
;            Extracted by SETFMT: AND 00011100b, then RRA twice -> N in bits 2-0.
;   bit 1:   Dual-sided flag. Set after successful DSKAUTO on head 1.
;   bit 0:   Side select (0=side 0, 1=side 1). Toggled during DSKAUTO retries.
DISKBITS:
	DB	00H		; Status flag (see bitfield above)
	DB	00H

;------------------------------------------------------------------------
; System call and interrupt handlers
;------------------------------------------------------------------------
; [Claude Opus 4.6] SYSCALL is the PROM's disk I/O entry point, called by
; the CP/M BIOS (or other boot code) to read disk tracks.  It saves the
; caller's stack pointer so it can return via RETSP, which restores SP
; and returns — allowing error paths (ERRDSP) to also unwind cleanly.
; Entry: HL = memory destination address
;        B  = bit7: head select, bits 6-0: cylinder number
;        C  = bit7: record/sector number (bits 6-0)
SYSCALL:
	; B=7 bit is head, 0..6 bit Cylinder; C=7 bit record
	LD	(MEMADR),HL		; store HL in MEMADR
	LD	HL,00000H
	ADD	HL,SP
	LD	(SPSAV),HL		; save SP in SPSAV and DE - unclear why it is needed
	PUSH	BC
	EX	DE,HL
	LD	A,C
	AND	01111111b
	LD	(CURREC),A
	LD	A,B
	AND	01111111b
	LD	(CURCYL),A
	CALL	Z,DSKAUTO
	LD	A,B
	AND	10000000b
	JP	Z,SYSCALL1
	LD	A,001H
SYSCALL1:
	LD	(CURHED),A
	CALL	RDTRK0
	POP	BC
	PUSH	AF
	LD	A,B
	AND	01111111b		; if cylinder not zero, return
	JP	NZ,SYSRET
	LD	A,001H			; otherwise done cylinder 0, try cylinder 1
	LD	(CURCYL),A
	CALL	DSKAUTO
SYSRET:
	POP	AF
	XOR	A			; A := 0
RETSP:
	LD	HL,(SPSAV)		; restore stack pointer, and return
	LD	SP,HL
	RET

;------------------------------------------------------------------------
; Display interrupt handler (DISINT)
; Called via HDINT on every CTC Ch2 interrupt (triggered by 8275 vertical retrace).
;
; [Claude Opus 4.6] Implements circular-buffer hardware scrolling using two
; DMA channels.  The 2000-byte display buffer at DSPSTR is treated as a
; circular buffer.  SCROLLOFSET (S) indicates where the visible screen starts.
;
; Two DMA channels split the scrolled view:
;   Ch2 (higher priority): transfers from DSPSTR+S to end of buffer
;       start address = DSPSTR + S
;       word count    = 1999 - S    (bytes from scroll position to buffer end)
;   Ch3 (lower priority):  transfers from DSPSTR for wrap-around
;       start address = DSPSTR
;       word count    = 1999        (full buffer, but only S bytes are used)
;
; The 8275 CRT controller requests characters via DMA row by row.  Ch2
; is serviced first (higher priority, demand mode).  When Ch2 reaches
; terminal count after transferring (2000 - S) bytes, Ch3 takes over and
; provides the remaining S bytes from the start of the buffer.  The 8275
; stops requesting after 2000 total bytes, so Ch3's full-buffer count
; is never exhausted.  The combined effect: the screen displays bytes
; [S..1999] followed by [0..S-1], implementing smooth hardware scrolling.
;
; Ch2 word count derivation (let A = DSPSTR + S, the absolute address):
;   -A + 1999 + DSPSTR  =  -(DSPSTR+S) + 1999 + DSPSTR  =  1999 - S
;------------------------------------------------------------------------
DISINT:
	PUSH	AF
	IN	A,(CRTCOM)		; Read 8275 status to acknowledge interrupt

	PUSH	HL
	PUSH	DE
	PUSH	BC

	; -- Mask (disable) DMA channels 2 and 3 during reprogramming
	; https://www.jbox.dk/rc702/hardware/intel-8237.pdf page 6-96
	LD	A,00000110b		; Channel 2, bit2=1 -> mask (disable)
	OUT	(SMSK),A		; Mask DMA channel 2
	LD	A,00000111b		; Channel 3, bit2=1 -> mask (disable)
	OUT	(SMSK),A		; Mask DMA channel 3
	OUT	(CLBP),A		; Clear byte pointer flip-flop (value in A is ignored)

	; -- Ch2: set start address = DSPSTR + SCROLLOFSET
	LD	HL,(SCROLLOFSET)	; HL = S (scroll offset, 0..1999)
	LD	DE,DSPSTR
	ADD	HL,DE			; HL = DSPSTR + S (absolute scroll start)
	LD	A,L
	OUT	(CH2ADR),A		; Ch2 address low byte
	LD	A,H
	OUT	(CH2ADR),A		; Ch2 address high byte

	; -- Ch2: set word count = 1999 - S
	; Computed as: -(DSPSTR + S) + 1999 + DSPSTR = 1999 - S
	LD	A,L
	CPL
	LD	L,A
	LD	A,H
	CPL
	LD	H,A
	INC	HL			; HL = -(DSPSTR + S)  (two's complement negate)
	LD	DE,2000 - 1
	ADD	HL,DE			; HL = -(DSPSTR + S) + 1999
	LD	DE,DSPSTR
	ADD	HL,DE			; HL = 1999 - S
	LD	A,L
	OUT	(WCREG2),A		; Ch2 word count low
	LD	A,H
	OUT	(WCREG2),A		; Ch2 word count high

	; -- Ch3: set start address = DSPSTR (buffer base for wrap-around)
	LD	HL,DSPSTR
	LD	A,L
	OUT	(CH3ADR),A		; Ch3 address low byte
	LD	A,H
	OUT	(CH3ADR),A		; Ch3 address high byte

	; -- Ch3: set word count = 1999 (full buffer; only S bytes actually used)
	LD	HL,2000-1
	LD	A,L
	OUT	(WCREG3),A		; Ch3 word count low
	LD	A,H
	OUT	(WCREG3),A		; Ch3 word count high

	; -- Unmask (enable) DMA channels 2 and 3 to begin transfers
	; SMSK format: bits 1-0 = channel, bit 2 = 0 to unmask (enable)
	LD	A,002H			; Unmask (enable) DMA channel 2
	OUT	(SMSK),A
	LD	A,003H			; Unmask (enable) DMA channel 3
	OUT	(SMSK),A

	POP	BC
	POP	DE
	POP	HL

	; -- Re-arm CTC channel 2 for next display interrupt
	LD	A,11010111b		; Int enable, counter, prescale=16, falling, TC follows, reset
	OUT	(CTCCH2),A		; Reconfigure CTC Ch2
	LD	A,001H			; Time constant = 1 (interrupt on next edge)
	OUT	(CTCCH2),A		; Load time constant

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
	JP	FLPBDY

DUMINT:				; Dummy interrupt
	EI
	RETI

;------------------------------------------------------------------------
; Error display procedure (cf. rob358 ERR)
; Entry: A = error code
;------------------------------------------------------------------------

ERRDSP:
	LD	(ERRSAV),A		; Save error code
	EI
	LD	A,(DSKTYP)
	AND	00000001b
	JP	NZ,RETSP		; Return to caller via SP restore
	OUT	(BIB),A			; A=0 after AND; any write to BIB sounds beeper on error
	CALL	ERRCPY			; Copy error text to display
ERRHLT:
	OR	A
	JP	ERRHLT			; Halt loop

ERRCPY:
	LD	BC,DSPSTR		; Display buffer address
	LD	DE,DISKETTEERRORMSG
	LD	HL,DISKETTEERRORMSGLEN	; 18 characters
ERRCPLP:
	LD	A,(DE)			; Copy error text to display
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
;
; Note: This message is shown if for any reason the diskette cannot be
; read when expected.  For MAME this may happen if using a mini floppy
; image in a maxi floppy drive, as the number of sectors per track are
; different are smaller.
DISKETTEERRORMSG:
	DEFB	'**DISKETTE ERROR** '
DISKETTEERRORMSGLEN	EQU $ - DISKETTEERRORMSG - 1

;------------------------------------------------------------------------
; FLOPPY BOOT - main entry point (0x7404)
; Called after hard disk boot fails or is skipped
; (cf. rob358 FLOPPY section)
;------------------------------------------------------------------------

FLBOOT:
	LD	A,(DISKBITS)		; Get status flags
	AND	10000000b			; Mask mini/maxi bit
	LD	HL,DSKTYP
	OR	(HL)			; Combine with current type
	LD	(HL),A
	DEC	(HL)
	CALL	DSKAUTO			; Auto-detect disk density
	LD	HL,FLOPPYDATA
	LD	(MEMADR),HL		; Memory pointer := 0
	LD	HL,INTVEC
	CALL	RDTRK0			; Read track 0 side 0
	LD	A,001H
	LD	(DSKTYP),A		; Set floppy boot flag
	; [Claude Opus 4.6] 0x1000 is the ID-COMAL boot entry point.  ID-COMAL
	; was a COMAL interpreter system used on RC700-series machines.  After
	; reading track 0 to memory at 0x0000, the ID-COMAL bootstrap code
	; resides at offset 0x1000 and takes over from here.  This path is only
	; reached for non-CP/M (COMAL) diskettes; CP/M boots via BOOT7/BOOT8.
	JP	COMALBOOT		; Jump to ID-COMAL boot address

RDTRK0:
	LD	A,000H
	LD	(TRKOVR),HL		; Clear track overflow
RDTRK1:
	CALL	FLSEEK			; Seek to track
	JP	C,CHECKPROM1 		; Error: display error
	JP	Z,RDTRK2		; Seek OK: read track
	LD	A,006H			; Error code
	JP	ERRDSP
RDTRK2:
	CALL	CALCTX			; Calculate transfer with overflow
	LD	A,006H			; Read track command
	LD	C,005H			; 5 retries
	CALL	READTK			; Read track with retry
	JP	NC,RDTROK		; Read OK
	LD	A,028H			; Error code
	JP	ERRDSP
RDTROK:
	LD	HL,(TRBYT)		; Get transfer byte count
	EX	DE,HL
	LD	HL,(MEMADR)		; Update memory pointer
	ADD	HL,DE
	LD	(MEMADR),HL
	LD	L,000H			; Clear transfer count
	LD	H,L
	LD	(TRBYT),HL
	CALL	NXTHDS			; Advance to next head/side
	LD	A,(MOREFL)		; More data to transfer?
	OR	A
	RET	Z			; No: return
	JP	RDTRK1			; Yes: read more (skip LD A,000H)

NXTHDS:
	LD	A,001H			; Advance head/side
	LD	(CURREC),A		; Record := 1
	LD	A,(DISKBITS)
	AND	00000010b			; Check dual-sided bit
	RRCA
	LD	HL,CURHED
	CP	(HL)			; Same head?
	JP	Z,NXTCYL		; Yes: advance cylinder
	INC	(HL)			; No: switch to other head
	RET

NXTCYL:
	XOR	A			; A := 0
	LD	(HL),A			; Head := 0
	LD	HL,CURCYL
	INC	(HL)			; Cylinder++
	RET

;------------------------------------------------------------------------
; CALCTX - Calculate track transfer with overflow check
; Sets MOREFL if more data needs to be transferred
;------------------------------------------------------------------------

CALCTX:
	LD	HL,(TRKOVR)		; Get remaining overflow
	PUSH	HL
	CALL	CALCTB			; Calculate transfer byte count
	CALL	NEGHL			; Negate HL
	POP	DE
	ADD	HL,DE			; Overflow - track bytes
	JP	NC,CALCTX2		; No overflow: clear flags
	LD	A,H
	OR	L
	JP	Z,CALCTX2		; Zero: clear flags
	LD	A,001H
	LD	(MOREFL),A		; More data to transfer
	LD	(TRKOVR),HL		; Save remaining overflow
	RET

CALCTX2:
	LD	A,000H
	LD	(MOREFL),A		; No more data
	LD	(TRKOVR),A		; Clear overflow
	LD	(TRKOV2),A
	EX	DE,HL
	LD	(TRBYT),HL		; Set transfer byte count
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
	LD	A,(DISKBITS)		; Get status flags
	AND	00011100b		; Extract density bits
	RRA
	RRA
	AND	00000111b		; and shift them to the lowest 3 bits
	LD	(RECLEN),A		; Set record length (N)
	CALL	FMTLKP			; Look up format parameters
	CALL	CALCTB			; Calculate transfer byte count
	RET

;------------------------------------------------------------------------
; DSKAUTO - Auto-detect disk density
; Seeks to track 0, reads ID, determines format
; Returns: CF=1 on error
;------------------------------------------------------------------------

DSKAUTO:
	LD	A,(DISKBITS)		; Get status flags
	AND	-2			; Clear side bit
	LD	(DISKBITS),A
DSKAUTO1:
	CALL	FLSEEK			; Seek to current cylinder
	JP	NZ,DSKFAIL		; Seek failed: error
	LD	L,004H
	LD	H,000H
	LD	(TRBYT),HL		; Transfer 4 bytes (ID field)
	LD	A,00AH			; Read ID command FIXME
	LD	C,001H			; 1 retry
	CALL	READTK			; Read track
	LD	HL,DISKBITS
	JP	NC,DSKDET		; Read OK: detect format
	LD	A,(HL)			; Read failed
	AND	00000001b			; Already tried other side?
	JP	NZ,DSKFAIL		; Yes: give up
	INC	(HL)			; Try other side
	JP	DSKAUTO1		; Retry seek
DSKDET:
	LD	A,(FDCRS6)		; Get N from FDC result
	RLCA				; Shift to density bits position
	RLCA
	LD	B,A
	LD	A,(HL)			; Get status flags
	AND	11100011B		; Clear old density bits
	ADD	A,B			; Insert new density
	LD	(HL),A
	CALL	SETFMT			; Set format from detected density
	; [Claude Opus 4.6] SCF; CCF is the standard Z80 idiom for clearing the
	; carry flag.  The Z80 has no direct "clear carry" instruction, so
	; SCF (set carry) followed by CCF (complement carry) achieves it.
	; This pattern appears throughout the PROM for returning success.
	SCF
	CCF				; Clear carry = success
	RET
DSKFAIL:
	SCF				; Set carry = error
	RET

;------------------------------------------------------------------------
; FMTLKP - Format table lookup by density
; Looks up EOT, GAP3, DTL from format tables based on mini/maxi
; and current density setting
;------------------------------------------------------------------------

FMTLKP:
	LD	A,(RECLEN)		; Get record length (N)
	RLA				; Multiply by 4 (table entry size)
	RLA
	LD	E,A
	LD	D,000H			; and put in DE.
	LD	HL,MAXIFMT		; Default: 8" format table
	LD	A,(DISKBITS)
	AND	10000000b		; Check mini/maxi bit (0=maxi, 1=mini)
	LD	A,04CH			; Max cylinder = 76
	JP	Z,FMTLK2		; bit7=0 (maxi): use MAXIFMT, cyl=76
	LD	A,023H			; Max cylinder = 35
	LD	HL,MINIFMT		; bit7=1 (mini): use MINIFMT, cyl=35
FMTLK2:
	LD	(EPTS),A		; Store sectors per track
	ADD	HL,DE			; Index into table
	LD	A,(DISKBITS)
	AND	00000001b			; Check side bit
	JP	Z,FMTLK3
	LD	E,002H			; Side 1: offset by 2
	LD	D,000H
	ADD	HL,DE
FMTLK3:
	EX	DE,HL
	LD	HL,CUREOT		; Copy EOT and GAP3 from table
	LD	A,(DE)
	LD	(HL),A			; CUREOT = table[0]
	LD	(TRKSZ),A		; Also save as track size
	INC	HL
	INC	DE
	LD	A,(DE)
	LD	(HL),A			; GAP3 = table[1]
	INC	HL
	LD	A,10000000b
	LD	(HL),A			; DTL = 80H
	RET

;------------------------------------------------------------------------
; CALCTB - Calculate transfer byte count
; Computes total bytes = sector_size * sector_count
; Sets TRBYT with result
;------------------------------------------------------------------------

CALCTB:
	LD	HL,SECSZ0		; Base sector size = 128
	LD	A,(RECLEN)		; Get N (record length code)
	OR	A
	JP	Z,CALCT2		; N=0: 128 bytes/sector
CALCT1:	ADD	HL,HL			; Double for each N level
	DEC	A
	JP	NZ,CALCT1
CALCT2:	LD	(SECBYT),HL		; Save bytes per sector
	EX	DE,HL
	LD	A,(CURREC)		; Current record number
	LD	L,A
	LD	A,(CUREOT)		; End of track
	SUB	L			; Sectors remaining = EOT - REC
	INC	A
	LD	L,A
	LD	A,(DSKTYP)		; Check mini/maxi
	AND	10000000b
	JP	Z,CALCT3		; Maxi: use calculated count
	LD	A,(CURHED)		; Mini: check head
	XOR	00000001b
	JP	NZ,CALCT3		; Head 0: use calculated count
	LD	L,00AH			; Mini head 1: 10 sectors
CALCT3:	LD	A,L			; Multiply sectors * bytes/sector
	LD	L,000H
	LD	H,L
CALCT4:	ADD	HL,DE			; HL += sector_size
	DEC	A
	JP	NZ,CALCT4
	LD	(TRBYT),HL		; Store transfer byte count
	RET

;------------------------------------------------------------------------
; READTK - Read track with retry
; Entry: A = FDC command, C = retry count
; (cf. rob358 READ/READOK)
;------------------------------------------------------------------------

READTK:
	PUSH	AF			; Save FDC command
	LD	A,C
	LD	(REPTIM),A		; Set retry count
READTK1:
	CALL	CLRFLF			; Clear floppy interrupt flag
	LD	HL,(TRBYT)		; Get transfer byte count
	LD	B,H
	LD	C,L
	DEC	BC			; BC = count - 1
	LD	HL,(MEMADR)		; Get DMA target address
	POP	AF
	PUSH	AF
	AND	00001111b		; Mask command type
	CP	00001010b		; Read ID command?
	CALL	NZ,STPDMA		; Set up DMA (read mode) if not Read ID
	POP	AF
	LD	C,A			; Save command in C
	CALL	FLRTRK			; Send FDC command
	LD	A,0FFH
	CALL	WAITFL			; Wait for floppy interrupt
	RET	C			; Return if timeout
	LD	A,C
	CALL	CHKRES			; Check FDC result (CHKRES)
	RET	NC			; Return if no error
	RET	Z			; Return if retries exhausted
	LD	A,C
	PUSH	AF
	JP	READTK1			; Retry (back to CLRFLF)

;------------------------------------------------------------------------
; Check FDC result status bytes
; Returns: NC if OK, C+NZ if error with retries, C+Z if retries exhausted
;------------------------------------------------------------------------
; [Claude Opus 4.6] NEC uPD765 result phase registers (corrected).
; After a read/write command, the FDC returns 7 result bytes:
;
;   Byte 0 - ST0: Status Register 0
;     bit 7-6: Interrupt code (00=normal, 01=abnormal, 10=invalid cmd, 11=drive not ready)
;     bit 5:   Seek end (SE)
;     bit 4:   Equipment check (EC)
;     bit 3:   Not ready (NR) - drive not ready
;     bit 2:   Head address (HD) - current head
;     bit 1-0: Unit select (US1,US0) - drive number
;
;   Byte 1 - ST1: Status Register 1
;     bit 7:   End of cylinder (EN)
;     bit 5:   Data error (DE) - CRC error in data field
;     bit 4:   Overrun (OR) - CPU didn't service DMA in time
;     bit 2:   No data (ND) - sector not found
;     bit 1:   Not writable (NW) - write protect
;     bit 0:   Missing address mark (MA)
;
;   Byte 2 - ST2: Status Register 2
;     bit 6:   Control mark (CM) - deleted data address mark found
;     bit 5:   Data error in data field (DD)
;     bit 4:   Wrong cylinder (WC)
;     bit 3:   Scan equal hit (SH)
;     bit 2:   Scan not satisfied (SN)
;     bit 1:   Bad cylinder (BC)
;     bit 0:   Missing address mark in data field (MD)
;
;   Byte 3: Cylinder number (C) after command
;   Byte 4: Head number (H) after command
;   Byte 5: Record/sector number (R) after command
;   Byte 6: Sector size code (N) after command
CHKRES:
	LD	HL,FDCRES		; Point to result status bytes
	LD	A,(HL)			; Get ST0
	AND	11000011b		; Mask command/drive bits
	LD	B,A
	LD	A,(DRVSEL)		; Expected drive select
	CP	B			; Match?
	JP	NZ,CHKERR		; No: error
	INC	HL
	LD	A,(HL)			; Get ST1
	CP	000H
	JP	NZ,CHKERR		; Non-zero: error
	INC	HL
	LD	A,(HL)			; Get ST2
	AND	10111111b		; Mask bit 6 (control mark)
	CP	000H
	JP	NZ,CHKERR		; Non-zero: error
	SCF				; Set carry
	CCF				; Clear carry = success
	RET

CHKERR:
	LD	A,(REPTIM)		; Decrement retry count
	DEC	A
	LD	(REPTIM),A
	SCF				; Set carry = error
	RET

;------------------------------------------------------------------------
; FLRTRK - Send FDC read/write command (cf. rob358 FLRTRK)
; Builds and sends command buffer to FDC
; If format command, sends 9 bytes; otherwise sends 2 bytes
;------------------------------------------------------------------------

FLRTRK:
	PUSH	BC
	PUSH	AF
	DI
	LD	A,0FFH
	LD	HL,COMBUF		; Command buffer
	LD	(FDCFLG),A		; Set FDC busy flag
	LD	A,(DISKBITS)		; Get status flags
	AND	00000001b			; Check side bit
	JP	Z,FLRTRK2		; Side 0: skip MFM flag
	LD	A,01000000b		; Side 1: set MFM flag
FLRTRK2:
	LD	B,A
	POP	AF
	PUSH	AF
	ADD	A,B			; Add MFM flag to command
	LD	(HL),A			; Store in command buffer
	INC	HL
	CALL	MKDHB			; Make drive/head byte
	LD	(HL),A			; Store drive/head
	DEC	HL
	POP	AF
	AND	00001111b			; Mask command type
	CP	006H			; Format command?
	LD	C,009H			; Format: 9 bytes to send
	JP	Z,FLRTRK3		; Jump to send loop
	LD	C,002H			; Non-format: 2 bytes
FLRTRK3:
	LD	A,(HL)			; Load command byte
	INC	HL
	CALL	FL02			; Wait FDC write ready (FLO2)
	DEC	C
	JP	NZ,FLRTRK3		; Loop: send remaining bytes
	POP	BC
	EI
	RET
;------------------------------------------------------------------------
; DMA setup - Write mode entry
; HL = memory address, BC = byte count - 1
; (cf. rob358 STPDMA - shared code between read/write modes)
;------------------------------------------------------------------------

DMAWRT:
	LD	A,005H			; Channel 1, bit2=1 -> mask (disable)
	DI
	OUT	(SMSK),A		; Mask (disable) DMA channel 1 during setup
	LD	A,01001001b		; Demand mode, addr increment, auto-init, write, channel 1
DMAWRT1:
	OUT	(DMAMOD),A		; Set DMA mode for channel 1 (read or write)
	OUT	(CLBP),A		; Clear byte pointer flip-flop (value in A is ignored)
	LD	A,L
	OUT	(CH1ADR),A		; Ch1 address low byte (memory buffer start)
	LD	A,H
	OUT	(CH1ADR),A		; Ch1 address high byte
	LD	A,C
	OUT	(WCREG1),A		; Ch1 word count low (transfer size - 1)
	LD	A,B
	OUT	(WCREG1),A		; Ch1 word count high
	LD	A,001H			; Channel 1, bit2=0 -> unmask (enable)
	OUT	(SMSK),A		; Unmask (enable) DMA channel 1, transfer begins
	EI
	RET

;------------------------------------------------------------------------
; STPDMA - Set up DMA for read (cf. rob358 STPDMA)
; HL = memory address, BC = byte count - 1
;------------------------------------------------------------------------

STPDMA:
	LD	A,005H			; Channel 1, bit2=1 -> mask (disable)
	DI
	OUT	(SMSK),A		; Mask (disable) DMA channel 1 during setup
	LD	A,01000101b		; Demand mode, addr increment, auto-init, read, channel 1
	JP	DMAWRT1			; Share DMA setup code

;------------------------------------------------------------------------
; Wait FDC ready to write + send byte (entry at 0763CH via overlapping)
; Waits for FDC RQM=1/DIO=0, then writes A to FDD
; (cf. rob358 FLO2)
;------------------------------------------------------------------------

FL02:
	PUSH	AF
	PUSH	BC
	LD	B,000H			; Timeout counter high
	LD	C,000H			; Timeout counter low
FL02_1:
	INC	B			; Increment counter
	CALL	Z,FDCTOUT		; Timeout if B overflows to 0
	IN	A,(FDC)			; Read FDC main status
	AND	11000000b			; Mask RQM and DIO bits
	CP	10000000b		; Ready for write? (RQM=1, DIO=0)
	JP	NZ,FL02_1		; No: keep waiting
	POP	BC
	POP	AF
	OUT	(FDD),A			; Write command/parameter byte to FDC data register
	RET

;------------------------------------------------------------------------
; FLO3 - Wait FDC ready to read (cf. rob358 FLO3)
; Returns data byte from FDC in A
;------------------------------------------------------------------------

FLO3:
	PUSH	BC
	LD	B,000H			; Timeout counter high
	LD	C,000H			; Timeout counter low
FL03_1:
	INC	B			; Increment counter
	CALL	Z,FDCTOUT		; Timeout if B overflows to 0
	IN	A,(FDC)			; Read FDC main status
	AND	11000000b		; Mask RQM and DIO bits
	CP	11000000b		; Ready for read? (RQM=1, DIO=1)
	JP	NZ,FL03_1		; No: keep waiting
	POP	BC
	IN	A,(FDD)			; Read data byte from FDC
	RET

;------------------------------------------------------------------------
; FDCTOUT - FDC timeout handler
;------------------------------------------------------------------------

FDCTOUT:
	LD	B,000H			; Reset high counter
	INC	C			; Increment group counter
	RET	NZ			; Return if not fully timed out
	EI				; Full timeout: enable interrupts
	JP	CHECKPROM1			; Jump to error handler

;------------------------------------------------------------------------
; Sense drive status (FDC command 04H)
;------------------------------------------------------------------------

SNSDRV:
	LD	A,004H			; Sense drive status command
	CALL	FL02			; Wait FDC write ready (FLO2)
	LD	A,(DRVSEL)		; Drive select byte
	CALL	FL02			; Wait FDC write ready (FLO2)
	CALL	FLO3			; Read ST3 result
	LD	(FDCRES),A		; Save ST3
	RET

;------------------------------------------------------------------------
; FLO6 - Sense interrupt status (cf. rob358 FLO6)
;------------------------------------------------------------------------

FLO6:
	LD	A,008H			; Sense interrupt status command
	CALL	FL02			; Wait FDC write ready (FLO2)
	CALL	FLO3			; Read ST0
	LD	(FDCRES),A		; Save ST0
	AND	11000000b			; Check status bits
	CP	10000000b		; Invalid command?
	JP	Z,FL06_2		; Yes: skip reading PCN
	CALL	FLO3			; Read present cylinder number
	LD	(FDCRS1),A		; Save PCN
FL06_2:
	RET

;------------------------------------------------------------------------
; CLRFLF - Clear floppy interrupt flag
;------------------------------------------------------------------------

CLRFLF:
	DI
	XOR	A			; A := 0
	LD	(FLPFLG),A		; Clear flag
	EI
	RET

;------------------------------------------------------------------------
; MKDHB - Make drive/head byte
; Returns A = (head << 2) | drive
;------------------------------------------------------------------------

MKDHB:
	PUSH	DE
	LD	A,(CURHED)		; Get current head
	RLA				; Shift head to bit 2
	RLA
	LD	D,A
	LD	A,(DRVSEL)		; Get drive select
	ADD	A,D			; Combine drive and head
	POP	DE
	RET

;------------------------------------------------------------------------
; DELAY - Delay loop (cf. rob358 FDSTAR W1/W2)
; B = outer count, C = inner count
;------------------------------------------------------------------------

DELAY: ; ~0.25µs * (b*(c*256+255)*24-2) per call
	PUSH	AF
	PUSH	HL
DELY1:	LD	H,C			; Inner loop count
	LD	L,0FFH
DELY2:	DEC	HL			; Decrement inner counter
	LD	A,L
	OR	H
	JP	NZ,DELY2		; Inner loop
	DEC	B			; Decrement outer counter
	JP	NZ,DELY1		; Outer loop
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
WAIT1:	DEC	A			; Decrement timeout counter
	SCF
	JP	Z,WAIT2			; Timed out: clear flag and return C
	LD	B,001H
	LD	C,001H
	CALL	DELAY			; Short delay
	LD	B,A			; Save counter
	LD	A,(FLPFLG)		; Check floppy interrupt flag
	AND	00000010b		; Interrupt occurred?
	LD	A,B			; Restore counter
	JP	Z,WAIT1			; No: keep waiting
	SCF				; Set carry
	CCF				; Clear carry = success
	CALL	CLRFLF			; Clear flag for next time
WAIT2:
	POP	BC
	RET

;------------------------------------------------------------------------
; FLWRES - Wait for floppy result
; Returns: B = ST0, C = PCN/ST1
;------------------------------------------------------------------------

FLWRES:
	LD	A,0FFH
	CALL	WAITFL			; Wait for floppy interrupt
	LD	A,(FDCRES)		; Get ST0
	LD	B,A
	LD	A,(FDCRS1)		; Get PCN/ST1
	LD	C,A
	RET

;------------------------------------------------------------------------
; FLO4 - Recalibrate drive (cf. rob358 FLO4)
;------------------------------------------------------------------------

FLO4:
	LD	A,007H			; Recalibrate command
	CALL	FL02			; Wait FDC write ready (FLO2)
	LD	A,(DRVSEL)		; Drive select
	CALL	FL02			; Wait FDC write ready (FLO2)
	RET

;------------------------------------------------------------------------
; FLO7 - Seek track (cf. rob358 FLO7)
; Entry: D = drive/head byte, E = cylinder number
;------------------------------------------------------------------------

FLO7:
	LD	A,00FH			; Seek command
	CALL	FL02			; Wait FDC write ready (FLO2)
	LD	A,D
	AND	00000111b			; Mask drive/head bits
	CALL	FL02			; Wait FDC write ready (FLO2)
	LD	A,E			; Cylinder number
	CALL	FL02			; Wait FDC write ready (FLO2)
	RET

;------------------------------------------------------------------------
; RECALV - Recalibrate and verify result
; Returns: NC if successful
;------------------------------------------------------------------------

RECALV:
	CALL	FLO4			; Recalibrate drive
	CALL	FLWRES			; Wait for result
	RET	C			; Return if timeout
	LD	A,(DRVSEL)		; Check result
	ADD	A,00100000b		; Expected: seek end + drive
	CP	B			; Match ST0?
	JP	NZ,RECALV1		; No: error
	LD	A,C
	CP	000H			; Cylinder 0?
RECALV1:
	SCF				; Set carry
	CCF				; Clear carry = success
	RET

;------------------------------------------------------------------------
; FLSEEK - Seek to current cylinder with verify
; (cf. rob358 FLO7 with result check)
;------------------------------------------------------------------------

FLSEEK:
	LD	A,(CURCYL)		; Get target cylinder
	LD	E,A
	CALL	MKDHB			; Get drive/head byte
	LD	D,A
	CALL	FLO7			; Seek to cylinder
	CALL	FLWRES			; Wait for result
	RET	C			; Return if timeout
	LD	A,(DRVSEL)		; Check result
	ADD	A,00100000b		; Expected: seek end + drive
	CP	B			; Match ST0?
	JP	NZ,SEEKERR		; No: error
	LD	A,(CURCYL)		; Verify cylinder
	CP	C			; Match PCN?
SEEKERR:
	SCF				; Set carry
	CCF				; Clear carry = success
	RET

;------------------------------------------------------------------------
; RSULT - Read FDC result bytes (cf. rob358 RSULT)
; Reads up to 7 result bytes from FDC into FDCRES buffer
;------------------------------------------------------------------------

RSULT:
	LD	HL,FDCRES		; Result buffer
	LD	B,007H			; Max 7 result bytes
	LD	A,B
	LD	(FDCFLG),A		; Mark FDC busy
RSULT2:
	CALL	FLO3			; Read first result byte
	LD	(HL),A			; Store in buffer
	INC	HL
	LD	A,(FDCWAI)		; FDC timing delay
RSULT3:
	DEC	A
	JP	NZ,RSULT3		; Delay loop

	IN	A,(FDC)			; Check FDC status
	AND	00010000b			; Non-DMA execution mode?
	JP	Z,RSULT4		; No: check DMA status
	DEC	B			; More bytes to read?
	JP	NZ,RSULT2		; Yes: read next byte
	LD	A,0FEH			; Error: too many result bytes
	JP	ERRDSP			; Error handler (ERRDSP)
RSULT4:
	IN	A,(DMACOM)		; Read DMA status
	LD	(HL),A			; Store in buffer
	DEC	B
	RET	Z			; All bytes read
	EI
	LD	A,0FDH			; Error: incomplete result
	JP	ERRDSP			; Error handler (ERRDSP)

;------------------------------------------------------------------------
; FLPBDY - Floppy interrupt handler body (cf. rob358 FLPINT)
;------------------------------------------------------------------------

FLPBDY:
	PUSH	AF
	PUSH	BC
	PUSH	HL
	LD	A,002H
	LD	(FLPFLG),A		; Set floppy interrupt flag
	LD	A,(FDCTMO)		; FDC timeout counter
FLPBDY2:
	DEC	A
	JP	NZ,FLPBDY2		; Delay loop

	IN	A,(FDC)			; Read FDC status
	AND	00010000b			; Non-DMA execution mode?
	JP	NZ,FLPBDY3		; Yes: read full result
	CALL	FLO6			; Sense interrupt status
	JP	FLPBDY4			; Exit
FLPBDY3:
	CALL	RSULT			; Read full result
FLPBDY4:
	POP	HL
	POP	BC
	POP	AF
	EI
	RETI

	; padding up to end of PROM.
	NOP
	NOP

PAYLOADLEN	EQU	$ - PAYLOAD + 1

	dephase

	; DATA AREA - RAM variables used by boot ROM
	; (cf. rob358.mac EQU block at 0xB000 for RC700/RC703 equivalents)
	ORG	08000H
TRK:	DS	03H		; Track count (cf. rob358 TRK at 0xB000)
ERRSAV:	DS	1		; Error code save (written in errdsp)
	DS	7		; (unused/padding)
FDCFLG:	DS	1		; FDC busy flag (0xFF=busy)
EPTS:	DS	1		; EOT / sectors per track
TRKSZ:	DS	1		; Track sector size byte
	DS	2		; (unused/padding)


; FDCRES / FDCRS1 / FDCRS6:  NEC UPD765 status registers.
;   FDCRES (1 byte) – ST0 (command/drive status).
;   FDCRS1 (5 bytes) – ST1- ST5; firmware uses ST1, ST2, ST3 (PCN).
;   FDCRS6 (1 byte) – ST6 (record‑length N).
;   These are read by READTK, CHKRES, FLWRES, etc.
FDCRES:	DS	1		; FDC result area: ST0 (7 bytes total)
FDCRS1:	DS	5		; FDC result: ST1/PCN through C,H,R
FDCRS6:	DS	1		; FDC result: N (record length)
	DS	4		; (unused/padding)
DRVSEL:	DS	1		; Drive select / head byte
FDCTMO:	DS	1		; FDC timeout counter (init=3)
FDCWAI:	DS	1		; FDC wait counter (init=4)
SPSAV:	DS	12H		; Stack pointer save + workspace
COMBUF:	DS	1		; FDC command buffer (9 bytes)
	DS	1		;  drive/head byte
CURCYL:	DS	1		;  current cylinder number
CURHED:	DS	1		;  current head address
CURREC:	DS	1		;  current record/sector number
RECLEN:	DS	1		;  record length (N), 0=128, 1=256, 2=512...
CUREOT:	DS	1		;  current EOT (end of track)
	DS	2		;  GAP3 + DTL
SECBYT:	DS	1		; Sector byte count (word)
	DS	7		; (unused/padding)
FLPFLG:	DS	1		; Floppy interrupt flag (0=idle, 2=done)
FLPWAI:	DS	1		; Floppy wait counter (init=4)
	DS	29		; (unused/padding)
DSKTYP:	DS	1		; Disk type flag (bit7=mini, bit0=floppy boot)
MOREFL:	DS	1		; More data to transfer flag
REPTIM:	DS	1		; Repeat/retry counter (init=5)
CLRBLK:	DS	1		; Start of 8-byte cleared block
	DS	1
MEMADR:	DS	1		; Memory address pointer (word, DMA dest)
	DS	1
TRBYT:	DS	1		; Transfer byte count (word)
	DS	1
TRKOVR:	DS	1		; Track overflow count (word)
TRKOV2:	DS	1		; Track overflow high byte


; Display buffer plus work area

	ORG	07800H
DSPSTR:	DS	2000		; Display memory buffer address
	DS	1		; [Claude Opus 4.6] Unnamed padding byte between
				; display buffer and CRT work area. Purpose unknown.
UNUSED1:	DS	1
UNUSED2:	DS	2
UNUSED3:	DS	1
SCROLLOFSET:	DS	2	; Scroll offset into display buffer for DMA ch2 start address.
				; Added to DSPSTR base to compute where screen rendering
				; begins, enabling circular-buffer hardware scrolling.
UNUSED4:	DS	2
UNUSED5:	DS	2
UNUSED6:	DS	2
UNUSED7:	DS	1
UNUSED8:	DS	2
UNUSED9:	DS	2
UNUSED10:	DS	2
UNUSED11:	DS	2
UNUSED12:	DS	1

	END
