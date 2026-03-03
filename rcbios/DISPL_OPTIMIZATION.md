# REL30 CONOUT/DISPLAY Optimization Plan

## Status: NOT YET IMPLEMENTED

All optimizations below are for REL30 only, guarded by `IFDEF REL30`.
Non-REL30 builds must remain byte-exact with reference binaries.

## Failed attempt (2026-03-03)

An implementation of items 6 and 7 (CONOUT wrapper + unrolled scroll) was
reverted because CP/M failed to boot. Root cause not yet diagnosed.

Key issue found during implementation: DISPL reads `LD A,(USHER)` so any
CONOUT restructuring that skips the USHER store on the normal char path
must also change DISPL to use `LD A,C` (item 2 below). These two changes
are coupled and must be done together.

The CONSP EQU LOCAD aliasing (reusing LOCAD's 2-byte slot for SP save)
should be safe in principle — LOCAD is only used within DISPL which runs
with interrupts enabled, while CONSP is written/read with DI. But this
needs more investigation given the boot failure.

---

## 1. DISPL: PUSH/POP HL instead of LD (LOCAD),HL

Current code saves cursor address to memory twice:
```
LD  (LOCAD),HL    ; 16T store
...
LD  HL,(LOCAD)    ; 16T load
```

REL30 version: use PUSH HL / POP HL (11T + 10T = 21T vs 32T). Saves 11T.
This also decouples LOCAD from DISPL, enabling CONSP reuse of the slot.

## 2. DISPL: LD A,C instead of LD A,(USHER)

Current code:
```
LD  A,(USHER)     ; 13T
```

Use `LD A,C` (4T). Saves 9T. C register still holds the character at
DISPL entry — only A is used in CONOUT dispatch logic.

**Coupled with item 6**: if CONOUT skips USHER store on the normal path,
DISPL MUST use `LD A,C` instead of `LD A,(USHER)`.

## 3. DISPL: Inline cursor advance

Current code calls ESCC (cursor right) which handles wrap-around, then
falls through to BGFLG bit-setting.

REL30 version inlines the common case (column < 79):
```
LD  A,(CCTAD)
CP  79
JP  Z,DISPL_WRAP    ; rare: end of line
INC A
LD  (CCTAD),A
JP  WP75
```

DISPL_WRAP handles the rare column-79 case by delegating to TSTLROW/ROWDN/SCROLL.
This duplicates ~12 bytes from ESCC1 logic.

Savings: eliminates CALL ESCC (17T) overhead on the common path.

## 4. WP75: Remove PUSH AF / POP AF

WP75 currently saves/restores AF (21T). All callers verified safe — they
all load A fresh after WP75 returns:

- ROWDN, ROWUP, CTLM, ESCC, ESCD, ESCA, ESCH, XYADD, ESCE

REL30 version removes PUSH AF / POP AF. Saves 21T per cursor update.

## 5. BGSTAR removal (~382 bytes freed)

BGSTAR (semi-graphics background feature) adds ~382 bytes of code across
DISPLAY.MAC. Wrapping all BGSTAR code in IFNDEF REL30 would free this space.

Affected routines:
- FILL (lines 89-98): BGFLG check + LOCBBU LDIR
- SCROLL (lines 107-115): BGFLG check + BGSTAR LDIR + LOCBBU
- ADDOFF, CLRBIT: entire routines
- ESCSB, ESCSF, ESCCF: entire routines (TAB1 entries -> DUMMY)
- ESCE, ESCK, ESCY, ESCDL, ESCIL: background bit handling tails
- DISPL (lines 610-629): background bit-setting

## 6. CONOUT wrapper restructuring (~55T saved per char)

Replace CONOUT with REL30-conditional version:
- `LD (CONSP),SP` / `LD SP,(CONSP)` (ED-prefix, 20T each vs 61T/74T)
- Eliminate PUSH AF (CP/M BDOS does not require CONOUT to preserve AF —
  verified against brouhaha/cpm22/bdos.asm, BDOS wraps conoutf with own
  push b / pop b)
- Defer USHER store to rare paths (control chars, XY addressing)
- CONSP EQU LOCAD: reuses LOCAD's 2-byte slot (requires item 1 first)

## 7. Unrolled LDI scroll (~8,395T saved, 20% faster)

Replace SCROLL's `LDIR` with 16-wide unrolled LDI loop:
```
SCRL1:  LDI             ; x16 (16T each vs 21T for LDIR)
        ...
        LDI
        JP   PE,SCRL1   ; P/V=1 when BC>0; 1920/16 = 120 exact iterations
```

Cost: 31,920T vs 40,315T. Code: +33 bytes.

## Expected cumulative timing (all optimizations)

| Metric       | Before  | After   | Improvement |
|--------------|---------|---------|-------------|
| Normal char  | 721T    | ~567T   | 21% faster  |
| Scroll       | 42,850T | 34,500T | 20% faster  |

## Recommended implementation order

Do items 1-2-6 together (they're coupled), then 3, 4, 5, 7 independently.
Test boot after each group.
