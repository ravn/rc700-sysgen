        ORG 0000h

; =========================
; Constants
; =========================

VIDEO_BASE  EQU 0F800h
SCREEN_W    EQU 80
SCREEN_H    EQU 25
CENTER_X    EQU 40
CENTER_Y    EQU 12
NUM_STARS   EQU 48

; =========================
; Entry
; =========================

start:
        ld      sp, 0FF00h

        call    init_stars

main_loop:

; -------------------------
; FRAME START BREAKPOINT
; -------------------------
frame_start:
        nop             ; <-- set breakpoint here

        call    clear_screen
        call    update_and_draw

; -------------------------
; FRAME END BREAKPOINT
; -------------------------
frame_end:
        nop             ; <-- or breakpoint here

        jp      main_loop

; =========================
; Initialize stars
; =========================

init_stars:
        ld      hl, stars
        ld      b, NUM_STARS
init_loop:
        call    random
        ld      (hl), a
        inc     hl
        call    random
        ld      (hl), a
        inc     hl
        djnz    init_loop
        ret

; =========================
; Clear screen (2000 bytes)
; =========================

clear_screen:
        ld      hl, VIDEO_BASE
        ld      bc, 2000
        ld      a, ' '
clear_loop:
        ld      (hl), a
        inc     hl
        dec     bc
        ld      a, b
        or      c
        jr      nz, clear_loop
        ret

; =========================
; Update and Draw Stars
; =========================

update_and_draw:
        ld      hl, stars
        ld      b, NUM_STARS

star_loop:

        ; load dx
        ld      a, (hl)
        ld      d, a
        inc     hl

        ; load dy
        ld      a, (hl)
        ld      e, a
        inc     hl

        ; dx += dx >> 4
        ld      a, d
        sra     a
        sra     a
        sra     a
        sra     a
        add     a, d
        ld      d, a

        ; dy += dy >> 4
        ld      a, e
        sra     a
        sra     a
        sra     a
        sra     a
        add     a, e
        ld      e, a

        ; compute screen position
        ld      a, d
        add     a, CENTER_X
        cp      SCREEN_W
        jr      nc, reset_star
        ld      c, a            ; x in C

        ld      a, e
        add     a, CENTER_Y
        cp      SCREEN_H
        jr      nc, reset_star
        ld      l, a            ; y in L

        ; store updated dx,dy back
        dec     hl
        dec     hl
        ld      (hl), d
        inc     hl
        ld      (hl), e
        inc     hl

        ; compute address = VIDEO_BASE + y*80 + x

        push    hl

        ld      a, l
        ld      h, 0
        ld      l, a

        ; multiply by 80 (64+16)
        add     hl, hl      ; x2
        add     hl, hl      ; x4
        add     hl, hl      ; x8
        add     hl, hl      ; x16

        ld      de, hl

        add     hl, hl      ; x32
        add     hl, hl      ; x64

        add     hl, de      ; 64+16 = 80

        ld      d, 0
        ld      e, c
        add     hl, de

        ld      de, VIDEO_BASE
        add     hl, de

        ld      (hl), '*'

        pop     hl
        jr      next_star

reset_star:
        ; reinitialize near center
        call    random
        and     03h
        sub     02h
        ld      d, a

        call    random
        and     03h
        sub     02h
        ld      e, a

        dec     hl
        dec     hl
        ld      (hl), d
        inc     hl
        ld      (hl), e
        inc     hl

next_star:
        djnz    star_loop
        ret

; =========================
; Tiny 8-bit PRNG (LFSR)
; =========================

random:
        ld      a, (seed)
        rra
        jr      nc, no_xor
        xor     0B8h
no_xor:
        ld      (seed), a
        ret

; =========================
; Data
; =========================

seed:      db  1
stars:     ds  NUM_STARS*2

