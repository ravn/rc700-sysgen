; cpnos-rom reset vector (Phase 0 skeleton)
;
; Entry at 0x0000 after power-on or reset.
; PROM0 is mapped; PROM1 at 0x2000 also mapped.  RAM is hidden under both
; until OUT (0x18) is executed.  For Phase 0 we just set up a stack in
; high RAM and call cpnos_main() in C.
;
; After Phase 1 the reset vector will:
;   1. DI, set stack
;   2. HW init (SIO/CTC/PIO)
;   3. Netboot: load CCP+BDOS into RAM
;   4. Copy resident BIOS chunk from ROM to 0xF580
;   5. OUT (0x18),A  -> PROM disable
;   6. JP to CCP
;
; NMI vector (0x0066) is a Phase 1 TODO; RC702 does not wire NMI so the
; hardwired location can hold other code or 0xFF padding.

    .section .reset, "ax"
    .global _reset
_reset:
    di
    ld sp, #0xED00              ; Cold-boot stack, grows down.  Session 33
                                ; follow-up (2026-04-22) moved it from
                                ; 0xF200 to 0xED00 in step with BIOS_BASE
                                ; to give SNIOS more room.  Stack occupies
                                ; 0xEB20..0xED00 (480 B); BSS 0xEA20..0xEB20
                                ; below.  Must NOT overlap netboot DMA
                                ; targets (0xCC00..0xDCC4 for cpnos.com).
    call _cpnos_main
1:  jr 1b                       ; hang if main returns
