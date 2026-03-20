# REL30 BIOS Improvement Opportunities (Parked)

All improvements apply only to REL30 (`-DREL30`). Existing releases (REL20-REL23, REL14)
must remain byte-exact against reference binaries.

## BLOCKING ISSUE: REL30 mini does not fit on system tracks

The mini (5.25") system tracks (Track 0 Side 0 + Side 1) provide 6144 bytes
(16×128 + 16×256). The current REL30 mini binary is **6426 bytes** — 282 bytes
over budget. It cannot be patched onto a mini disk image with `patch_bios.py`.
The space savings below (especially BGSTAR removal at 382 bytes) are needed to
bring REL30 mini within the system track budget. REL30 maxi (8", 9984 bytes
available) has more headroom and may already fit.

## 1. BGSTAR Removal — saves 382 bytes

Remove the background position bitmap (ESC S/F/C sequences). BGSTAR is a 250-byte
bitmap at 0xF500 tracking which screen cells were written in "background mode".
No known software uses these escape sequences, and they are absent from RC702E.

- **Code removed**: BGSTAR init (INIT.MAC), SETBG/CLRFG/ESCCF1 (DISPLAY.MAC),
  BGFLG/LOCBBU variables, BGSTAR bitmap scroll/shift in INSERT/DELETE LINE.
- **Space saved**: 382 bytes of code + 250 bytes of RAM (bitmap) + 3 bytes work area.
- **Risk**: Low. No known RC702 software uses ESC S/F/C.
- **Analysis**: `rcbios/BGSTAR_ANALYSIS.md`

## 2. JP→JR Optimization — saves ~110 bytes

Replace ~110 JP instructions with JR (2 bytes instead of 3) throughout the shared
BIOS code. All candidates verified in-range and using JR-compatible conditions
(Z, NZ, C, NC) or unconditional.

- **Space saved**: ~110 bytes (one byte per replaced JP).
- **Time saved**: JR takes 12T (taken) or 7T (not taken) vs JP's 10T always.
  Taken branches are 2T slower; not-taken branches save 3T. Net effect is
  negligible for most code paths, slightly negative for tight loops.
- **Implementation**: Wrap each change in `IFDEF REL30` / `ELSE` / `ENDIF` guards,
  or use a macro: `JRC COND,TARGET` that emits JR for REL30 and JP otherwise.
- **Risk**: None if guards are correct; verified by `make verify`.
- **Note**: 2 additional JR savings in REL30-only code (no guards needed).

## 3. CONOUT Optimization — saves ~154 bytes, 20% faster

Rewrite CONOUT path (DISPL, SCROLL, cursor update) to eliminate redundant register
saves, use faster addressing modes, and remove unnecessary indirection.

- **Normal char path**: 716T → 562T (21.5% faster)
- **Scroll path**: 40,345T → 31,950T (20.8% faster, visible improvement on full-screen scrolls)
- **Space saved**: ~154 bytes (estimated from analysis)
- **Key insight**: CP/M 2.2 BDOS does NOT require BIOS CONOUT to preserve any registers
  (verified against BDOS source). Current code saves/restores IX, IY, BC unnecessarily.
- **Analysis**: `rcbios/CONOUT_OPTIMIZATION.md` has full timing diagrams.

## 4. RXBUF Padding Reclaim — saves 113 bytes

SIO ring buffer (RXBUF, 256 bytes) requires page alignment. Current layout places
KBBUF (16 bytes) at 0xF37F, ending at 0xF38F, leaving a 113-byte gap to 0xF400.

- **Fix**: Move KBBUF to 0xF3F0 (adjacent to RXBUF) or reduce RXBUFSZ to 128
  (still adequate for 38400 baud with RTS flow control).
- **Space saved**: 113 bytes of RAM.
- **Risk**: None for KBBUF relocation. Reducing RXBUFSZ needs flow control margin analysis.

## 5. SECTRA No-op Removal — saves 3 bytes

SECTRA (sector translate BIOS entry) is `LD H,B / LD L,C / RET` — a no-op that
returns BC in HL. Actual sector translation happens in CHKTRK via TRANTB table.

- **Fix**: Point the BIOS jump table entry to a shared `LD H,B / LD L,C / RET`
  sequence (if one exists elsewhere), or inline.
- **Space saved**: 3 bytes.
- **Risk**: None.

## 6. Floppy Driver Loop Tightening — saves ~5-10 bytes

- **SELD loop** (SELD10): JP-based counted iteration, could use DJNZ or JR.
- **RWOPER shift loop** (RSECS): Always iterates SECSHF times (2 for 512-byte sectors).
  Could unroll for fixed geometry, or use JR.
- **FLO2/FLO3 busy-wait loops**: Use JP, could use JR (saves 1 byte each).

## 7. RCB ISR Already Removed

Channel B receiver ISR (dead code in all originals) is already removed in REL30 —
IVT entry points to DUMITR. No further action needed.

## Summary

| Improvement            | Bytes saved | Speed improvement     | Risk | Complexity |
|------------------------|------------:|----------------------|------|------------|
| BGSTAR removal         |    382 code | —                    | Low  | Medium     |
| JP→JR optimization     |       ~110  | Negligible           | None | Low        |
| CONOUT optimization    |       ~154  | 20% faster output    | Low  | Medium     |
| RXBUF padding reclaim  |    113 RAM  | —                    | None | Low        |
| SECTRA no-op           |          3  | —                    | None | Low        |
| Loop tightening        |       ~5-10 | Negligible           | None | Low        |
| **Total**              | **~767+**   |                      |      |            |

The biggest wins are BGSTAR removal (382B) and CONOUT optimization (154B + speed).
Together with JP→JR (110B), these would free ~646 bytes for new features.
