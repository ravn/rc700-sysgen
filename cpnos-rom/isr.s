; cpnos-rom interrupt helpers + CRT ISR
;
; Z80 IM2 interrupt handling for display refresh.  The 8275 CRT asserts
; VRTC at each vertical retrace; CTC channel 2 counts those pulses and
; fires an IM2 interrupt whose vector is base+4 (CTC ch2).  Our IVT at
; 0xF100 maps that vector to _isr_crt, which reprograms DMA for the
; next display refresh and re-arms CTC ch2.
;
; Register preservation: the ISR swaps to the Z80 shadow register set
; via `ex af,af'` + `exx`, so any use of A/BC/DE/HL in the body is
; safe.  Compiled C code is built with +shadow-regs meaning the main
; register set is the one live at interrupt time; the shadow set is
; therefore free for the ISR to use.  IX/IY are not swapped but the
; ISR does not touch them.
;
; All ISRs live in .resident so they survive the OUT (0x18) PROM
; disable.  Helpers below (set_i_reg, enable_im2, ei/di) run from PROM
; during init and are not needed afterwards.

; ------------------------------------------------------------------
; Init-time helpers (live in PROM, called from init.c)
; ------------------------------------------------------------------

    .section .text.__set_i_reg, "ax", @progbits
    .global _set_i_reg
_set_i_reg:
    ; uint8_t page -> A
    ld   i, a
    ret

    .section .text.__enable_im2, "ax", @progbits
    .global _enable_im2
_enable_im2:
    im   2
    ret

    ; enable_interrupts / disable_interrupts are called from
    ; resident_entry *after* PROM disable, so they must live in
    ; .resident.  Without this, the call lands on zero-initialised
    ; RAM and PC walks through NOPs forever.
    .section .resident.isr, "ax", @progbits
    .global _enable_interrupts
_enable_interrupts:
    ei
    ret

    .global _disable_interrupts
_disable_interrupts:
    di
    ret

; ------------------------------------------------------------------
; ISRs (live in .resident — survive PROM disable)
; ------------------------------------------------------------------

    .section .resident.isr, "ax", @progbits

; No-op ISR for unused IM2 slots.  Must use RETI so the CTC/PIO's
; interrupt-daisy-chain hardware can advance past this device.
    .global _isr_noop
_isr_noop:
    ei
    reti

; CRT refresh ISR.  On each VRTC interrupt:
;   - ack CRT status read
;   - mask DMA display+attr channels, clear byte-pointer FF
;   - (re)load display base address + word count
;   - (re)load attribute word count = 0 (no attributes used)
;   - unmask DMA channels
;   - re-arm CTC ch2 for next frame
;   - bump a tick counter at 0xEC20 so the MAME probe can verify we fired
; Swaps to shadow regs so A/BC/DE/HL of the interrupted code are safe.
; IX/IY are never touched.
    .global _isr_crt
_isr_crt:
    .byte 0x08              ; ex af,af' (GNU-as on Z80 chokes on the apostrophe)
    .byte 0xD9              ; exx

    ; Breadcrumb tick.  Was 0xEC20; moved to 0xEC30 because IVT now
    ; lives at 0xEC00..0xEC23 (IVT_PIO_A slot at 0xEC20 would collide).
    ld   hl, 0xEC30
    inc  (hl)

    ; Ack CRT status register.
    in   a, (0x01)          ; PORT_CRT_CMD

    ; Mask DMA channels 2 + 3.
    ld   a, 0x06            ; mask set, ch2
    out  (0xFA), a
    ld   a, 0x07            ; mask set, ch3
    out  (0xFA), a

    ; Clear byte-pointer flip-flop so the next two writes are lo/hi.
    xor  a
    out  (0xFC), a

    ; Display source addr = 0xF800 (lo=0, hi=0xF8).
    ld   a, 0x00
    out  (0xF4), a
    ld   a, 0xF8
    out  (0xF4), a

    ; Display word count = DISPLAY_SIZE-1 = 2000-1 = 0x07CF.
    ld   a, 0xCF
    out  (0xF5), a
    ld   a, 0x07
    out  (0xF5), a

    ; Attribute word count = 0.
    xor  a
    out  (0xF7), a
    out  (0xF7), a

    ; Unmask channels 2 + 3.
    ld   a, 0x02            ; mask clear, ch2
    out  (0xFA), a
    ld   a, 0x03            ; mask clear, ch3
    out  (0xFA), a

    ; Re-arm CTC ch2 for the next VRTC.
    ld   a, 0xD7            ; counter mode, interrupt enable, TC follows
    out  (0x0E), a
    ld   a, 0x01            ; count = 1
    out  (0x0E), a

    ; Deferred 8275 cursor update: if impl_conout set cur_dirty, push
    ; the current curx/cury to the CRT and clear the flag.  Doing this
    ; at frame rate instead of per-character eliminates visible flicker
    ; on fast streams (netboot banner, CCP DIR, etc.).  Mainline writes
    ; cur_dirty *after* writing curx/cury, so reading them here races
    ; benignly: we may see a slightly-stale position one frame later,
    ; but never a torn pair (single-byte stores are atomic on Z80).
    ld   a, (_cur_dirty)
    or   a
    jr   z, _isr_crt_done
    xor  a
    ld   (_cur_dirty), a
    ld   a, 0x80            ; 8275 "load cursor position" command
    out  (0x01), a          ; PORT_CRT_CMD
    ld   a, (_curx)
    out  (0x00), a          ; PORT_CRT_PARAM (column)
    ld   a, (_cury)
    out  (0x00), a          ; PORT_CRT_PARAM (row)
_isr_crt_done:

    .byte 0xD9              ; exx
    .byte 0x08              ; ex af,af'
    ei
    reti

; PIO-A keyboard ISR.  Fires on each PIO-A interrupt (one per keystroke
; when PIO-A is in input mode with IRQ enabled).  Reads the byte and
; enqueues to the kbd_ring; drops the byte silently if the ring is full.
; Swaps to shadow regs (same convention as _isr_crt).  The ring buffer
; symbols (_kbd_ring / _kbd_head / _kbd_tail) live in .scratch_bss,
; defined by resident.c.
    .global _isr_pio_kbd
_isr_pio_kbd:
    .byte 0x08              ; ex af,af'
    .byte 0xD9              ; exx

    in   a, (0x10)          ; PORT_PIO_A_DATA -> A (keystroke)
    ld   e, a               ; stash the key

    ; new_head = (head + 1) & 0x0F
    ld   hl, _kbd_head
    ld   a, (hl)
    inc  a
    and  0x0F
    ld   d, a               ; D = new_head

    ; if (new_head == tail) drop the byte
    ld   hl, _kbd_tail
    ld   a, (hl)
    cp   d
    jr   z, _isr_pio_kbd_done

    ; ring[head] = key;  head = new_head
    ld   hl, _kbd_head
    ld   a, (hl)
    ld   h, 0
    ld   l, a
    ld   bc, _kbd_ring
    add  hl, bc
    ld   (hl), e            ; store key
    ld   a, d
    ld   (_kbd_head), a

_isr_pio_kbd_done:
    .byte 0xD9              ; exx
    .byte 0x08              ; ex af,af'
    ei
    reti

; PIO-B parallel ISR — CP/NET fast-link bring-up stub.
; Fires on each PIO-B interrupt (one per byte strobed in via BSTB
; while PIO-B is in Mode 1 input).  Reads the byte, stores into
; _pio_par_byte, bumps _pio_par_count.  Both BSS vars live in
; resident.c.  Shadow regs preserved so the ISR doesn't perturb
; whatever the foreground was doing.  Replaced by the real CP/NET
; RX ring once protocol-layer work lands; for now the counter is
; just a "bytes flowed through" indicator that the test harness
; polls via MAME Lua memory tap.
    .global _isr_pio_par
_isr_pio_par:
    .byte 0x08              ; ex af,af'
    .byte 0xD9              ; exx

    in   a, (0x11)          ; PORT_PIO_B_DATA -> A
    ld   (_pio_par_byte), a

    ld   hl, _pio_par_count
    inc  (hl)

    .byte 0xD9              ; exx
    .byte 0x08              ; ex af,af'
    ei
    reti
