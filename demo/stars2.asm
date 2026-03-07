        ORG 0100h

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
        ; ld      sp,0FF00h
        call    init_stars

main_loop:

frame_start:
        nop             ; <-- breakpoint here

        call    update_stars
        call    delay

frame_end:
        nop             ; <-- or here

        jp      main_loop

; =========================
; Update + Draw
; =========================

update_stars:
        ld      hl,stars
        ld      b,NUM_STARS

star_loop:

        ; ---- erase old ----
        ld      a,(hl)          ; dx
        inc     hl
        ld      a,(hl)          ; dy
        inc     hl

        ld      a,(hl)          ; px
        ld      d,a
        inc     hl
        ld      a,(hl)          ; py
        ld      e,a
        inc     hl

        push    hl

        call    plot_space      ; erase

        pop     hl
        dec     hl
        dec     hl
        dec     hl
        dec     hl

        ; reload dx,dy
        ld      a,(hl)
        ld      d,a
        inc     hl
        ld      a,(hl)
        ld      e,a
        inc     hl

        ; ---- movement ----
        ; dx += dx>>4
        ld      a,d
        sra     a
        sra     a
        sra     a
        sra     a
        add     a,d
        ld      d,a

        ; dy += dy>>4
        ld      a,e
        sra     a
        sra     a
        sra     a
        sra     a
        add     a,e
        ld      e,a

        ; compute screen coords
        ld      a,d
        add     a,CENTER_X
        cp      SCREEN_W
        jr      nc,reset_star
        ld      c,a

        ld      a,e
        add     a,CENTER_Y
        cp      SCREEN_H
        jr      nc,reset_star
        ld      l,a

        ; ---- brightness ----
        ld      a,d
        call    abs8
        ld      h,a
        ld      a,e
        call    abs8
        add     a,h
        srl     a
        srl     a
        srl     a
        srl     a
        cp      7
        jr      c,bright_ok
        ld      a,6
bright_ok:
        ld      h,0
        ld      l,a
        ld      de,chars
        add     hl,de
        ld      a,(hl)

        ; ---- plot ----
        push    af
        push    hl
        push    bc
        push    de

        ld      a,l            ; y
        call    compute_addr
        pop     de
        pop     bc
        pop     hl
        pop     af
        ld      (hl),a

        ; store new dx,dy,px,py
        pop     hl
        ld      (hl),d
        inc     hl
        ld      (hl),e
        inc     hl
        ld      (hl),c
        inc     hl
        ld      (hl),l
        inc     hl

        djnz    star_loop
        ret

reset_star:
        call    random
        and     03h
        sub     02h
        ld      d,a
        call    random
        and     03h
        sub     02h
        ld      e,a
        jr      star_loop

; =========================
; Plot space at D=x E=y
; =========================

plot_space:
        ld      a,e
        call    compute_addr
        ld      (hl),' '
        ret

; =========================
; Compute HL = VIDEO_BASE + y*80 + x
; y in A, x in D
; =========================

compute_addr:
        ld      h,0
        ld      l,a

        add     hl,hl
        add     hl,hl
        add     hl,hl
        add     hl,hl
        ld      de,hl
        add     hl,hl
        add     hl,hl
        add     hl,de

        ld      e,d
        ld      d,0
        add     hl,de
        ld      de,VIDEO_BASE
        add     hl,de
        ret

; =========================
; abs8 in A
; =========================

abs8:
        bit     7,a
        ret     z
        neg
        ret

; =========================
; Delay
; =========================

delay:
        ld      a,(frame_delay)
delay_outer:
        ld      c,255
delay_inner:
        dec     c
        jr      nz,delay_inner
        dec     a
        jr      nz,delay_outer
        ret

; =========================
; PRNG
; =========================

random:
        ld      a,(seed)
        rra
        jr      nc,no_xor
        xor     0B8h
no_xor:
        ld      (seed),a
        ret

; =========================
; Data
; =========================

chars:          db '.,-o+#*'
frame_delay:    db 40
seed:           db 1
stars:          ds NUM_STARS*4

