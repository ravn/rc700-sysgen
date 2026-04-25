; cpnos-rom BIOS ABI shims — CP/M ↔ clang sdcccall(1) bridge
;
; CP/M BIOS ABI:
;   CONOUT(c in C),  LIST(c in C)         — char arg in C
;   CONST(→ A),  CONIN(→ A)               — no args, byte return in A
;   All callers expect BC, DE, HL preserved (HL preserved is loose; CCP
;   doesn't care, but BC and DE are CCP/NDOS loop counters and MUST
;   survive across the BIOS call).
;
; clang sdcccall(1):
;   First 8-bit arg in A.  8-bit return in A.  No callee-save registers.
;
; These shims save BC/DE, translate C→A where needed, CALL the impl,
; restore BC/DE, RET.  Replaces the cshim/cishim/coshim/lshim wrappers
; that used to live in cpnos-build/src/cpbios.asm — moving them into
; the resident keeps the register-translation logic in the same build
; as the impls and removes the cross-build coupling that bit us
; 2026-04-25 (memory: project_cpnos_address_coupling_brittle).
;
; CALL+POP+RET (vs JP+stack-trick): 7 bytes per shim, ~50 T-states
; per BIOS call.  Acceptable — console traffic isn't hot-path.

    .section .text._bios_shims, "ax", @progbits

    .global bios_const_shim
    .global bios_conin_shim
    .global bios_conout_shim
    .extern _impl_const, _impl_conin, _impl_conout

bios_const_shim:
    push bc
    push de
    call _impl_const          ; A = 0x00 (no char) or 0xFF (char ready)
    pop  de
    pop  bc
    ret

bios_conin_shim:
    push bc
    push de
    call _impl_conin          ; A = char
    pop  de
    pop  bc
    ret

bios_conout_shim:
    push bc
    push de
    ld   a, c                 ; CP/M: char in C → clang: char in A
    call _impl_conout
    pop  de
    pop  bc
    ret
