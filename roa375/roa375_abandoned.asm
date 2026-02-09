;************************************************************************
;*									*
;* AUTOLOAD ROM FOR THE RC702 MICROCOMPUTER				*
;*									*
;* ROM: ROA375 (2048 bytes)						*
;* Disassembled and commented: 2026-02-08				*
;*									*
;************************************************************************

.Z80

;=======================================================================
; HARDWARE I/O PORT DEFINITIONS
;=======================================================================

PORT14		EQU	014H		; Mini/Maxi switch & PROM disable
					; Reading: bit 7 = diskette size
					; Writing: disables PROM, enables RAM
PORT18		EQU	018H		; Beeper/speaker port

;=======================================================================
; MEMORY ADDRESS DEFINITIONS
;=======================================================================

STACK		EQU	0BFFFH		; Stack pointer initialization
RELOCBASE	EQU	07000H		; Relocation destination (RAM)
RELOCSIZE	EQU	0798H		; Bytes to relocate (1944 bytes)
EXECADDR	EQU	070D0H		; Jump to relocated code

;=======================================================================
; MEMORY MAPPED I/O ADDRESSES
;=======================================================================

IO_801C		EQU	0801CH		; I/O control register
IO_801D		EQU	0801DH		; I/O control register
IO_8042		EQU	08042H		; I/O control register
IO_8033		EQU	08033H		; I/O control register
IO_801B		EQU	0801BH		; I/O control register
IO_8060		EQU	08060H		; I/O control register
IO_8061		EQU	08061H		; I/O control register
IO_8041		EQU	08041H		; I/O control register
IO_8062		EQU	08062H		; I/O control register
IO_8063		EQU	08063H		; I/O register array base (8 bytes)

RELOCATED_DATA	EQU	07320H		; Storage for switch state
JUMP_TARGET	EQU	07218H		; Final jump address

;************************************************************************
;*									*
;* ROM START - COLD BOOT INITIALIZATION				*
;*									*
;* This section executes from ROM and relocates the bootstrap code	*
;* to RAM at 0x7000 for execution.					*
;*									*
;************************************************************************

	ORG	0000H			; ROM starts at address 0

BEGIN:
	DI				; Disable interrupts during init
	LD	SP,STACK		; Initialize stack pointer to 0xBFFF

;-----------------------------------------------------------------------
; Find end of ROM image (search for 0xFF terminator or zero bytes)
;-----------------------------------------------------------------------

	LD	HL,DATASTART		; Point to start of data section
SCAN:
	LD	A,(HL)			; Read byte from ROM
	OR	A			; Check if zero
	INC	HL			; Advance pointer
	JP	Z,SCAN			; Continue scanning if zero
	CP	0FFH			; Check for 0xFF marker
	JP	Z,SKIP			; Found end marker
	DEC	HL			; Back up one byte
SKIP:
	EX	DE,HL			; DE = source address

;-----------------------------------------------------------------------
; Relocate code from ROM to RAM at 0x7000
; This allows the ROM to be disabled and RAM to take over
;-----------------------------------------------------------------------

	LD	HL,RELOCBASE		; HL = destination address (0x7000)
	LD	BC,RELOCSIZE		; BC = number of bytes to copy
COPY:
	LD	A,(DE)			; Read byte from source
	LD	(HL),A			; Write byte to destination
	INC	DE			; Advance source pointer
	INC	HL			; Advance destination pointer
	DEC	BC			; Decrement byte counter
	LD	A,C			; Check if counter reached zero
	OR	B			;
	JP	NZ,COPY			; Continue copying
	JP	EXECADDR		; Jump to relocated code in RAM

;************************************************************************
;*									*
;* HARDWARE INITIALIZATION ROUTINE					*
;*									*
;* Initializes system I/O ports and control registers			*
;*									*
;************************************************************************

INIT_HW:
	LD	A,003H			; Value 3
	LD	(IO_801C),A		; Write to I/O control
	INC	A			; A = 4
	LD	(IO_801D),A		; Write to I/O control
	LD	(IO_8042),A		; Write to I/O control

	LD	A,000H			; Clear A
	LD	B,A			; Clear B
	IN	A,(PORT14)		; Read diskette size switch
	AND	080H			; Mask bit 7 (1=mini/5.25", 0=maxi/8")
	ADD	A,B			; Add to B (=0)
	LD	(RELOCATED_DATA),A	; Store diskette type in RAM

;-----------------------------------------------------------------------
; Clear I/O control registers
;-----------------------------------------------------------------------

	XOR	A			; A = 0
	LD	(IO_8033),A		; Clear I/O registers
	LD	(IO_801B),A		;
	LD	(IO_8060),A		;
	LD	(IO_8061),A		;
	LD	(IO_8041),A		;

;-----------------------------------------------------------------------
; Clear 8-byte I/O register array at 0x8063
;-----------------------------------------------------------------------

	LD	C,008H			; Counter = 8 bytes
	LD	HL,IO_8063		; Base address of array
LOOP1:
	LD	(HL),A			; Write zero (A=0)
	INC	HL			; Next byte
	DEC	C			; Decrement counter
	JP	NZ,LOOP1		; Loop until done

;-----------------------------------------------------------------------
; Enable interrupts and complete initialization
;-----------------------------------------------------------------------

	EI				; Enable interrupts
	LD	A,001H			; Value 1
	OUT	(PORT14),A		; Disable PROM, enable full RAM access

	LD	A,005H			; Value 5
	LD	(IO_8062),A		; Write to I/O register
	JP	JUMP_TARGET		; Jump to main bootstrap code

;-----------------------------------------------------------------------
; Return from non-maskable interrupt
;-----------------------------------------------------------------------

	RETN				; NMI return

;************************************************************************
;*									*
;* DATA SECTION - CODE AND STRINGS THAT GET RELOCATED TO RAM		*
;*									*
;************************************************************************

DATASTART:

;-----------------------------------------------------------------------
; This section starts at 0x68 in ROM and gets relocated to 0x7000
;-----------------------------------------------------------------------

	.PHASE	RELOCBASE		; Assemble for relocated address

	DB	0FFH			; Relocatable marker (also used for scanning)

;-----------------------------------------------------------------------
; Code blocks for display initialization
;-----------------------------------------------------------------------

CODE_BLK1:
	LD	BC,07800H		; BC = display parameters
	LD	DE,0707DH		; DE = message source address
	LD	HL,0014H		; HL = length/offset
	CALL	SUB_COPY		; Copy message to display
	JP	073DAH			; Jump to display handler

CODE_BLK2:
	LD	BC,07800H		; BC = display parameters
	LD	DE,070B0H		; DE = message source address
	LD	HL,000FH		; HL = length/offset
	CALL	SUB_COPY		; Copy message
	JP	073DAH			; Jump to display handler

CODE_BLK3:
	LD	BC,07800H		; BC = display parameters
	LD	DE,07092H		; DE = message source address
	LD	HL,001DH		; HL = length/offset
	CALL	SUB_COPY		; Copy message
	JP	073DAH			; Jump to display handler

;-----------------------------------------------------------------------
; Subroutine: String comparison helper
;-----------------------------------------------------------------------

SUB_CMP1:
	PUSH	HL			; Save HL
	INC	HL			; Advance pointer
	EX	DE,HL			; Swap DE and HL
	LD	BC,070C3H		; BC = compare address
	LD	HL,0004H		; HL = byte count
	CALL	SUB_COMPARE		; Compare strings
	POP	HL			; Restore HL
	JP	Z,0704FH		; Jump if match
	RET				; Return

SUB_CMP2:
	PUSH	HL			; Save HL
	INC	HL			; Advance pointer
	EX	DE,HL			; Swap DE and HL
	LD	BC,070C8H		; BC = compare address
	LD	HL,0004H		; HL = byte count
	CALL	SUB_COMPARE		; Compare strings
	POP	HL			; Restore HL
	JP	Z,0704FH		; Jump if match
	RET				; Return

;-----------------------------------------------------------------------
; Subroutine: Check byte at offset +7 and compare with 0x13
;-----------------------------------------------------------------------

SUB_CHK:
	PUSH	HL			; Save HL
	INC	HL			; HL++
	LD	DE,0007H		; Offset = 7
	ADD	HL,DE			; HL = HL + 7
	LD	A,(HL)			; Read byte
	AND	03FH			; Mask lower 6 bits
	CP	013H			; Compare with 0x13
	POP	HL			; Restore HL
	RET				; Return with flags set

;-----------------------------------------------------------------------
; Subroutine: Compare memory regions byte by byte
; Input: DE = source1, BC = source2, L = byte count
; Output: Z flag set if equal
;-----------------------------------------------------------------------

SUB_COMPARE:
	LD	A,(DE)			; Read byte from source1
	LD	H,A			; Store in H
	LD	A,(BC)			; Read byte from source2
	CP	H			; Compare bytes
	RET	NZ			; Return if not equal
	INC	DE			; Advance source1
	INC	BC			; Advance source2
	DEC	L			; Decrement counter
	JP	NZ,SUB_COMPARE		; Loop if more bytes
	RET				; Return (Z flag set)

;-----------------------------------------------------------------------
; Subroutine: Copy memory block
; Input: DE = source, BC = destination, L = byte count
;-----------------------------------------------------------------------

SUB_COPY:
	LD	A,(DE)			; Read byte from source
	LD	(BC),A			; Write byte to destination
	INC	BC			; Advance destination
	INC	DE			; Advance source
	DEC	L			; Decrement counter
	JP	NZ,SUB_COPY		; Loop if more bytes
	RET				; Return

;************************************************************************
;*									*
;* ERROR MESSAGES							*
;*									*
;************************************************************************

;-----------------------------------------------------------------------
; Error message strings displayed when boot fails
;-----------------------------------------------------------------------

MSG_ERROR1:
	DEFM	" RC700"
MSG_ERROR2:
	DEFM    " RC702"
MSG_ERROR3:
	DEFM	" **NO SYSTEM FILES** "
MSG_ERROR4:
	DEFM	" **NO DISKETTE NOR LINEPROG** "
MSG_ERROR5:
	DEFM	" **NO KATALOG** "
MSG_ERROR6:
	DEFB	002H			; Control character

;-----------------------------------------------------------------------
; System command identifier strings
;-----------------------------------------------------------------------

CMD_TABLE:
	JP	053C8H			; Jump vector (0xC3, 0xC8, 0x53)
	DEFM	"SYSM SYSC "		; System command names
	JP	07362H			; Jump vector (0xC3, 0x62, 0x73)

;-----------------------------------------------------------------------
; Additional initialization code and data follows as DB directives
; (These are the remaining bytes from the original ROM)
;-----------------------------------------------------------------------

	DEFB	031H, 0FFH, 0BFH, 03EH, 073H, 0EDH, 047H, 0EDH
	DEFB	05EH, 00EH, 0FFH, 006H, 001H, 0CDH, 0B1H, 076H
	DEFB	03EH, 099H, 0CDH, 0E9H, 070H, 021H, 027H, 000H
	DEFB	0E9H, 0F5H, 03EH, 002H, 0D3H, 012H, 03EH, 004H
	DEFB	0D3H, 013H, 03EH, 04FH, 0D3H, 012H, 03EH, 00FH
	DEFB	0D3H, 013H, 03EH, 083H, 0D3H, 012H, 0D3H, 013H
	DEFB	0C3H, 003H, 071H, 03EH, 008H, 0D3H, 00CH, 0F1H
	DEFB	03EH, 046H, 0F6H, 041H, 0D3H, 00CH, 03EH, 020H
	DEFB	0D3H, 00CH, 03EH, 046H, 0F6H, 041H, 0D3H, 00DH
	DEFB	03EH, 020H, 0D3H, 00DH, 03EH, 0D7H, 0D3H, 00EH
	DEFB	03EH, 001H, 0D3H, 00EH, 03EH, 0D7H, 0D3H, 00FH
	DEFB	03EH, 001H, 0D3H, 00FH, 0C3H, 02FH, 071H, 03EH
	DEFB	020H, 0D3H, 0F8H, 03EH, 0C0H, 0D3H, 0FBH, 03EH
	DEFB	000H, 0D3H, 0FAH, 03EH, 04AH, 0D3H, 0FBH, 03EH
	DEFB	04BH, 0D3H, 0FBH, 0C3H, 046H, 071H, 03EH, 000H
	DEFB	0D3H, 001H, 03EH, 04FH, 0D3H, 000H, 03EH, 098H
	DEFB	0D3H, 000H, 03EH, 09AH, 0D3H, 000H, 03EH, 05DH
	DEFB	0D3H, 000H, 03EH, 080H, 0D3H, 001H, 0AFH, 0D3H
	DEFB	000H, 0D3H, 000H, 03EH, 0E0H, 0D3H, 001H, 0C3H
	DEFB	06EH, 071H, 003H, 003H, 04FH, 020H, 00EH, 0FFH
	DEFB	006H, 001H, 0CDH, 0B1H, 076H, 0DBH, 004H, 0E6H
	DEFB	01FH, 0C2H, 06EH, 071H, 021H, 06AH, 071H, 046H
	DEFB	023H, 0DBH, 004H, 0E6H, 0C0H, 0FEH, 080H, 0C2H
	DEFB	081H, 071H, 07EH, 0D3H, 005H, 005H, 0C2H, 080H
	DEFB	071H, 0C3H, 094H, 071H, 021H, 000H, 000H, 0EBH
	DEFB	021H, 000H, 078H, 019H, 03EH, 020H, 077H, 07BH
	DEFB	0FEH, 0CFH, 0CAH, 0A9H, 071H, 013H, 0C3H, 098H
	DEFB	071H, 07AH, 0FEH, 007H, 0CAH, 0B3H, 071H, 013H
	DEFB	0C3H, 098H, 071H, 011H, 071H, 070H, 021H, 006H
	DEFB	000H, 001H, 000H, 078H, 0CDH, 068H, 070H, 021H
	DEFB	000H, 000H, 022H, 0D2H, 07FH, 022H, 0D9H, 07FH
	DEFB	022H, 0E4H, 07FH, 022H, 0E2H, 07FH, 022H, 0E0H
	DEFB	07FH, 022H, 0D7H, 07FH, 022H, 0DEH, 07FH, 022H
	DEFB	0D5H, 07FH, 021H, 080H, 007H, 022H, 0DBH, 07FH
	DEFB	03EH, 000H, 032H, 0D1H, 07FH, 032H, 0D4H, 07FH
	DEFB	032H, 0DDH, 07FH, 032H, 0E6H, 07FH, 03EH, 023H
	DEFB	0D3H, 001H, 0C9H, 0AFH, 032H, 032H, 080H, 03CH
	DEFB	032H, 033H, 080H, 032H, 034H, 080H, 0CDH, 0CBH
	DEFB	074H, 0DAH, 00BH, 072H, 021H, 020H, 073H, 03EH
	DEFB	002H, 0B6H, 077H, 021H, 033H, 080H, 035H, 0CDH
	DEFB	0CBH, 074H, 0D0H, 03EH, 0FBH, 0C3H, 0C4H, 072H
	DEFB	006H, 001H, 00EH, 0FFH, 0CDH, 0B1H, 076H, 0CDH
	DEFB	072H, 076H, 03AH, 010H, 080H, 0E6H, 023H, 04FH
	DEFB	03AH, 01BH, 080H, 0C6H, 020H, 0B9H, 0C2H, 0C4H
	DEFB	072H, 0CDH, 00BH, 077H, 0DAH, 0C4H, 072H, 0CAH
	DEFB	03DH, 072H, 0C3H, 0C4H, 072H, 0CDH, 0F3H, 071H
	DEFB	03EH, 001H, 0D3H, 018H, 02AH, 067H, 080H, 0CDH
	DEFB	025H, 074H, 03AH, 032H, 080H, 0B7H, 0C2H, 057H
	DEFB	072H, 0CDH, 0CBH, 074H, 0C3H, 044H, 072H, 03EH
	DEFB	001H, 032H, 060H, 080H, 0CDH, 062H, 072H, 0C3H
	DEFB	003H, 074H, 03EH, 00AH, 021H, 000H, 000H, 0CDH
	DEFB	0AAH, 072H, 0CAH, 07CH, 072H, 03EH, 00BH, 0CDH
	DEFB	0AAH, 072H, 0CAH, 078H, 072H, 0C3H, 00FH, 070H
	DEFB	02AH, 000H, 000H, 0E9H, 021H, 000H, 000H, 011H
	DEFB	060H, 00BH, 019H, 011H, 020H, 000H, 019H, 001H
	DEFB	000H, 00DH, 078H, 0BCH, 0DAH, 000H, 070H, 07EH
	DEFB	0B7H, 0CAH, 083H, 072H, 0CDH, 02DH, 070H, 0C2H
	DEFB	000H, 070H, 011H, 020H, 000H, 019H, 07EH, 0B7H
	DEFB	0CAH, 000H, 070H, 0CDH, 03EH, 070H, 0C2H, 000H
	DEFB	070H, 0C9H, 011H, 002H, 000H, 019H, 0EBH, 001H
	DEFB	071H, 070H, 021H, 006H, 000H, 0FEH, 00AH, 0CAH
	DEFB	0C0H, 072H, 001H, 077H, 070H, 021H, 006H, 000H
	DEFB	0CDH, 05CH, 070H, 0C9H, 03EH, 00BH, 021H, 000H
	DEFB	020H, 0CDH, 0AAH, 072H, 0CAH, 0D2H, 072H, 0C3H
	DEFB	01EH, 070H, 02AH, 000H, 020H, 0E9H, 01AH, 007H
	DEFB	034H, 007H, 00FH, 00EH, 01AH, 00EH, 008H, 01BH
	DEFB	00FH, 01BH, 000H, 000H, 008H, 035H, 010H, 007H
	DEFB	020H, 007H, 009H, 00EH, 010H, 00EH, 005H, 01BH
	DEFB	009H, 01BH, 000H, 000H, 005H, 035H, 000H, 000H
	DEFB	000H, 000H, 000H, 000H, 000H, 000H, 000H, 000H
	DEFB	0C6H, 073H, 0C6H, 073H, 0C6H, 073H, 0C6H, 073H
	DEFB	0C6H, 073H, 0C6H, 073H, 0BBH, 073H, 0C2H, 073H
	DEFB	0C6H, 073H, 0C6H, 073H, 0C6H, 073H, 0C6H, 073H
	DEFB	0C6H, 073H, 0C6H, 073H, 0C6H, 073H, 0C6H, 073H
	DEFB	000H, 000H, 022H, 065H, 080H, 021H, 000H, 000H
	DEFB	039H, 022H, 01EH, 080H, 0C5H, 0EBH, 079H, 0E6H
	DEFB	07FH, 032H, 034H, 080H, 078H, 0E6H, 07FH, 032H
	DEFB	032H, 080H, 0CCH, 0CBH, 074H, 078H, 0E6H, 080H
	DEFB	0CAH, 045H, 073H, 03EH, 001H, 032H, 033H, 080H
	DEFB	0CDH, 025H, 074H, 0C1H, 0F5H, 078H, 0E6H, 07FH
	DEFB	0C2H, 05BH, 073H, 03EH, 001H, 032H, 032H, 080H
	DEFB	0CDH, 0CBH, 074H, 0F1H, 0AFH, 02AH, 01EH, 080H
	DEFB	0F9H, 0C9H, 0F5H, 0DBH, 001H, 0E5H, 0D5H, 0C5H
	DEFB	03EH, 006H, 0D3H, 0FAH, 03EH, 007H, 0D3H, 0FAH
	DEFB	0D3H, 0FCH, 02AH, 0D5H, 07FH, 011H, 000H, 078H
	DEFB	019H, 07DH, 0D3H, 0F4H, 07CH, 0D3H, 0F4H, 07DH
	DEFB	02FH, 06FH, 07CH, 02FH, 067H, 023H, 011H, 0CFH
	DEFB	007H, 019H, 011H, 000H, 078H, 019H, 07DH, 0D3H
	DEFB	0F5H, 07CH, 0D3H, 0F5H, 021H, 000H, 078H, 07DH
	DEFB	0D3H, 0F6H, 07CH, 0D3H, 0F6H, 021H, 0CFH, 007H
	DEFB	07DH, 0D3H, 0F7H, 07CH, 0D3H, 0F7H, 03EH, 002H
	DEFB	0D3H, 0FAH, 03EH, 003H, 0D3H, 0FAH, 0C1H, 0D1H
	DEFB	0E1H, 03EH, 0D7H, 0D3H, 00EH, 03EH, 001H, 0D3H
	DEFB	00EH, 0F1H, 0C9H, 0F3H, 0CDH, 062H, 073H, 0FBH
	DEFB	0EDH, 04DH, 0F3H, 0C3H, 070H, 077H, 0FBH, 0EDH
	DEFB	04DH, 032H, 003H, 080H, 0FBH, 03AH, 060H, 080H
	DEFB	0E6H, 001H, 0C2H, 05DH, 073H, 0D3H, 01CH, 0CDH
	DEFB	0DEH, 073H, 0B7H, 0C3H, 0DAH, 073H, 001H, 000H
	DEFB	078H, 011H, 0F0H, 073H, 021H, 012H, 000H, 01AH
	DEFB	002H, 003H, 013H, 02DH, 0C2H, 0E7H, 073H, 0C9H
	DEFB	02AH, 02AH, 044H, 049H, 053H, 04BH, 045H, 054H
	DEFB	054H, 045H, 020H, 045H, 052H, 052H, 04FH, 052H
	DEFB	02AH, 02AH, 020H, 03AH, 020H, 073H, 0E6H, 080H
	DEFB	021H, 060H, 080H, 0B6H, 077H, 035H, 0CDH, 0CBH
	DEFB	074H, 021H, 000H, 000H, 022H, 065H, 080H, 021H
	DEFB	000H, 073H, 0CDH, 025H, 074H, 03EH, 001H, 032H
	DEFB	060H, 080H, 0C3H, 000H, 010H, 03EH, 000H, 022H
	DEFB	069H, 080H, 0CDH, 021H, 077H, 0DAH, 0C4H, 072H
	DEFB	0CAH, 038H, 074H, 03EH, 006H, 0C3H, 0C9H, 073H
	DEFB	0CDH, 081H, 074H, 03EH, 006H, 00EH, 005H, 0CDH
	DEFB	083H, 075H, 0D2H, 04AH, 074H, 03EH, 028H, 0C3H
	DEFB	0C9H, 073H, 02AH, 067H, 080H, 0EBH, 02AH, 065H
	DEFB	080H, 019H, 022H, 065H, 080H, 02EH, 000H, 065H
	DEFB	022H, 067H, 080H, 0CDH, 066H, 074H, 03AH, 061H
	DEFB	080H, 0B7H, 0C8H, 0C3H, 02AH, 074H, 03EH, 001H
	DEFB	032H, 034H, 080H, 03AH, 020H, 073H, 0E6H, 002H
	DEFB	00FH, 021H, 033H, 080H, 0BEH, 0CAH, 07AH, 074H
	DEFB	034H, 0C9H, 0AFH, 077H, 021H, 032H, 080H, 034H
	DEFB	0C9H, 02AH, 069H, 080H, 0E5H, 0CDH, 047H, 075H
	DEFB	0CDH, 0AEH, 074H, 0D1H, 019H, 0D2H, 09EH, 074H
	DEFB	07CH, 0B5H, 0CAH, 09EH, 074H, 03EH, 001H, 032H
	DEFB	061H, 080H, 022H, 069H, 080H, 0C9H, 03EH, 000H
	DEFB	032H, 061H, 080H, 032H, 069H, 080H, 032H, 06AH
	DEFB	080H, 0EBH, 022H, 067H, 080H, 0C9H, 0F5H, 07DH
	DEFB	02FH, 06FH, 07CH, 02FH, 067H, 023H, 0F1H, 0C9H
	DEFB	03AH, 020H, 073H, 0E6H, 01CH, 01FH, 01FH, 0E6H
	DEFB	007H, 032H, 035H, 080H, 0CDH, 00AH, 075H, 0CDH
	DEFB	047H, 075H, 0C9H, 03AH, 020H, 073H, 0E6H, 0FEH
	DEFB	032H, 020H, 073H, 0CDH, 021H, 077H, 0C2H, 008H
	DEFB	075H, 02EH, 004H, 026H, 000H, 022H, 067H, 080H
	DEFB	03EH, 00AH, 00EH, 001H, 0CDH, 083H, 075H, 021H
	DEFB	020H, 073H, 0D2H, 0F7H, 074H, 07EH, 0E6H, 001H
	DEFB	0C2H, 008H, 075H, 034H, 0C3H, 0D3H, 074H, 03AH
	DEFB	016H, 080H, 007H, 007H, 047H, 07EH, 0E6H, 0E3H
	DEFB	080H, 077H, 0CDH, 0B8H, 074H, 037H, 03FH, 0C9H
	DEFB	037H, 0C9H, 03AH, 035H, 080H, 017H, 017H, 05FH
	DEFB	016H, 000H, 021H, 0D6H, 072H, 03AH, 020H, 073H
	DEFB	0E6H, 080H, 03EH, 04CH, 0CAH, 024H, 075H, 03EH
	DEFB	023H, 021H, 0E6H, 072H, 032H, 00CH, 080H, 019H
	DEFB	03AH, 020H, 073H, 0E6H, 001H, 0CAH, 035H, 075H
	DEFB	01EH, 002H, 016H, 000H, 019H, 0EBH, 021H, 036H
	DEFB	080H, 01AH, 077H, 032H, 00DH, 080H, 023H, 013H
	DEFB	01AH, 077H, 023H, 03EH, 080H, 077H, 0C9H, 021H
	DEFB	080H, 000H, 03AH, 035H, 080H, 0B7H, 0CAH, 056H
	DEFB	075H, 029H, 03DH, 0C2H, 051H, 075H, 022H, 039H
	DEFB	080H, 0EBH, 03AH, 034H, 080H, 06FH, 03AH, 036H
	DEFB	080H, 095H, 03CH, 06FH, 03AH, 060H, 080H, 0E6H
	DEFB	080H, 0CAH, 076H, 075H, 03AH, 033H, 080H, 0EEH
	DEFB	001H, 0C2H, 076H, 075H, 02EH, 00AH, 07DH, 02EH
	DEFB	000H, 065H, 019H, 03DH, 0C2H, 07AH, 075H, 022H
	DEFB	067H, 080H, 0C9H, 0F5H, 079H, 032H, 062H, 080H
	DEFB	0CDH, 09DH, 076H, 02AH, 067H, 080H, 044H, 04DH
	DEFB	00BH, 02AH, 065H, 080H, 0F1H, 0F5H, 0E6H, 00FH
	DEFB	0FEH, 00AH, 0C4H, 032H, 076H, 0F1H, 04FH, 0CDH
	DEFB	0DDH, 075H, 03EH, 0FFH, 0CDH, 0C3H, 076H, 0D8H
	DEFB	079H, 0CDH, 0B3H, 075H, 0D0H, 0C8H, 079H, 0F5H
	DEFB	0C3H, 088H, 075H, 021H, 010H, 080H, 07EH, 0E6H
	DEFB	0C3H, 047H, 03AH, 01BH, 080H, 0B8H, 0C2H, 0D4H
	DEFB	075H, 023H, 07EH, 0FEH, 000H, 0C2H, 0D4H, 075H
	DEFB	023H, 07EH, 0E6H, 0BFH, 0FEH, 000H, 0C2H, 0D4H
	DEFB	075H, 037H, 03FH, 0C9H, 03AH, 062H, 080H, 03DH
	DEFB	032H, 062H, 080H, 037H, 0C9H, 0C5H, 0F5H, 0F3H
	DEFB	03EH, 0FFH, 021H, 030H, 080H, 032H, 00BH, 080H
	DEFB	03AH, 020H, 073H, 0E6H, 001H, 0CAH, 0F2H, 075H
	DEFB	03EH, 040H, 047H, 0F1H, 0F5H, 080H, 077H, 023H
	DEFB	0CDH, 0A4H, 076H, 077H, 02BH, 0F1H, 0E6H, 00FH
	DEFB	0FEH, 006H, 00EH, 009H, 0CAH, 009H, 076H, 00EH
	DEFB	002H, 07EH, 023H, 0CDH, 03CH, 076H, 00DH, 0C2H
	DEFB	009H, 076H, 0C1H, 0FBH, 0C9H, 03EH, 005H, 0F3H
	DEFB	0D3H, 0FAH, 03EH, 049H, 0D3H, 0FBH, 0D3H, 0FCH
	DEFB	07DH, 0D3H, 0F2H, 07CH, 0D3H, 0F2H, 079H, 0D3H
	DEFB	0F3H, 078H, 0D3H, 0F3H, 03EH, 001H, 0D3H, 0FAH
	DEFB	0FBH, 0C9H, 03EH, 005H, 0F3H, 0D3H, 0FAH, 03EH
	DEFB	045H, 0C3H, 01CH, 076H, 0F5H, 0C5H, 006H, 000H
	DEFB	00EH, 000H, 004H, 0CCH, 06AH, 076H, 0DBH, 004H
	DEFB	0E6H, 0C0H, 0FEH, 080H, 0C2H, 042H, 076H, 0C1H
	DEFB	0F1H, 0D3H, 005H, 0C9H, 0C5H, 006H, 000H, 00EH
	DEFB	000H, 004H, 0CCH, 06AH, 076H, 0DBH, 004H, 0E6H
	DEFB	0C0H, 0FEH, 0C0H, 0C2H, 059H, 076H, 0C1H, 0DBH
	DEFB	005H, 0C9H, 006H, 000H, 00CH, 0C0H, 0FBH, 0C3H
	DEFB	0C4H, 072H, 03EH, 004H, 0CDH, 03CH, 076H, 03AH
	DEFB	01BH, 080H, 0CDH, 03CH, 076H, 0CDH, 054H, 076H
	DEFB	032H, 010H, 080H, 0C9H, 03EH, 008H, 0CDH, 03CH
	DEFB	076H, 0CDH, 054H, 076H, 032H, 010H, 080H, 0E6H
	DEFB	0C0H, 0FEH, 080H, 0CAH, 09CH, 076H, 0CDH, 054H
	DEFB	076H, 032H, 011H, 080H, 0C9H, 0F3H, 0AFH, 032H
	DEFB	041H, 080H, 0FBH, 0C9H, 0D5H, 03AH, 033H, 080H
	DEFB	017H, 017H, 057H, 03AH, 01BH, 080H, 082H, 0D1H
	DEFB	0C9H, 0F5H, 0E5H, 061H, 02EH, 0FFH, 02BH, 07DH
	DEFB	0B4H, 0C2H, 0B6H, 076H, 005H, 0C2H, 0B3H, 076H
	DEFB	0E1H, 0F1H, 0C9H, 0C5H, 03DH, 037H, 0CAH, 0DFH
	DEFB	076H, 006H, 001H, 00EH, 001H, 0CDH, 0B1H, 076H
	DEFB	047H, 03AH, 041H, 080H, 0E6H, 002H, 078H, 0CAH
	DEFB	0C4H, 076H, 037H, 03FH, 0CDH, 09DH, 076H, 0C1H
	DEFB	0C9H, 03EH, 0FFH, 0CDH, 0C3H, 076H, 03AH, 010H
	DEFB	080H, 047H, 03AH, 011H, 080H, 04FH, 0C9H, 03EH
	DEFB	007H, 0CDH, 03CH, 076H, 03AH, 01BH, 080H, 0CDH
	DEFB	03CH, 076H, 0C9H, 03EH, 00FH, 0CDH, 03CH, 076H
	DEFB	07AH, 0E6H, 007H, 0CDH, 03CH, 076H, 07BH, 0CDH
	DEFB	03CH, 076H, 0C9H, 0CDH, 0EFH, 076H, 0CDH, 0E1H
	DEFB	076H, 0D8H, 03AH, 01BH, 080H, 0C6H, 020H, 0B8H
	DEFB	0C2H, 01EH, 077H, 079H, 0FEH, 000H, 037H, 03FH
	DEFB	0C9H, 03AH, 032H, 080H, 05FH, 0CDH, 0A4H, 076H
	DEFB	057H, 0CDH, 0FBH, 076H, 0CDH, 0E1H, 076H, 0D8H
	DEFB	03AH, 01BH, 080H, 0C6H, 020H, 0B8H, 0C2H, 03DH
	DEFB	077H, 03AH, 032H, 080H, 0B9H, 037H, 03FH, 0C9H
	DEFB	021H, 010H, 080H, 006H, 007H, 078H, 032H, 00BH
	DEFB	080H, 0CDH, 054H, 076H, 077H, 023H, 03AH, 01DH
	DEFB	080H, 03DH, 0C2H, 051H, 077H, 0DBH, 004H, 0E6H
	DEFB	010H, 0CAH, 065H, 077H, 005H, 0C2H, 049H, 077H
	DEFB	03EH, 0FEH, 0C3H, 0C9H, 073H, 0DBH, 0F8H, 077H
	DEFB	005H, 0C8H, 0FBH, 03EH, 0FDH, 0C3H, 0C9H, 073H
	DEFB	0F5H, 0C5H, 0E5H, 03EH, 002H, 032H, 041H, 080H
	DEFB	03AH, 01CH, 080H, 03DH, 0C2H, 07BH, 077H, 0DBH
	DEFB	004H, 0E6H, 010H, 0C2H, 08CH, 077H, 0CDH, 084H
	DEFB	076H, 0C3H, 08FH, 077H, 0CDH, 040H, 077H, 0E1H
	DEFB	0C1H, 0F1H, 0FBH, 0EDH, 04DH, 000H, 000H

	.DEPHASE			; End of relocated section

	END
