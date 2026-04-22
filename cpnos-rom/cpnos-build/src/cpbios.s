; cpbios.s — CP/NOS BIOS for RC702.  GNU-as syntax.
;
; Replaces cpnet-z80/dist/src/cpbios.asm (which targets Altos/DSC2
; I/O ports).  This version forwards every BIOS entry point to
; RC702-native code in cpnos-rom/resident.c / snios.s via ABI shims.
;
; Layout requirements (from DRI's cpbios/cpbdos contract):
;   - BIOS label at module top followed by a 17-entry JP jump table
;     (51 bytes, 3 bytes per entry).  NDOS COLDST reads *(TOP+1) and
;     patches the copy of this table at NDOSRL+0x300.
;   - boot code at label `boot` (pointed to by BIOS+0).
;   - Entries BIOS+3 .. BIOS+48 map to WBOOT, CONST, CONIN, CONOUT,
;     LIST, PUNCH, READER, HOME, SELDSK, SETTRK, SETSEC, SETDMA,
;     READ, WRITE, LISTST, SECTRAN.
;
; ABI translation:
;   CP/M BIOS passes:  char in C (conout/list/punch/seldsk/write)
;                      16-bit in BC (settrk/setsec/setdma/sectran)
;                      nothing (const/conin/reader/home/read/listst/boot/wboot)
;   Our resident C:    char in A  (sdcccall(1) first 8-bit arg)
;                      16-bit in HL
;                      returns 8-bit in A, 16-bit in HL
; So conout/list/etc. get a `ld a, c` prologue before chaining to the
; clang-built impl in resident RAM.

    .extern NDOS, BDOS, NDOSRL
    .global BIOS

    .section .cpnos_code,"ax",@progbits

; ---------------------------------------------------------------
; BIOS jump table — exactly 17 entries x 3 bytes = 51 bytes.
; MUST stay in this layout so NDOS's tlbios walk patches the right
; slots and cpbdos's `ndosrl+constf` / `ndosrl+coninf` offsets hit
; the expected entries after the boot copy to NDOSRL+0x300.
; ---------------------------------------------------------------
BIOS:
    jp    boot        ; +0
    jp    error       ; +3   wboot (CP/NOS: WBOOT is a no-op fault)
    jp    const_shim  ; +6
    jp    conin_shim  ; +9
    jp    conout_shim ; +12
    jp    list_shim   ; +15
    jp    error       ; +18  PUNCH
    jp    error       ; +21  READER
    jp    error       ; +24  HOME
    jp    error       ; +27  SELDSK
    jp    error       ; +30  SETTRK
    jp    error       ; +33  SETSEC
    jp    error       ; +36  SETDMA
    jp    error       ; +39  READ
    jp    error       ; +42  WRITE
    jp    listst_shim ; +45  LISTST
    jp    error       ; +48  SECTRAN
BIOSlen = . - BIOS

; ---------------------------------------------------------------
; Zero-page setup + boot sign-on + hand-off to NDOS cold-start.
; Based on cpnet-z80's cpbios.asm boot routine, rewritten for GNU-as.
; ---------------------------------------------------------------
    .equ BUFF, 0x0080
    .equ JMP_OPCODE, 0xC3

signon:
    .byte 0x0D, 0x0A, 0x0A
    .byte 'R','C','7','0','2',' ','C','P','/','N','O','S',' ','v','1','.','2'
    .byte 0x0D, 0x0A, 0

boot:
    ld    sp, BUFF + 0x0080
    ld    hl, signon
    call  prmsg
    ld    a, JMP_OPCODE
    ld    (0x0000), a
    ld    (0x0005), a
    ld    hl, BDOS
    ld    (0x0006), hl
    xor   a
    ld    (0x0004), a
    ld    hl, NDOSRL + 0x0303
    ld    (0x0001), hl
    dec   hl
    dec   hl
    dec   hl
    ld    de, BIOS
    ld    c, BIOSlen
initloop:
    ld    a, (de)
    ld    (hl), a
    inc   hl
    inc   de
    dec   c
    jp    nz, initloop
    jp    NDOS + 3

error:
    ret

prmsg:
    ld    a, (hl)
    or    a
    ret   z
    ld    c, a
    push  hl
    call  conout_shim
    pop   hl
    inc   hl
    jp    prmsg

; ---------------------------------------------------------------
; ABI shims — translate CP/M register conventions to sdcccall and
; chain to our clang-built resident impls via the BIOS JT.
; Session 33 follow-up (2026-04-22): BIOS_BASE moved from 0xF200 to
; 0xED00 to give SNIOS more room.  JT slots 0xED00..0xED30 are stable
; (enforced by cpnos_rom.ld asserts); the underlying _impl_xxx
; addresses drift with clang builds, but we chain through the JT, not
; the impl directly.  See GitHub issue #34 for the SPR-relocatable
; monolith plan that would eliminate this coupling.
; ---------------------------------------------------------------
    .equ _bios_const,    0xED06
    .equ _bios_conin,    0xED09
    .equ _bios_conout,   0xED0C
    .equ _bios_list,     0xED0F

const_shim:
    jp    _bios_const
conin_shim:
    jp    _bios_conin
conout_shim:
    ld    a, c
    jp    _bios_conout
list_shim:
    ld    a, c
    jp    _bios_list
listst_shim:
    xor   a
    ret
