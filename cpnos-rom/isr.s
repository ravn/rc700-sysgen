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

    ; Breadcrumb tick.
    ld   hl, 0xEC20
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

    .byte 0xD9              ; exx
    .byte 0x08              ; ex af,af'
    ei
    reti
