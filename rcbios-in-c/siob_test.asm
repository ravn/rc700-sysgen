; siob_test.asm — SIO-B receive test for RC700 CP/M
;
; Sets IOBYTE RDR:=UR1 (SIO-B), reads bytes via BIOS READER entry,
; prints each as hex to console, then checks for marker string.
; Prints PASS or FAIL and exits to CP/M.
;
; Does NOT use PIP or STAT — calls BIOS directly.
;
; Build:  zmac -z siob_test.asm
; Output: zout/siob_test.cim (rename to SIOBTEST.COM)

        .z80
        org     0100h

; BIOS entry points (56K, BIOS at 0xDA00)
BIOS    equ     0DA00h
CONOUT  equ     BIOS + 0Ch      ; C = char
READER  equ     BIOS + 15h      ; returns A = byte from RDR:
READS   equ     BIOS + 4Dh      ; returns A = FF if data ready, 0 if not

; CP/M
BDOS    equ     0005h
IOBYTE  equ     0003h
C_WRITE equ     02h
C_PRINT equ     09h

; IOBYTE RDR: field is bits 3:2
; UR1 (SIO-B) = value 2 in bits 3:2 = 0x08
IOB_RDR_MASK equ 0Ch           ; bits 3:2
IOB_RDR_UR1  equ 08h           ; value 2 << 2

start:
        ; Print banner
        ld      de, msg_banner
        ld      c, C_PRINT
        call    BDOS

        ; Set IOBYTE RDR: = UR1 (SIO-B)
        ld      a, (IOBYTE)
        and     ~IOB_RDR_MASK   ; clear RDR field
        or      IOB_RDR_UR1     ; set to UR1
        ld      (IOBYTE), a

        ; Print "IOBYTE="
        ld      de, msg_iobyte
        ld      c, C_PRINT
        call    BDOS
        ld      a, (IOBYTE)
        call    puthex
        call    putcrlf

        ; Read up to 128 bytes from READER, stop on Ctrl-Z (0x1A)
        ; or after 128 bytes, whichever comes first.
        ld      hl, rxdata      ; store received data here
        ld      b, 128          ; max bytes to read

        ; Wait up to ~10 seconds for first byte (500 polls with HALT)
        ld      de, 500
wait_first:
        call    READS
        or      a
        jr      nz, read_loop
        ei
        halt                    ; yield to ISRs
        dec     de
        ld      a, d
        or      e
        jr      nz, wait_first

        ; Timeout — no data received
        ld      de, msg_timeout
        ld      c, C_PRINT
        call    BDOS
        jr      fail

read_loop:
        call    READER          ; A = byte from SIO-B
        cp      1Ah             ; Ctrl-Z?
        jr      z, read_done
        ld      (hl), a         ; store
        inc     hl
        djnz    read_loop

read_done:
        ; HL points past last byte, B = remaining count
        ld      a, 128
        sub     b
        ld      (rxlen), a      ; save received length

        ; Print received data as hex
        ld      de, msg_received
        ld      c, C_PRINT
        call    BDOS
        ld      a, (rxlen)
        call    puthex
        ld      de, msg_bytes
        ld      c, C_PRINT
        call    BDOS

        ; Print received data as ASCII
        ld      de, msg_data
        ld      c, C_PRINT
        call    BDOS
        ld      hl, rxdata
        ld      a, (rxlen)
        or      a
        jr      z, check_marker
        ld      b, a
print_data:
        ld      a, (hl)
        cp      20h
        jr      c, skip_nonprint ; skip control chars
        ld      c, a
        push    hl
        push    bc
        ld      e, c
        ld      c, C_WRITE
        call    BDOS
        pop     bc
        pop     hl
skip_nonprint:
        inc     hl
        djnz    print_data
        call    putcrlf

check_marker:
        ; Check if received data contains "SIOB-IOBYTE-TEST-OK"
        ld      a, (rxlen)
        cp      19              ; marker is 19 bytes
        jr      c, fail         ; too short

        ld      hl, rxdata
        ld      de, marker
        ld      b, 19
cmp_loop:
        ld      a, (de)
        cp      (hl)
        jr      nz, fail
        inc     hl
        inc     de
        djnz    cmp_loop

        ; PASS
        ld      de, msg_pass
        ld      c, C_PRINT
        call    BDOS
        jr      restore

fail:
        ld      de, msg_fail
        ld      c, C_PRINT
        call    BDOS

restore:
        ; Restore IOBYTE RDR: to PTR (SIO-A, value 0)
        ld      a, (IOBYTE)
        and     ~IOB_RDR_MASK
        ld      (IOBYTE), a

        ; Return to CP/M
        rst     0

; ---- Subroutines ----

; Print A as 2 hex digits
puthex:
        push    af
        rrca
        rrca
        rrca
        rrca
        call    putnib
        pop     af
putnib:
        and     0Fh
        add     a, '0'
        cp      '9'+1
        jr      c, putnib_out
        add     a, 'A'-'0'-10
putnib_out:
        ld      e, a
        ld      c, C_WRITE
        call    BDOS
        ret

putcrlf:
        ld      e, 13
        ld      c, C_WRITE
        call    BDOS
        ld      e, 10
        ld      c, C_WRITE
        call    BDOS
        ret

; ---- Data ----

msg_banner:  defm 'SIO-B BIOS test',13,10,'$'
msg_iobyte:  defm 'IOBYTE=$'
msg_timeout: defm 'TIMEOUT: no data from SIO-B',13,10,'$'
msg_received:defm 'Received $'
msg_bytes:   defm ' bytes',13,10,'$'
msg_data:    defm 'Data: $'
msg_pass:    defm 13,10,'SIOB-IOBYTE-TEST-OK',13,10,'$'
msg_fail:    defm 13,10,'SIOB-IOBYTE-TEST-FAIL',13,10,'$'

marker:      defm 'SIOB-IOBYTE-TEST-OK'

rxlen:       defb 0
rxdata:      defs 128
