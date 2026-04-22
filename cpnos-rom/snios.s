; cpnos-rom SNIOS (Slave Network I/O System)
;
; Ported from cpnet/snios.asm (DRI binary serial protocol) to GNU-as
; syntax for clang integrated assembly.  Two adaptations vs the DRI
; source:
;
;  1. Character I/O goes direct to the C transport layer
;     (_transport_send_byte / _transport_recv_byte), not through
;     hardcoded BIOS READER/PUNCH/READS vectors.  There is no
;     ring-buffered BIOS reader in cpnos-rom — transport_sio.c is the
;     byte layer.
;
;  2. CFGTBL lives in cfgtbl.c (as `_cfgtbl`) — this file references it
;     via `extern`.  MSGBUF is at `_cfgtbl + 45`.  Local scratch
;     (MSGADR, RETCNT) is kept here in .resident.data.
;
; Wire protocol is unchanged:
;   Send: ENQ -> ACK -> SOH+header+HCS -> ACK -> STX+data+ETX+CKS+EOT -> ACK
;   Recv: same, inverted
;
; Transport ABI (from llvm-z80 clang, confirmed via disasm):
;   _transport_send_byte:  arg in A, clobbers A/D, returns void
;   _transport_recv_byte:  arg (timeout_ticks) in HL; returns in DE
;                          (D=0, E=byte) on success, DE=0xFFFF on timeout
;
; Jump table is exposed at `_snios_jt` (first 24 bytes of the SNIOS
; resident chunk).  NDOS reaches it via its hook into the CP/NOS cold
; boot sequence (wiring is next session's work).

; Protocol constants
    .equ SOH, 0x01
    .equ STX, 0x02
    .equ ETX, 0x03
    .equ EOT, 0x04
    .equ ENQ, 0x05
    .equ ACK, 0x06
    .equ NAK, 0x15

; Retry / timeout parameters
    .equ MAXRETRY, 10
    .equ TMRETRY,  100
    .equ RECV_TIMEOUT_TICKS, 0x8000

; Network status byte flags
    .equ ACTIVE, 0b00010000
    .equ RCVERR, 0b00000010
    .equ SNDERR, 0b00000001

; CFGTBL field offsets (must match cfgtbl.c layout)
    .equ CFG_NETST,   0
    .equ CFG_SLAVEID, 1
    .equ CFG_SIZ,     43
    .equ CFG_MSGBUF,  45

    .extern _cfgtbl
    .extern _transport_send_byte
    .extern _transport_recv_byte

;----------------------------------------------------------------
;  SNIOS jump table  (first 24 bytes — public ABI for NDOS)
;----------------------------------------------------------------
    .section .resident.snios_jt,"ax",@progbits
    .global _snios_jt
    .global _snios_ntwkin, _snios_ntwkst, _snios_cnftbl
    .global _snios_sndmsg, _snios_rcvmsg
    .global _snios_ntwker, _snios_ntwkbt, _snios_ntwkdn

_snios_jt:
_snios_ntwkin:  jp NTWKIN       ; +00 NETWORK INITIALIZATION
_snios_ntwkst:  jp NTWKST       ; +03 NETWORK STATUS
_snios_cnftbl:  jp CNFTBL       ; +06 RETURN CONFIG TABLE ADDRESS
_snios_sndmsg:  jp SNDMSG       ; +09 SEND MESSAGE ON NETWORK
_snios_rcvmsg:  jp RCVMSG       ; +0C RECEIVE MESSAGE FROM NETWORK
_snios_ntwker:  jp NTWKER       ; +0F NETWORK ERROR
_snios_ntwkbt:  jp NTWKBT       ; +12 NETWORK WARM BOOT
_snios_ntwkdn:  jp NTWKDN       ; +15 NETWORK SHUTDOWN

;----------------------------------------------------------------
;  SNIOS body
;----------------------------------------------------------------
    .section .resident.snios,"ax",@progbits

;----------------------------------------------------------------
;  C-callable wrappers.
;
;  The SNIOS jump table is the DRI ABI — NDOS passes the message
;  buffer pointer in BC.  cpnos-rom C code uses sdcccall(1), which
;  passes the first 16-bit arg in HL.  These wrappers bridge the
;  two conventions without disturbing the DRI-facing entries.
;----------------------------------------------------------------
    .global _snios_sndmsg_c
_snios_sndmsg_c:
    ld   b, h
    ld   c, l
    jp   SNDMSG

    .global _snios_rcvmsg_c
_snios_rcvmsg_c:
    ld   b, h
    ld   c, l
    jp   RCVMSG

;================================================
;= CHARACTER I/O WRAPPERS                       =
;= Direct calls into _transport_* (SIO-A)        =
;================================================

; SENDBY - Send byte in A via transport.
; Preserves: HL, DE (protocol loop counters and checksum must survive).
SENDBY:
    push hl
    push de
    call _transport_send_byte       ; arg already in A
    pop  de
    pop  hl
    ret

; RECVBY - Receive one byte, busy wait (no timeout).
; Returns: A = byte, CY clear.  Preserves HL, DE.
RECVBY:
    push hl
    push de
RECVBY1:
    ld   hl, 0xFFFF                 ; max timeout per call
    call _transport_recv_byte
    ld   a, d
    inc  a                          ; D=0xFF -> A=0 (timeout); D=0 -> A=1
    jr   z, RECVBY1                 ; timeout: retry forever
    ld   a, e                       ; got byte
    pop  de
    pop  hl
    or   a                          ; clear carry
    ret

; RECVBT - Receive one byte with timeout.
; Returns: A = byte, CY clear on success; CY set on timeout.
RECVBT:
    push de
    push hl
    ld   hl, RECV_TIMEOUT_TICKS
    call _transport_recv_byte
    ld   a, d
    inc  a                          ; D=0xFF -> Z (timeout)
    jr   z, RECVBT_TMO
    ld   a, e
    pop  hl
    pop  de
    or   a                          ; clear carry (success)
    ret
RECVBT_TMO:
    pop  hl
    pop  de
    scf
    ret

;================================================
;= CHECKSUM UTILITIES                           =
;= D = running checksum accumulator             =
;================================================

; NETOUT / PREOUT - Send byte C, accumulate checksum in D
NETOUT:
PREOUT:
    ld   a, d
    add  a, c
    ld   d, a                       ; update checksum
    ld   a, c
    jp   SENDBY

; NETIN - Receive byte, accumulate checksum in D
; Returns: A = byte, D updated, Z from checksum; CY set on timeout.
NETIN:
    call RECVBY
    ld   b, a
    add  a, d
    ld   d, a
    or   a                          ; Z flag from checksum
    ld   a, b
    ret

; MSGIN - Receive E bytes into (HL), accumulate checksum in D.
; Returns CY set on timeout.
MSGIN:
    call NETIN
    ret  c
    ld   (hl), a
    inc  hl
    dec  e
    jr   nz, MSGIN
    ret

; MSGOUT - Send preamble C, then E bytes from (HL); init checksum in D.
MSGOUT:
    ld   d, 0
    call PREOUT
MSOLP:
    ld   c, (hl)
    inc  hl
    call NETOUT
    dec  e
    jr   nz, MSOLP
    ret

;================================================
;= SNDMSG - SEND MESSAGE ON NETWORK             =
;================================================
; BC = message buffer address
; Returns: A = 0 on success, 0xFF on error
SNDMSG:
    ld   a, (_cfgtbl + CFG_NETST)
    and  ACTIVE
    jp   z, SNDERR1                 ; not active
SNDMS0:
    ld   h, b
    ld   l, c
    ld   (MSGADR), hl
    ; -- BDOS/CP-NET function trace (per-FNC saturating uint8) --
    ; Counter table at 0xEC80..0xECFF; FNC byte is at msgbuf+3.
    ; Additionally, 16-bit counter for FNC=20 (READ_SEQ) at
    ; 0xEC7E..0xEC7F — so we can see if it exceeds 256.
    push af
    push hl
    push bc
    inc  hl
    inc  hl
    inc  hl                         ; HL = msgbuf+3 = FNC
    ld   a, (hl)
    push af                         ; save raw FNC
    and  0x7f                       ; clamp 0..127
    ld   l, a
    ld   h, 0xec
    set  7, l                       ; HL = 0xEC80 | (FNC & 0x7F)
    ld   a, (hl)
    inc  a
    jr   z, 1f                      ; saturate at 0xFF
    ld   (hl), a
1:  pop  af                         ; restore raw FNC
    cp   20                         ; READ_SEQ?
    jr   nz, 2f
    ld   hl, 0xec7e
    inc  (hl)
    jr   nz, 2f
    inc  hl
    inc  (hl)
2:  pop  bc
    pop  hl
    pop  af
    ; Ensure SID is correct
    ld   a, (_cfgtbl + CFG_SLAVEID)
    inc  bc
    inc  bc
    ld   (bc), a                    ; store SID in msg[2]

RESEND:
    ld   a, MAXRETRY
    ld   (RETCNT), a
SEND:
    ld   hl, (MSGADR)
    ; Send ENQ
    ld   a, ENQ
    call SENDBY
    ; Wait for ACK (with timeout retries)
    ld   d, TMRETRY
ENQRSP:
    call RECVBT
    jr   nc, GOTENQ
    dec  d
    jr   nz, ENQRSP
    jr   SNDTMO
GOTENQ:
    call CHKACK
    ; Send SOH + 5 header bytes + HCS
    ld   c, SOH
    ld   e, 5
    call MSGOUT                     ; SOH FMT DID SID FNC SIZ
    ; Send header checksum (two's complement of running sum)
    xor  a
    sub  d
    ld   c, a
    call NETOUT
    ; Wait for ACK
    call GETACK
    ; Send STX + data bytes + ETX + CKS + EOT
    dec  hl                         ; back to SIZ field
    ld   e, (hl)
    inc  hl
    inc  e                          ; 0 means 1 byte
    ld   c, STX
    call MSGOUT
    ld   c, ETX
    call PREOUT                     ; ETX is part of checksum
    xor  a
    sub  d
    ld   c, a
    call NETOUT                     ; CKS
    ld   a, EOT
    call SENDBY
    call GETACK
    ret                             ; A=0 success (from CHKACK)

; GETACK - Wait for ACK, retry on timeout or NAK.
GETACK:
    call RECVBT
    jr   c, SNDRET                  ; timeout -> retry
CHKACK:
    and  0x7F
    sub  ACK
    ret  z                          ; got ACK, A=0
; Fall through to retry
SNDRET:
    pop  hl                         ; discard return address
    ld   hl, RETCNT
    dec  (hl)
    jr   nz, SEND
SNDTMO:
    ld   a, SNDERR
    jp   ERRRTN

;================================================
;= RCVMSG - RECEIVE MESSAGE FROM NETWORK        =
;================================================
; BC = message buffer address
; Returns: A = 0 on success, 0xFF on error
RCVMSG:
    ld   a, (_cfgtbl + CFG_NETST)
    and  ACTIVE
    jp   z, SNDERR1
RCVMS0:
    ld   h, b
    ld   l, c
    ld   (MSGADR), hl

RERCV:
    ld   a, MAXRETRY
    ld   (RETCNT), a
RECALL:
    call RECV
    ld   hl, RETCNT
    dec  (hl)
    jr   nz, RECALL
RCVTMO:
    ld   a, RCVERR
    jp   ERRRTN

RECV:
    ld   hl, (MSGADR)
    ; Wait for ENQ (with timeout retries)
    ld   d, TMRETRY
RCVFST:
    call RECVBT
    jr   nc, GOTFST
    dec  d
    jr   nz, RCVFST
    pop  hl                         ; discard RECALL return
    jr   RCVTMO
GOTFST:
    and  0x7F
    cp   ENQ
    jr   nz, RECV                   ; not ENQ, keep looking

    ; Got ENQ, send ACK
    ld   a, ACK
    call SENDBY

    ; Receive SOH
    call RECVBY
    ret  c
    and  0x7F
    cp   SOH
    ret  nz                         ; not SOH -> retry
    ld   d, a                       ; init HCS with SOH

    ; Receive 5 header bytes
    ld   e, 5
    call MSGIN
    ret  c

    ; Receive and check HCS
    call NETIN
    ret  c
    jr   nz, BADCKS

    ; Header OK, send ACK
    call SNDACK

    ; Receive STX
    call RECVBY
    ret  c
    and  0x7F
    cp   STX
    ret  nz
    ld   d, a                       ; init CKS with STX

    ; Get data length from SIZ field (HL points past header)
    dec  hl
    ld   e, (hl)
    inc  hl
    inc  e                          ; 0 means 1 byte

    ; Receive data bytes
    call MSGIN
    ret  c

    ; Receive ETX
    call RECVBY
    ret  c
    and  0x7F
    cp   ETX
    ret  nz
    add  a, d
    ld   d, a                       ; fold ETX into CKS

    ; Receive and check data checksum
    call NETIN
    ret  c
    ; Receive EOT
    call RECVBY
    ret  c
    and  0x7F
    cp   EOT
    ret  nz
    ld   a, d
    or   a
    jr   nz, BADCKS

    ; Message received OK
    pop  hl                         ; discard RECALL return
    ; Check DID matches our node
    ld   hl, (MSGADR)
    inc  hl                         ; -> DID
    ld   a, (_cfgtbl + CFG_SLAVEID)
    inc  a                          ; 0xFF -> 0 (accept any during init)
    jr   z, SNDACK
    dec  a
    sub  (hl)
    jr   z, SNDACK                  ; DID matches, A=0
    ld   a, 0xFF                    ; bad DID
SNDACK:
    push af
    ld   a, ACK
    call SENDBY
    pop  af
    ret

BADCKS:
    ld   a, NAK
    jp   SENDBY                     ; send NAK and return to retry

;================================================
;= ERROR HANDLING                                =
;================================================
ERRRTN:
    ld   hl, _cfgtbl + CFG_NETST
    or   (hl)
    ld   (hl), a                    ; set error bit in status
    call NTWKER                     ; device re-init if needed
SNDERR1:
    ld   a, 0xFF
    ret

;================================================
;= NTWKIN - NETWORK INITIALIZATION               =
;================================================
; CP/NET 1.2: no handshake needed.  Drain any stale bytes, set SLAVEID
; and the ACTIVE flag.  Login is handled by NDOS (FNC=64).
NTWKIN:
    ; Drain any bytes buffered during boot.  transport_recv_byte with a
    ; tiny timeout returns promptly when the SIO RX buffer is empty.
NTWKDR:
    ld   hl, 64                     ; small timeout per poll
    call _transport_recv_byte
    ld   a, d
    inc  a
    jr   nz, NTWKDR                 ; got a byte, keep draining
    ; SLAVEID is already seeded in cfgtbl.c from the -DRC702_SLAVEID=
    ; build flag, so (unlike the DRI original at CFGTBL+1=0xFF) we don't
    ; need to rewrite it here.
    ; Mark network active.
    ld   a, ACTIVE
    ld   (_cfgtbl + CFG_NETST), a
    xor  a
    ld   (_cfgtbl + CFG_SIZ), a     ; clear SIZ — discard LST output
    ret                             ; A=0 success

;================================================
;= Remaining entry points                        =
;================================================

; NTWKST - Return network status (clears error bits after read).
NTWKST:
    ld   a, (_cfgtbl + CFG_NETST)
    ld   b, a
    and  0xFF - (RCVERR | SNDERR)   ; clear RX/TX error bits
    ld   (_cfgtbl + CFG_NETST), a
    ld   a, b
    ret

; CNFTBL - Return configuration table address in HL.
CNFTBL:
    ld   hl, _cfgtbl
    ret

; NTWKBT - Warm boot hook.
NTWKBT:
    xor  a
    ret

; NTWKER - Network error handler (device re-init if needed).
NTWKER:
    ret

; NTWKDN - Network shutdown.  Sends FNC=0xFE to the server.
NTWKDN:
    ld   ix, _cfgtbl + CFG_MSGBUF
    ld   (ix+0), 0                  ; FMT = 0
    ld   (ix+3), 0xFE               ; FNC = 254 (shutdown)
    ld   (ix+4), 0                  ; SIZ = 0
    ld   bc, _cfgtbl + CFG_MSGBUF
    call SNDMS0                     ; bypass ACTIVE check
    xor  a
    ret

;----------------------------------------------------------------
;  C-ABI trampoline: `void jump_to(uint16_t addr)` — tail-calls
;  through HL (sdcccall(1) first 16-bit arg).  Replaces clang's
;  __call_iy helper which lives in PROM0 at 0x0009 and dies after
;  PROM disable.  Lives in .resident so it survives the OUT (0x18)
;  unmap.
;----------------------------------------------------------------
    .global _jump_to
_jump_to:
    jp   (hl)

;----------------------------------------------------------------
;  Local scratch — lives in .resident.data so it is 0-initialised
;  at LMA time and becomes RAM at VMA.
;----------------------------------------------------------------
    .section .resident.data,"aw",@progbits
MSGADR: .2byte 0
RETCNT: .byte 0
