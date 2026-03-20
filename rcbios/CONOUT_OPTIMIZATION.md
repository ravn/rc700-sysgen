# REL30 CONOUT Display Driver Optimization Analysis

## CP/M BDOS Register Convention (Verified)

Source: CP/M 2.2 BDOS source code ([brouhaha/cpm22](https://github.com/brouhaha/cpm22), `bdos.asm`)

**Finding: The CP/M 2.2 BDOS does NOT require BIOS CONOUT to preserve any registers.**

The BDOS saves its own registers around every `conoutf` (BIOS CONOUT) call:

| BDOS call site | Line | Pattern | Post-call register use |
|---------------|------|---------|----------------------|
| `conout` | 291-296 | `push b; call conoutf; pop b` | Uses B (restored), then `lda` (A only) |
| `backup` | 365 | `call conoutf` | Falls through to `pctlh` — no reg dependency |
| `pctlh` | 370 | `jmp conoutf` | Tail call — caller gets return |
| direct I/O | 614 | `jmp conoutf` | Tail call |
| `print` | 405-408 | `push b; call tabout; pop b` | Uses B (restored) |
| `ctlout`/`rep0` | 529-533 | `push b; push h; call ctlout; pop h; pop b` | Uses H,B (restored) |

**BIOS-internal caller** (`PRMSG` in CPMBOOT.MAC line 126-129):
```asm
PRMSG:  LD A,(HL)       ; char from message
        PUSH HL         ; <-- saves HL itself
        LD C,A
        CALL CONOUT
        POP HL          ; <-- restores HL itself
        INC HL
        JP PRMSG
```
Also saves HL itself — no dependency on CONOUT preserving it.

**Risk**: User programs calling BIOS CONOUT directly (via jump table at BIOS+9)
may expect register preservation. This is outside CP/M spec but may occur in
RC702 software. Decision on register preservation level is a compatibility tradeoff.

---

## Current CONOUT Timing (Normal Printable Character, Column < 79)

### CONOUT Wrapper (DISPLAY.MAC lines 633-664)
```
                        ; Prologue                              Bytes  T-states
CONOUT: DI              ;                                        1      4
        PUSH HL         ; save caller HL                         1     11
        LD   HL,0       ; Z80 has no "LD HL,SP" instruction      3     10
        ADD  HL,SP      ; HL = caller SP                         1     11
        LD   SP,STACK   ; switch to BIOS stack                   3     10
        EI              ;                                        1      4
        PUSH HL         ; save caller SP on BIOS stack           1     11  = 61T
        PUSH AF         ; save AF                                1     11
        PUSH BC         ; save BC (C = character)                1     11
        PUSH DE         ; save DE                                1     11  = 33T

                        ; Dispatch (normal char path)
        LD   A,C        ; A = character                          1      4
        LD   (USHER),A  ; store for DISPL/SPECC/XYADD            3     13
        LD   A,(XFLG)   ; check XY addressing mode               3     13
        OR   A          ;                                        1      4
        JP   Z,CONOU1   ; → CONOU1 (not in XY mode)              3     10
CONOU1: LD   A,(USHER)  ; reload character (redundant!)           3     13
        CP   32         ; control char?                          2      7
        JP   NC,CONOU2  ; → CONOU2 (printable)                   3     10  = 74T
CONOU2: CALL DISPL      ; display character                      3     17

                        ; Epilogue
CONOU3: POP  DE         ;                                        1     10
        POP  BC         ;                                        1     10
        POP  AF         ;                                        1     10
        POP  HL         ; restore caller SP into HL              1     10
        DI              ;                                        1      4
        LD   SP,HL      ; switch back to caller stack            1      6
        POP  HL         ; restore caller HL                      1     10
        EI              ;                                        1      4
        RET             ;                                        1     10  = 74T

CONOUT wrapper total: 61 + 33 + 74 + 17(CALL) + 74 = 259T (excl. DISPL body)
```

### DISPL Body (DISPLAY.MAC lines 583-629, normal path: col < 79, char < 128, GRAPH=0)
```
                        ;                                       Bytes  T-states
DISPL:  LD   HL,(RCTAD) ; row offset (0, 80, 160, ...)           3     16
        LD   D,0        ;                                        2      7
        LD   A,(CCTAD)  ; column (0-79)                          3     13
        LD   E,A        ;                                        1      4
        ADD  HL,DE      ; HL = row + column                      1     11
        LD   (LOCAD),HL ; save for background code               3     16  = 67T
        LD   A,(USHER)  ; reload char (could use C)              3     13
        CP   192        ; >= 192?                                2      7
        JP   C,DISPL1   ; no                                     3     10  = 30T
DISPL1: LD   C,A        ;                                        1      4
        CP   128        ; >= 128?                                2      7
        JP   C,DISPL2   ; no → convert                           3     10  = 21T
DISPL2: LD   HL,OUTCON  ; conversion table address               3     10
        CALL CONV       ; convert character                      3     17
                        ; CONV body (GRAPH=0 path):
                        ;   LD A,(GRAPH)  3/13T
                        ;   OR A          1/4T
                        ;   LD A,C        1/4T  (loads char)
                        ;   LD B,0        2/7T
                        ;   ADD HL,BC     1/11T (table+offset)
                        ;   LD A,(HL)     1/7T  (converted char)
                        ;   RET           1/10T
                        ;                            = 10+17+56 = 83T
DISPL3: LD   HL,(LOCAD) ; reload location                        3     16
        LD   DE,DSPSTR  ; display start address                  3     10
        ADD  HL,DE      ; HL = absolute screen address            1     11
        LD   (HL),A     ; write character to screen               1      7
                        ;                                              = 44T
        CALL ESCC       ; cursor right                           3     17
                        ; ESCC body (col < 79 path):
                        ;   LD A,(CCTAD)   3/13T
                        ;   CP 79          2/7T
                        ;   JP Z,ESCC1     3/10T (not taken)
                        ;   INC A          1/4T
                        ;   LD (CCTAD),A   3/13T
                        ;   JP WP75        3/10T
                        ;                              = 57T
                        ; WP75 body:
                        ;   PUSH AF        1/11T
                        ;   LD A,80H       2/7T
                        ;   OUT (DSPLC),A  2/11T
                        ;   LD A,(CCTAD)   3/13T
                        ;   OUT (DSPLD),A  2/11T
                        ;   LD A,(CURSY)   3/13T
                        ;   OUT (DSPLD),A  2/11T
                        ;   POP AF         1/10T
                        ;   RET            1/10T
                        ;                              = 97T
                        ; ESCC total: 17(CALL) + 57 + 97 = 171T

        ; Background code (col < 79 → ESCC returns, then:)
        LD   A,(BGFLG)  ; check background flag                  3     13
        CP   2          ;                                        2      7
        RET  NZ         ; not background → return                1     11  = 31T
                        ; (background path not taken for REL30)

DISPL body total: 67 + 30 + 21 + 83 + 44 + 171 + 31 = 447T
```

### Total: Current Normal Character Path
```
CONOUT wrapper:  259T  (prologue + dispatch + CALL + epilogue)
DISPL body:      447T
RET from DISPL:   10T
                 ────
Total:           716T  at 4 MHz = 179µs → ~5,590 chars/sec
```

---

## Proposed REL30 Optimizations

### Optimization 1: CONOUT Wrapper Restructuring
```
                        ; REL30 Prologue                        Bytes  T-states
CONOUT: DI              ;                                        1      4
        LD   (CONSP),SP ; ED 73 nn nn — save caller SP           4     20
        LD   SP,STACK   ; switch to BIOS stack                   3     10
        EI              ;                                        1      4  = 38T
        PUSH HL         ; save HL                                1     11
        PUSH BC         ; save BC (C = character)                1     11
        PUSH DE         ; save DE                                1     11  = 33T
  [or: drop all PUSHes = 0T if no reg preservation needed]

                        ; Dispatch (normal char path)
        LD   A,(XFLG)   ; check XY addressing mode               3     13
        OR   A          ;                                        1      4
        JP   NZ,CONXY   ; XY mode (rare)                         3     10
        LD   A,C        ; A = character from C (4T vs 13T)       1      4
        CP   32         ; control char?                          2      7
        JP   C,CONCTL   ; control char (rare)                    3     10  = 48T
        CALL DISPL      ;                                        3     17

                        ; REL30 Epilogue
CONOU3: POP  DE         ;                                        1     10
        POP  BC         ;                                        1     10
        POP  HL         ;                                        1     10  = 30T
  [or: 0T if no reg preservation]
        DI              ;                                        1      4
        LD   SP,(CONSP) ; ED 7B nn nn — restore caller SP        4     20
        EI              ;                                        1      4
        RET             ;                                        1     10  = 38T

REL30 wrapper: 38 + 33 + 48 + 17(CALL) + 30 + 38 = 204T  (was 259T, saves 55T)
  [or without reg saves: 38 + 0 + 48 + 17 + 0 + 38 = 141T (saves 118T)]
```

**What changed:**
- `LD (CONSP),SP` / `LD SP,(CONSP)` replaces the HL-based SP capture trick (38T vs 61T = -23T)
- Separate CONSP variable needed (can't reuse SP_SAV — ISRs fire during EI)
- PUSH AF dropped: CP/M doesn't need AF preserved; A is loaded from C immediately (-22T)
- USHER store deferred to rare paths CONCTL/CONXY only (-13T on common path)
- `LD A,C` replaces `LD A,(USHER)` reload (-9T)
- Dispatch reordered: XY check first (JP NZ = skip rare), then CP 32 (JP C = skip rare)

### Optimization 2: DISPL Body
```
                        ; REL30 DISPL                           Bytes  T-states
DISPL:  LD   HL,(RCTAD) ; row offset                             3     16
        LD   D,0        ;                                        2      7
        LD   A,(CCTAD)  ; column                                 3     13
        LD   E,A        ;                                        1      4
        ADD  HL,DE      ; HL = row + column                      1     11
        PUSH HL         ; save (was LD (LOCAD),HL = 16T)         1     11  = 62T  (-5T)
        LD   A,C        ; char from C (was LD A,(USHER) = 13T)   1      4
        CP   192        ;                                        2      7
        JP   C,DISPL1   ;                                        3     10  = 21T  (-9T)
DISPL1: LD   C,A        ;                                        1      4
        CP   128        ;                                        2      7
        JP   C,DISPL2   ;                                        3     10  = 21T  (same)
DISPL2: LD   HL,OUTCON  ;                                        3     10
        CALL CONV       ; (CONV body: 56T)                       3     17  = 83T  (same)
DISPL3: POP  HL         ; restore (was LD HL,(LOCAD) = 16T)      1     10
        LD   DE,DSPSTR  ;                                        3     10
        ADD  HL,DE      ;                                        1     11
        LD   (HL),A     ; write char to screen                   1      7  = 38T  (-6T)

        ; Inline cursor advance (replaces CALL ESCC)
        LD   A,(CCTAD)  ;                                        3     13
        CP   79         ;                                        2      7
        JP   Z,DISPL_WRAP ; col 79 → wrap (rare)                 3     10
        INC  A          ;                                        1      4
        LD   (CCTAD),A  ;                                        3     13
        JP   WP75       ; tail call (WP75 RET → CONOU3)          3     10  = 57T

        ; WP75 body (REL30, no PUSH/POP AF):
        ;   LD A,80H       2/7T
        ;   OUT (DSPLC),A  2/11T
        ;   LD A,(CCTAD)   3/13T
        ;   OUT (DSPLD),A  2/11T
        ;   LD A,(CURSY)   3/13T
        ;   OUT (DSPLD),A  2/11T
        ;   RET            1/10T  = 76T  (-21T from removing PUSH/POP AF)

        ; No BGFLG check (removed for REL30)            = 0T  (-31T)

REL30 DISPL total: 62 + 21 + 21 + 83 + 38 + 57 + 76 = 358T  (was 447T, saves 89T)
  [no CALL ESCC overhead: saves 17T (CALL) + 10T (RET in ESCC) = 27T]
  [no BGFLG check: saves 31T]
  [LOCAD → PUSH/POP: saves 11T]
  [USHER → C reg: saves 9T]
  [WP75 no PUSH/POP AF: saves 21T]
```

### Total: REL30 Normal Character Path (with register saves)
```
REL30 wrapper:   204T  (was 259T)
REL30 DISPL:     358T  (was 447T)
RET from DISPL:    0T  (tail call via JP WP75 → RET to CONOU3)
                 ────
Total:           562T  at 4 MHz = 140µs → ~7,100 chars/sec  (was 716T)
Savings:         154T per character = 21.5% faster
```

### Total: REL30 Without Register Saves
```
REL30 wrapper:   141T  (no PUSH/POP HL,BC,DE)
REL30 DISPL:     358T
                 ────
Total:           499T  at 4 MHz = 125µs → ~8,020 chars/sec
Savings:         217T per character = 30.3% faster
```

### Optimization 3: Unrolled LDI Scroll — IMPLEMENTED
```
Current SCROLL (LDIR):
  LD HL,DSPSTR+80       3/10T
  LD DE,DSPSTR          3/10T
  LD BC,1920            3/10T
  LDIR                  2/1920×21T - 5T = 40,315T
                        Total: 40,345T

REL30 SCROLL (16-wide unrolled LDI):
  LD HL,DSPSTR+80       3/10T
  LD DE,DSPSTR          3/10T
  LD BC,1920            3/10T
  SCRL1: LDI ×16        32/16×16T = 256T per iteration
         JP PE,SCRL1     3/10T per iteration
                        120 iterations × 266T = 31,920T
                        Total: 31,950T

  Savings: 8,395T per scroll = 20.8% faster
  Code cost: +33 bytes (35 bytes vs 2 bytes for LDIR)
  1920 / 16 = 120 exactly (no remainder)
```

Committed and boot-tested 2026-03-03.

### Optimization 4: BGSTAR Removal
```
Code savings: ~382 bytes (see rcbios/BGSTAR_ANALYSIS.md)
Runtime savings: 31T per normal character (BGFLG check eliminated)
                 Variable savings in control char paths (ESCK, ESCY, ESCDL, ESCIL)
```

---

## Summary

| Configuration | Normal char | Scroll | Code delta |
|--------------|-------------|--------|------------|
| Current (all builds) | 716T (5,590 c/s) | 40,345T | baseline |
| REL30 + reg saves | 562T (7,100 c/s) | 31,950T | -349B net |
| REL30 no reg saves | 499T (8,020 c/s) | 31,950T | -355B net |
| Improvement (reg saves) | -154T (21.5%) | -8,395T (20.8%) | |
| Improvement (no saves) | -217T (30.3%) | -8,395T (20.8%) | |

All optimizations use `IFDEF REL30` / `IFNDEF REL30` conditional assembly.
Non-REL30 builds remain byte-identical (verified by `make verify`).

## Implementation Files

- `rcbios/src/DISPLAY.MAC` — CONOUT, DISPL, WP75, SCROLL, BGSTAR sections
- `rcbios/src/BIOS.MAC` — add `CONSP EQU LOCAD` under `IFDEF REL30` (line ~236)

## Key Design Decisions

1. **CONSP variable**: Separate from SP_SAV because ISRs fire while CONOUT runs (EI).
   `CONSP EQU LOCAD` reuses the LOCAD slot (unused in REL30: DISPL uses PUSH/POP).
2. **USHER**: Still needed by SPECC and XYADD. Stored only in rare paths (CONCTL, CONXY).
3. **C register**: Holds char from CP/M caller, never clobbered between CONOUT entry and dispatch.
4. **WP75**: PUSH AF/POP AF safe to remove — all callers load A fresh after WP75.
5. **DISPL_WRAP**: ~12 bytes of ESCC1 logic duplicated for inline cursor advance.
