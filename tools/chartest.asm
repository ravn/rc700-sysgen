; chartest.asm - Test 8275 field attributes and GPA0 ROM selection
; Writes directly to display memory at 0xF800 to test:
; 1. Normal characters (ROA296) without field attributes
; 2. Characters with GPA0=1 field attribute (should select ROA327)
; 3. All 64 block patterns via ROA327

BDOS    EQU 0x0005
CONIN   EQU 1
DSPSTR  EQU 0xF800
COLS    EQU 80

    .Z80
    ORG 0x0100

start:
    ; Clear screen
    ld hl,DSPSTR
    ld bc,1920
    ld a,0x20
clr:
    ld (hl),a
    inc hl
    dec bc
    ld a,b
    or c
    jr nz,clr

    ; === ROW 0: Label "Normal chars (ROA296):" ===
    ld hl,DSPSTR
    ld de,msg_normal
    call puts

    ; === ROW 1: Normal characters 0x00-0x3F (no field attribute) ===
    ld hl,DSPSTR + COLS
    ld a,0x00
    ld b,64
row1:
    ld (hl),a
    inc hl
    inc a
    djnz row1

    ; === ROW 3: Label "GPA0=1 chars (ROA327):" ===
    ld hl,DSPSTR + COLS*3
    ld de,msg_gpa0
    call puts

    ; === ROW 4: Field attr 0x84 (GPA0=1) then chars 0x00-0x3F ===
    ld hl,DSPSTR + COLS*4
    ld (hl),0x84          ; field attribute: GPA0=1
    inc hl
    ld a,0x00
    ld b,64
row4:
    ld (hl),a
    inc hl
    inc a
    djnz row4

    ; === ROW 6: Label "GPA0=1 upper (0x40-0x7F):" ===
    ld hl,DSPSTR + COLS*6
    ld de,msg_upper
    call puts

    ; === ROW 7: Field attr 0x84 then chars 0x40-0x7F ===
    ld hl,DSPSTR + COLS*7
    ld (hl),0x84          ; field attribute: GPA0=1
    inc hl
    ld a,0x40
    ld b,64
row7:
    ld (hl),a
    inc hl
    inc a
    djnz row7

    ; === ROW 9: Field attr 0x80 (reset to normal) then "Back to normal" ===
    ld hl,DSPSTR + COLS*9
    ld (hl),0x80          ; field attribute: GPA0=0 (reset)
    inc hl
    ld de,msg_back
    call puts_hl

    ; === ROW 11: Label "Block patterns 0-31:" ===
    ld hl,DSPSTR + COLS*11
    ld de,msg_blk1
    call puts

    ; === ROW 12: Field attr 0x84 then patterns 0-31 (chars 0x20-0x3F) ===
    ; ROA327 chars 0x20-0x3F are the 2x3 block semigraphics
    ld hl,DSPSTR + COLS*12
    ld (hl),0x84          ; field attribute: GPA0=1
    inc hl
    ld a,0x20             ; ROA327 block start
    ld b,32
row12:
    ld (hl),a
    inc hl
    inc a
    djnz row12

    ; === ROW 14: Label "Block patterns 32-63:" ===
    ld hl,DSPSTR + COLS*14
    ld de,msg_blk2
    call puts

    ; === ROW 15: Field attr 0x84 then patterns 32-63 (chars 0x40-0x5F) ===
    ld hl,DSPSTR + COLS*15
    ld (hl),0x84          ; field attribute: GPA0=1
    inc hl
    ld a,0x40
    ld b,32
row15:
    ld (hl),a
    inc hl
    inc a
    djnz row15

    ; === ROW 17: Label "Line drawing (0x00-0x1F):" ===
    ld hl,DSPSTR + COLS*17
    ld de,msg_line
    call puts

    ; === ROW 18: Field attr 0x84 then chars 0x00-0x1F (line drawing) ===
    ld hl,DSPSTR + COLS*18
    ld (hl),0x84          ; field attribute: GPA0=1
    inc hl
    ld a,0x00
    ld b,32
row18:
    ld (hl),a
    inc hl
    inc a
    djnz row18

    ; === ROW 20: Mixed test - normal then GPA0 then normal ===
    ld hl,DSPSTR + COLS*20
    ld de,msg_mixed
    call puts

    ; === ROW 21: "Hello " + GPA0 blocks + normal " World" ===
    ld hl,DSPSTR + COLS*21
    ld (hl),'H'
    inc hl
    ld (hl),'e'
    inc hl
    ld (hl),'l'
    inc hl
    ld (hl),'l'
    inc hl
    ld (hl),'o'
    inc hl
    ld (hl),' '
    inc hl
    ld (hl),0x84          ; GPA0=1
    inc hl
    ld (hl),0x3F          ; full block (pattern 63)
    inc hl
    ld (hl),0x3F          ; full block
    inc hl
    ld (hl),0x3F          ; full block
    inc hl
    ld (hl),0x3F          ; full block
    inc hl
    ld (hl),0x80          ; GPA0=0 (reset)
    inc hl
    ld (hl),' '
    inc hl
    ld (hl),'W'
    inc hl
    ld (hl),'o'
    inc hl
    ld (hl),'r'
    inc hl
    ld (hl),'l'
    inc hl
    ld (hl),'d'

    ; === ROW 23: "Press any key to exit" ===
    ld hl,DSPSTR + COLS*23
    ld de,msg_exit
    call puts

    ; Wait for keypress
    ld c,CONIN
    call BDOS

    ; Clear screen via BDOS
    ld c,9
    ld de,clrmsg
    call BDOS
    rst 0

; puts: copy string from DE to HL (DSPSTR), terminated by 0
puts:
    ld a,(de)
    or a
    ret z
    ld (hl),a
    inc hl
    inc de
    jr puts

; puts_hl: copy string from DE to current HL position
puts_hl:
    ld a,(de)
    or a
    ret z
    ld (hl),a
    inc hl
    inc de
    jr puts_hl

msg_normal:
    db "Normal chars 0x00-0x3F (ROA296):",0
msg_gpa0:
    db "GPA0=1 chars 0x00-0x3F (should be ROA327):",0
msg_upper:
    db "GPA0=1 chars 0x40-0x7F (ROA327 upper half):",0
msg_back:
    db "Back to normal (GPA0=0 reset)",0
msg_blk1:
    db "Block patterns 0-31 (ROA327 0x20-0x3F):",0
msg_blk2:
    db "Block patterns 32-63 (ROA327 0x40-0x5F):",0
msg_line:
    db "Line drawing (ROA327 0x00-0x1F):",0
msg_mixed:
    db "Mixed: normal + GPA0 blocks + normal:",0
msg_exit:
    db "Press any key to exit",0
clrmsg:
    db 0x1B, 'E', '$'
