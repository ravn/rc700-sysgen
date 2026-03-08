# TODO: 26th Display Line

## Goal
Add a 26th line to the RC702 display (status line, 80x26 = 2080 bytes).

## Requirements

1. **Move work area**: The current work area at 0xFFD0-0xFFFF overlaps with
   the extended display buffer (0xF800 + 2080 = 0x0020 past 0xFFFF).
   Display would need 0xF800-0xF81F of the next page — but there is no
   next page (wraps to 0x0000).
   - Work area variables must be relocated elsewhere
   - Put them in a separate include/header so the address is configurable
   - Candidate locations: somewhere in 0xF500-0xF7FF range

2. **Reprogram 8275 CRT controller**: Change PAR2 from 25 to 26 rows.
   The 8275 PAR2 encodes rows/frame and VRTC timing — need to verify
   the exact encoding for 26 rows and whether VRTC timing needs adjustment.

3. **DMA termination byte**: Place a stop/end-of-row attribute byte at
   the end of line 26 (around 0xFFFE) to prevent the DMA from wrapping
   past 0xFFFF into 0x0000, which would cause visual flicker/garbage.
   The 8275 uses special character attribute codes — need to identify
   the correct "end of screen" marker.

4. **Display buffer size**: SCRN_SIZE changes from 2000 to 2080.
   DMA word count in CRT ISR changes accordingly.
   Scroll copies 2000 bytes instead of 1920. Fill clears line 26.

## Open Questions

- Does MAME's 8275 emulation support 26 rows? May need to test or
  read MAME source (`src/devices/video/i8275.cpp`).
- What is the correct DMA termination mechanism for the 8275?
  Options: special attribute code, or just program DMA for exactly 2080 bytes.
- Does the 8275 handle the case where display RAM wraps at 0xFFFF→0x0000?
  If the DMA controller wraps (Am9517A does 16-bit wrap), the 8275 might
  display garbage from low memory.
- Impact on BGSTAR bitmap size (not relevant — BGSTAR is omitted in REL30-C).

## Implementation Notes

- The 26th line is for status display only (not scrolled).
- CONOUT scroll should only scroll lines 0-24, leaving line 25 fixed.
- Alternatively, scroll all 26 lines and manage status line separately.
