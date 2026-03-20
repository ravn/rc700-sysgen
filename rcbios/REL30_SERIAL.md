# REL30 Serial (SIO Channel A) — Flow Control and Ring Buffer

## Overview
REL30 BIOS adds a 256-byte page-aligned ring buffer for SIO Channel A (READER/PUNCH port)
with RTS hardware flow control. Default baud rate 38400. Verified: 32KB file transfer at
38400 baud with zero data loss via MAME null_modem.

## Ring Buffer Architecture (SIO.MAC)
- **RXBUF**: 256-byte page-aligned buffer (`RXBUF EQU (KBBUF+16+255) AND 0FF00H`)
- **RXHEAD**: Write position (advanced by RCA ISR)
- **RXTAIL**: Read position (advanced by READER)
- **Used count**: `(RXHEAD - RXTAIL) AND RXMASK` (mod 256 for default size)
- HEAD and TAIL are single bytes; 256-byte buffer = free wrapping via 8-bit overflow

## RTS Flow Control Thresholds (BIOS.MAC EQUs)
```
RXBUFSZ EQU 256       ; buffer size (power of 2, max 256)
RXMASK  EQU RXBUFSZ-1 ; wrapping mask (0FFH for 256)
RXTHHI  EQU RXBUFSZ-8 ; 248: RCA deasserts RTS when used >= this
RXTHLO  EQU RXBUFSZ-16; 240: READER re-asserts RTS when used < this
```

## Hysteresis Design
- **RCA ISR** deasserts RTS at `used >= RXTHHI` (248 used, 8 free)
- **READER** re-asserts RTS only when `used < RXTHLO` (240 used, 16+ free)
- Hysteresis gap = 8 bytes. Once RTS is deasserted, READER must consume at least
  9 bytes before re-asserting. This prevents the burst-on-reassert race condition.

## Race Condition Fix (commit 30005df)
**Problem**: Original READER unconditionally re-asserted RTS after every byte read
(`ADD A,8AH` = DTR+TX+RTS). Even when buffer had 247/256 bytes used, RTS went high
immediately. The remote sender resumed, flooding bytes. If PIP paused for disk I/O,
the buffer overflowed.

**Symptom**: Data loss starting at ~line 7 of large file transfers (378 bytes = just
past the 256-byte buffer).

**Fix**: READER checks `used < RXTHLO` before re-asserting RTS. If buffer is still
too full, RTS stays deasserted and the sender remains paused.

## Register Caching Optimization (commit b357e4c)
Both RCA ISR and READER cached RXTAIL in register C to avoid repeated memory reads:

**RCA ISR** — saves BC, caches TAIL in C:
- Eliminated: 2x `LD HL,RXTAIL` (6B, 20T), PUSH/POP HL pair (2B, 21T), `LD A,H` (1B, 4T)
- Added: PUSH/POP BC (2B, 21T), `LD A,(RXTAIL); LD C,A` (4B, 17T)
- Net: -3 bytes, -13T on normal path. Character stored via `LD (HL),B` directly.

**READER** — caches new tail in C:
- Eliminated: PUSH/POP HL (2B, 21T), `LD HL,RXTAIL` (3B, 10T), indirect `SUB (HL)` → `SUB C`
- Added: `LD C,A` (1B, 4T)
- Net: -4 bytes, -30T

## Parametric Buffer Size
Buffer size is configurable via `RXBUFSZ EQU` in BIOS.MAC. Code uses conditional assembly:
```
IF RXBUFSZ-256    ; true (non-zero) for non-256 sizes
AND RXMASK        ; wrap mask after INC and SUB operations
ENDIF
```
For 256 (default), `RXBUFSZ-256 = 0` so no AND masks are generated (optimal).
For smaller power-of-2 sizes (128, 64, 32): AND RXMASK instructions are included
at each wrap/subtract point. Cost: +4B/+14T in RCA ISR, +4B/+14T in READER.

256 is the Z80 sweet spot: 8-bit register overflow = free modular arithmetic.

## MAME null_modem Setup
- MAME's Z80 SIO emulates real hardware RTS behavior: clearing WR5 RTS bit in async
  mode delays /RTS deassertion until ALL_SENT (transmitter empty). This is correct
  per Z80 SIO datasheet. In receive-only operation, ALL_SENT remains true from reset,
  so deassertion is immediate.
- Lua autoboot script sets `FLOW_CONTROL=0x01` (RTS) on null_modem device.
  Without this, null_modem ignores RTS and sends at full speed.
- See `rcbios/run_mame.sh` for complete MAME launch pattern.

## Serial File Transfer Workflow
1. Start MAME with `run_mame.sh` (builds BIOS, patches image, launches with serial)
2. In terminal: Ctrl-] then type filename to send file to CP/M
3. In CP/M: `pip test.txt=rdr:` to receive, `pip pun:=test.txt` to send back
4. For automated testing: use SUBMIT to chain commands, AUTOEXEC to run at boot

## Test Results
- 141 bytes (< buffer size): no data loss (pre-hysteresis fix)
- 2.7KB (50 lines, > buffer): data loss from line 7 without hysteresis fix
- 32KB (600 lines): zero data loss with hysteresis fix + register optimization
