# 26-Line Display with Status Line

## Background

The ravn/rc702-bios assembly BIOS implements a 26th screen line by
reprogramming the Intel 8275 CRT controller. This document captures
the findings from analyzing that implementation and plans the port
to the C BIOS.

## Findings from ravn/rc702-bios

### How the 26th line is enabled

In `CDEF.MAC`, a build flag controls the feature:

    crt26  equ  yes

In `INIT.MAC`, the CRT 8275 reset sequence modifies the second
parameter byte:

```asm
LD  A,CRTreset      ; 8275 Reset command (0x00)
OUT (CRTctrl),A
LD  A,(CRT0)         ; PAR1: 0x4F → 80 chars/row
OUT (CRTdata),A
LD  A,(CRT1)         ; PAR2: 0x98 (25 rows, VRTC timing)
ifdef crt26
 sub  03fh           ; VerticalRetraceCount-1, LinesOnScreen+1
endif
OUT (CRTdata),A      ; PAR2 becomes 0x59 → 26 rows
```

The `SUB 0x3F` on the 8275 Parameter 2 byte achieves two effects
in one instruction:
- **High bits (7:6)**: VRTC retrace timing decremented by 1 scanline
  (making room for the extra character row)
- **Low bits (5:0)**: Row count incremented by 1 (25→26)

The value 0x98 encodes: bits 7:6 = 0b10 (VRTC=2), bits 5:0 = 0x18
(24 → 24+1=25 rows). After SUB 0x3F: bits 7:6 = 0b01 (VRTC=1),
bits 5:0 = 0x19 (25 → 25+1=26 rows).

### Screen memory layout with CRT26

```
0xF800  ┌─ 25 rows × 80 cols = 2000 bytes (normal display area)
        │  Rows 0-24, addressed by CONOUT cursor logic
0xFF9F  └─
0xFFA0  ┌─ Row 25: status line (80 bytes)
0xFFEF  └─
0xFFF0     0xFF terminator byte (stops DMA feed to CRT)
```

In `CONOUT.MAC`, the DMA word count adapts:

```asm
ifdef crt26
  screensize  defl  800h-5    ; 0x7FB = 2043 bytes
else
  screensize  defl  screenlength  ; 0x7CF = 1999 bytes
endif
```

The extra bytes cover the 26th row (80 bytes) plus a 0xFF stop byte.
The 8275 interprets 0xFF as "end of row" (all-ones special code),
which terminates the DMA transfer cleanly.

### INIT.MAC screen clear covers the 26th line

```asm
LD  BC,SCREENsize     ; 910307 — Erases also the 26th line
LD  (HL),' '
LDIR
ld  (hl), 0ffh        ; Last visible screenbyte. Stops DMA feed to CRT.
call  n$statl          ; Display default status line.
```

### Status line module (STATL.MAC)

The status line is a callback-based system:

- `N$STATL` — reset to default (clock display)
- `S$STATL(hl)` — set callback to HL; update immediately
- `U$STATL(hl)` — update only if HL is the active callback

The callback function returns HL pointing to a NUL-terminated string.
STATL copies up to 39 characters to `scstat` (0xF800 + 25×80), padding
with spaces.

```asm
scstat  equ  0F800h + (25*80)   ; byte 2000 of display memory
sclen   equ  39                 ; max status line length
```

### Clock module (CLOCK.MAC)

The default status line shows date and time: `DD/MM HH:MM`.
Updated from the 50Hz CRT interrupt via BCD arithmetic (DAA).
The tick counter and clock bytes are:

```asm
cl$yy:  db  93h        ; Year (BCD)
cl$mm:  db  04h        ; Month
cl$dd:  db  19h        ; Day
cl$tim: db  0          ; Hours
cl$min: db  0          ; Minutes
cl$sec: db  0          ; Seconds
cl$tck: db  ticks      ; Tick counter (50)
```

The `tick` routine is called from `IntDisplay` (the CRT ISR) 50×/sec.

### Keyboard-activated status line (KEYINT.MAC)

The SystemRequest key (CLEAR, 0x8C) activates a mode menu on the
status line: `D)isk, L)aTeX, I)SO, N)ormal`. This allows runtime
switching between keyboard mapping modes (Danish, LaTeX, ISO-8859-1).

### DMA ISR (C.MAC IntDisplay)

The CRT ISR programs DMA ch2 every frame with `SCREENBASE` and
`SCREENSIZE`. No DMA split (ch3 word count = 0). The 26th line
is simply part of the contiguous DMA transfer.

## Current C BIOS state

- `bios.h`: `Display[25]` = 25 rows, `SCRN_SIZE` = 2000
- `boot_confi.c`: `par2 = 0x98` (25 rows, standard)
- `bios_hw_init.c:202`: `port_out(crt_param, CFG.par2)` — writes par2 unmodified
- `bios.c isr_crt()`: DMA word count = `SCRN_SIZE - 1` = 1999
- No status line, no clock display, no 26th line

## Implementation Plan

### Phase 1: CRT26 — enable the 26th line

**Goal**: Get the 8275 to display 26 rows instead of 25.

1. **Add `CRT26` build flag** to Makefile (`-DCRT26`)
   - Both clang and SDCC variants

2. **Modify CRT init** in `bios_hw_init.c`:
   ```c
   #ifdef CRT26
       port_out(crt_param, CFG.par2 - 0x3F);  /* 26 rows */
   #else
       port_out(crt_param, CFG.par2);          /* 25 rows */
   #endif
   ```

3. **Extend display memory definitions** in `bios.h`:
   ```c
   #ifdef CRT26
   #define STATLINE    ((byte *)(DSPSTR + SCRN_SIZE))  /* row 25 */
   #define STAT_LEN    39          /* max status string length */
   #define DMA_SIZE    (SCRN_SIZE + SCRN_COLS + 1)  /* 2081: 25 rows + status + 0xFF */
   #else
   #define DMA_SIZE    SCRN_SIZE   /* 2000 */
   #endif
   ```

4. **Update isr_crt DMA word count** in `bios.c`:
   ```c
   hal_dma_dsp_wc(DMA_SIZE - 1);
   ```

5. **Clear 26th line + write 0xFF terminator** in `bios_hw_init.c`:
   ```c
   #ifdef CRT26
   memset(STATLINE, ' ', SCRN_COLS);
   screen[SCRN_SIZE + SCRN_COLS] = 0xFF;  /* DMA stop byte */
   #endif
   ```

6. **CONOUT stays 25 rows**: cursor addressing, scroll, insert/delete
   all remain bounded to rows 0-24. The 26th line is ISR-managed only.

Files: `bios.h`, `bios_hw_init.c`, `bios.c`, `Makefile`, `clang/Makefile`, `sdcc/Makefile`

### Phase 2: Status line driver

**Goal**: Callback-based status line, matching the assembly BIOS design.

1. **Status line API** (in `bios.h`):
   ```c
   typedef const char *(*statline_fn)(void);
   void statline_set(statline_fn fn);    /* S$STATL */
   void statline_update(statline_fn fn); /* U$STATL */
   void statline_reset(void);            /* N$STATL */
   ```

2. **Status line rendering** (in `bios.c`):
   - Copy up to `STAT_LEN` bytes from callback string to `STATLINE`
   - Pad remainder with spaces
   - Called from `isr_crt` (every frame) or on-demand

3. **Default status line**: show a simple clock (HH:MM) derived from
   the existing `rtc0` counter (already incremented 50×/sec in isr_crt).
   - BCD encoding not needed — can use integer division
   - Format: `DD/MM HH:MM` or simpler `HH:MM`

Files: `bios.h`, `bios.c`

### Phase 3: Interactive status line (optional, later)

- SystemRequest key triggers status line menu
- Disk status display (current drive, track)
- Keyboard mode switching

This phase matches the full ravn/rc702-bios feature set but is not
essential for the initial implementation.

## Verification

1. Build with `-DCRT26` for both clang and SDCC
2. MAME boot: verify 26th line visible, status line shows clock
3. CONOUT regression: cursor addressing, scroll, insert/delete line
   must all work correctly within the 25-row area
4. Screen clear (^L) must clear rows 0-24 and reset status line
5. No display corruption at row 25/26 boundary
6. Binary size impact: should be small (< 50 bytes for phase 1)

## References

- ravn/rc702-bios: `CDEF.MAC` (crt26 flag), `INIT.MAC` (CRT init),
  `CONOUT.MAC` (screensize), `C.MAC` (IntDisplay ISR),
  `STATL.MAC` (status line driver), `CLOCK.MAC` (clock display),
  `KEYINT.MAC` (keyboard menu)
- Intel 8275 datasheet: Reset command parameter encoding
- C BIOS: `bios.h` (ConfiBlock.par2), `bios_hw_init.c` (CRT init),
  `bios.c` (isr_crt DMA), `boot_confi.c` (default par2=0x98)
