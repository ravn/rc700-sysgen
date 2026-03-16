# MP/M CP/NET Server Analysis — z80pack

## Architecture

z80pack CP/NET uses two separate cpmsim instances:

- **Server**: MP/M with NETWRKIF RSP. Console 3 (ports 44/45) listens on TCP 4002.
- **Client**: CP/M 2.2 with SNIOS/NDOS. Ports 50/51 (AUX) connect out to TCP 4002.

The client SNIOS (`srccpm2/snios-0.asm`) uses z80pack virtual ports 50/51.
The reference client disk is `cpm2-net-1.2.tgz` from the z80pack FTP archive.

Config files: `conf/net_server.conf` (server ports), `conf/net_client.conf` (client connection target).

## Bug: NETWRKIF nwinit computes wrong CONIN address

**Affects**: `srcmpm/netwrkif-0.asm`, `netwrkif-1.asm`, `netwrkif-2.asm`.

### Symptom

MP/M with NETWRKIF RSP hangs after displaying the memory map. No `0A>` prompt appears. The NtwrkIP0 process crashes when it first calls `xCharin`, which jumps to an invalid address.

With `netwrkif-0.asm`: confirmed crash at `0xFFEB` — `ED 0D` (undefined Z80 opcode).

### Root cause

`nwinit` computes the XIOS CONIN entry address incorrectly:

```asm
; netwrkif nwinit (BUGGY)
lhld    0001h       ; HL = addr of JP WARMSTART in XIOS jump table
inx     h
mov     e,m         ; DE = WARMSTART code address (JP operand)
inx     h
mov     d,m
lxi     h,6
dad     d           ; HL = WARMSTART_code + 6  ← WRONG
shld    conin
```

This assumes the WARMSTART code address equals the base of the XIOS jump table. In DRI's original XIOS template, WARMSTART/COLDSTART were at the start of the module, and CONST/CONIN/CONOUT followed as JP instructions at +3/+6/+9.

In Udo Munk's `bnkxios-net-2.mac`, the layout is:

```
+0:  JP COMMONBASE       ; module start
+3:  JP WARMSTART        ; ← [0001h] points here
+6:  JP CONST
+9:  JP CONIN            ; ← target
+12: JP CONOUT
...
COMMONBASE:
  JP COLDSTART
  SWTUSER: JP $-$
  SWTSYS:  JP $-$
  PDISP:   JP $-$
  XDOS:    JP $-$
  SYSDAT:  DEFW $-$
COLDSTART:
WARMSTART:               ; ← actual code, NOT at module base
  LD C,0
  JP XDOS
CONST:                   ; ← at WARMSTART+5, not WARMSTART+3
  CALL PTBLJMP
  ...
```

`WARMSTART_code + 6` lands inside CONST's dispatch table — not at CONIN.

### Fix

Use the jump table address directly instead of dereferencing the JP operand:

```asm
; netwrkif nwinit (FIXED)
lhld    0001h       ; HL = addr of JP WARMSTART entry (base+3)
lxi     d,6
dad     d           ; HL = base+9 = addr of JP CONIN entry
shld    conin
```

`xCharin` then does `LHLD conin; PCHL` which executes `JP CONIN`, reaching the handler correctly.

## GENSYS: Number of TMPs must be 5

`build-mpmnet.exp` was setting `Number of TMPs = 2`. This must match the XIOS `NMBCNS` (5). With 2 TMPs:

- `CONSOLE DAT` is only 2 pages (consoles 0-1)
- XDOS POLL for console 3 devices may access unallocated memory
- The system appears to work superficially (memory map prints) but processes hang

Fix: accept the GENSYS default (5 TMPs).

## SNIOS changes (RC702 side)

Simplified `NTWKIN` for CP/NET 1.2 compatibility: removed FNC=FF handshake (MP/M doesn't understand it), replaced with standard init (set slave ID, mark active, return 0). CPNETLDR now completes successfully.

## Files

| File | Change | Status |
|------|--------|--------|
| `cpmsim/srcmpm/netwrkif-2.asm` | Fix nwinit CONIN calculation; disable WtchDg; NmbSlvs=1 | Modified |
| `cpmsim/build-mpmnet.exp` | Accept default TMPs (5) instead of forcing 2 | Modified |
| `cpmsim/srcsim/sim.h` | Disable TCPASYNC (macOS SIGIO unreliable) | Modified |
| `cpmsim/srcsim/simio.c` | Debug fprintf in cons3_in (temporary) | Modified |
| `cpmsim/z80core/simcore.c` | Debug fprintf for port 40-47 reads (temporary) | Modified |
| `cpnet/snios.asm` | Remove FNC=FF handshake for CP/NET 1.2 | Modified |
| `cpnet/cpnet12_client.py` | New: Python test client for DRI binary protocol | New |

## Status

The nwinit fix has NOT been verified end-to-end. The fix is logically correct (confirmed by BNKXIOS layout analysis and the 0xFFEB crash proving the original calculation is wrong), but MP/M still needs rebuilding and testing with the corrected NETWRKIF.

## References

- MP/M II sources: `mpmsrc.zip` from z80pack FTP (XDOS poll in `dsptch.asm`, function 131 in `xdos.asm`)
- CP/NET 1.2 reference client disk: `cpm2-net-1.2.tgz` from z80pack FTP
- BNKXIOS: `cpmsim/srcmpm/bnkxios-net-2.mac` — 5 consoles, poll device table at DEVTBL
