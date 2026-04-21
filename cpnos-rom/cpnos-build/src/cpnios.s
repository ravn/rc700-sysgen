; cpnios.s — CP/NOS Network I/O System for RC702.  GNU-as syntax.
;
; Replaces cpnet-z80/dist/src/cpnios.asm (Altos/DSC2 serial ports).
; This version exposes the NIOS 8-entry jump table and forwards each
; entry directly to our resident SNIOS implementation in snios.s.
;
; Both DRI's cpnios and our snios.s already use the same DRI ABI:
;   NTWKIN: no args, returns A = 0 on success
;   NTWKST: A = slave ID, returns A = status
;   CNFTBL: no args, returns HL = pointer to CFGTBL
;   SNDMSG: BC = message buffer addr, returns A = 0/0xFF
;   RCVMSG: BC = message buffer addr, returns A = 0/0xFF
;   NTWKER: no args, returns A
;   NTWKBT: no args (warm-boot hook)
;   NTWKDN: no args (shutdown)

    .extern BDOS
    .global NIOS

    .section .cpnos_code,"ax",@progbits

; Our resident SNIOS JT lives at 0xF233 (8 * 3-byte JP entries).
    .equ _snios_jt, 0xF233

NIOS:
    jp    _snios_jt +  0              ; +0   NTWKIN
    jp    _snios_jt +  3              ; +3   NTWKST
    jp    _snios_jt +  6              ; +6   CNFTBL
    jp    _snios_jt +  9              ; +9   SNDMSG
    jp    _snios_jt + 12              ; +12  RCVMSG
    jp    _snios_jt + 15              ; +15  NTWKER
    jp    _snios_jt + 18              ; +18  NTWKBT
    jp    _snios_jt + 21              ; +21  NTWKDN
