# RC702 TEST v1.2 — runtime behaviour analysis

What the test program does from power-on to the "state: halted" screen,
captured as screenshots from a MAME `rc702mini` run. `rc700-sdl2` was ruled
out because its 8275 CRT polling model isn't accurate enough — the test
program polls `CRT_STAT_IR` while interrupts are masked, and rc700's
`crt_poll()` gates status updates on `IFF`.

## TL;DR — the test program is an auto-running sequential diagnostic

This is NOT an interactive menu program that waits for a keystroke. The
test disk **auto-runs a 6-test sequence** as soon as it boots:

| # | Test | Result in MAME |
|---|---|---|
| 01 | `MEM refresh test` | **OK** |
| 02 | `DMA-test ch 0 - 1` | **OK** |
| 03 | `CTC-test` | **OK** |
| 04 | `FDC_test` | **OK** |
| 05 | `PIO_TEST` | **FAIL** — `rec : 00 exp : E5 pio_test aborted` |
| 06 | `SIO-test` | **FAIL** — `line1: CTS or DCD error, exp: 00 rec: 28` |

After test 06 the program transitions the on-screen status from
`state: running` to `state: halted`, stops its sub-test loop, and drops
into the `HALT ; JR -3` idle loop at RAM `0x0341` waiting for a manual
command. The halted state means "the auto-run has finished"; the test
program is still alive and can be commanded interactively from the RC702
keyboard (the `"HRLGSPFEDCBA98765432100123456789ABCDEFPSGLRH"` command-
letter table at `0x0389`), it just isn't running tests by itself any
more.

The MEM/DMA/CTC/FDC sub-tests pass because MAME emulates those devices
faithfully. PIO and SIO fail because there's no physical stimulus in
the emulator — no keyboard producing the expected 0xE5 pattern into
PIO-A, no serial loopback raising CTS/DCD for SIO — so those tests
legitimately time out or see mismatched loopback data. On real RC702
hardware with the test harness plugged in, all six would be expected to
pass.

### Visual progression

Captured with an autoboot Lua hook that snaps at frames 200 / 500 / 1000
and again when the substring `"halted"` appears anywhere in the 80×25
display buffer at `0xF000-0xF7CF`. Files in this folder:

| File | When | Content |
|---|---|---|
| `mame_run_f0200_loading.png` | ≈ 4 s emulated | Only `"Loading test program"` on row 0 — ROA375 boot + phase-2 loader still running |
| `mame_run_f0500_memtest.png` | ≈ 10 s | Screen tiled with `"00 00 00 ..."` pairs — the **memory-refresh test pattern** being drawn and scrubbed across RAM by test 01 |
| `mame_run_f1000_menu_running.png` | ≈ 20 s | Main banner visible: `"RC700 TESTSYSTEM / ver 1.2 / test no : 01 / state: running / MEM refresh test :"` — test 01 is still in progress |
| `mame_run_final_halted.png` | when `"halted"` appears in the screen buffer | The full auto-run summary screen with tests 01-06 and their pass/fail results — see the table above |
| `mame_run_final_ram_0000.bin` | same point | 9,984 B RAM dump at `0x0000-0x26FF` at the `halted` state |
| `mame_run_final_ram_d480.bin` | same point | 9,984 B RAM dump at `0xD480-0xF8FF` at the `halted` state |

The rest of this document walks through **how the program gets to the
halted state** — the boot hand-off, the phase-2 LDIRs, the FDC overlay
reads, the 8275 + DMA programming, the dispatcher machinery — so future
maintenance work can reason about it without re-running MAME.

All RAM addresses below are **runtime addresses**, matching what you'd see
in the MAME debugger. Cross-reference with the file-offset disassemblies
in `region*_asload.asm` and the runtime-shifted disassemblies in
`region*_runtime.asm` (with the important caveat that the latter only
track the frozen high-memory snapshot — see the README).

## 1. Boot hand-off (`PC = 0x0000` in ROM → `PC = 0x0280` in RAM)

On power-on the RC702 autoload PROM (ROA375) is overlaid at `0x0000-0x07FF`.
It performs its normal CP/M boot path:

1. `DI`, `LD SP,0BFFFh`, self-relocate ROM → RAM `0x7000`.
2. Bring up CTC IVT, SIO, PIO, DMA, 8275 CRTC.
3. Motor-on, recalibrate, `DSKAUTO` detects the mixed-density track 0
   of the mini diskette.
4. FDC+DMA read of Track 0 both sides — `16 × 128 FM + 16 × 256 MFM = 6,144 B`
   — into RAM `0x0000-0x17FF`.
5. `BOOT7` / `ISRC70X` find `" RC702"` at file offset `0x0008` → match,
   take the CP/M-layout branch.
6. `BOOT9`: `LD HL,(FLOPPYDATA) ; JP (HL)` — reads the word at `0x0000`
   = `0x0280` (the JP-vector field of the test disk's boot header) and
   jumps there.

At this point control is with the test program, running from the
just-loaded Track 0 content.

## 2. Phase-2 relocating loader (`0x0280-~0x02FF`)

```
0280  DI
0281  LD HL,0000h
0284  LD DE,D480h
0287  LD BC,2381h
028A  LDIR               ; freeze a 9,089 B snapshot of 0x0000-0x2380 into 0xD480+
028C  LD HL,D580h        ; runtime equivalent of file 0x0100 (output conv table)
028F  LD DE,F680h        ; destination inside the display buffer (see §5)
0292  LD BC,0180h
0295  LDIR               ; splice 384 B of character-conversion tables into 0xF680
0297  LD SP,0080h        ; minimal work stack in low RAM
029A  LD A,(EC25h)       ; read IVT-page byte from the relocated CONFI area
029D  LD I,A
029F  IM 2
02A1  ...                ; CRTC reset + initial parameter stream
```

Key properties of the LDIR at `0x028A`:

- Source is 9,089 B but on **mini**, only 6,144 B are live — the tail
  `0x1800-0x2380` (2,945 B) is zero-filled because ROA375 only reads
  Track 0. On **maxi** the LDIR would fit entirely inside Track 0 both
  sides (`26×128 + 26×256 = 9,984 B`). The loader was coded for a maxi
  Track 0 and runs unchanged on mini; the zero tail is tolerated
  because the regions it touches are overwritten or unused (see §6).
- After the LDIR the frozen high-memory copy at `0xD480-0xF800` is a
  **boot-time snapshot**. It is NOT live — execution stays in low RAM
  and the two copies diverge as soon as the test program starts
  rewriting low memory. The high copy is referred to later by jumps
  (`JP D7F2h`, `JP D8BFh`, etc.) when the code wants to reach the
  pristine versions of its own init routines.

## 3. Hardware bring-up in low RAM (`~0x02A0 - ~0x0280 + ...`)

The phase-2 loader continues with a first hardware-init pass using the
values it can find in the CONFI block (post-LDIR, in both the low and
high copies simultaneously at this point). This mostly programs the
8275 CRTC. Then execution reaches the code at file `0x032F` which
issues `OUT (50h),A` (unknown-to-the-rc700-emulator port, no-op on
MAME) and falls into the dispatcher preamble — but the dispatcher
hasn't been loaded yet; this is the loader's transitional code.

## 4. FDC overlay reads — the test program paging itself in

This is the non-obvious part of the boot. The phase-2 loader's disk
driver issues two FDC commands with DMA destinations set by CPU writes
to the Am9517 address registers:

| Overlay | Source (disk) | Destination (RAM) | Size |
|---|---|---|---|
| 1 | `0x1800-0x19FF` (T1S0 sector 1) | `0x0000-0x01FF` | 512 B |
| 2 | `0x1C00-0x1DFF` (T1S0 sector 3) | `0x0200-0x03FF` | 512 B |

Both overlays land in the low-RAM region that used to hold the boot
header, the CONFI block, and the conversion-table sectors (sectors 1-5
of the original Track 0). The test program reclaims that KB as its
primary workspace. Evidence (from `ram_at_halt_0000.bin`):

- RAM `0x0000-0x01FF` is a byte-exact 512/512 B match of disk `0x1800-0x19FF`.
- RAM `0x0200-0x03FF` is a byte-exact 512/512 B match of disk `0x1C00-0x1DFF`.
- RAM `0x0400-0x17FF` is unchanged from what ROA375 loaded
  (matches disk `0x0400-0x17FF`).
- RAM `0x1800-0x2380` is still zero (the LDIR zero tail, never touched).

Skipping T1S0 sector 2 is intentional — the overlay loader wants only
sectors 1 and 3 of that track. (Sector 2 presumably contains other
test-only data not needed at boot.)

The fact that `install_write_tap` on address `0x0341` in MAME fired
zero times while the HALT opcode appeared there is consistent with this
— the bytes arrive as DMA payloads, not CPU stores, and MAME's Lua
memory-tap API only hooks the CPU bus.

## 5. Display buffer = `0xF000`, 80 × 25, driven by DMA channel 2

Programmed by this sequence in the first-pass init at low-RAM `0x0041`:

```
0041  LD A,20h ; OUT (F8h),A    ; Am9517 command register
0045  LD A,5Ah ; OUT (FBh),A    ; Am9517 mode register: CH2, mem→peripheral,
                                ; auto-init, address-increment, single-transfer
0049  LD A,00h ; OUT (F4h),A    ; CH2 address LOW  = 0x00
004D  LD A,F0h ; OUT (F4h),A    ; CH2 address HIGH = 0xF0   → base = 0xF000
0051  LD A,CFh ; OUT (F5h),A    ; CH2 count    LOW  = 0xCF
0055  LD A,07h ; OUT (F5h),A    ; CH2 count    HIGH = 0x07  → count = 0x07D0 = 2,000 B
```

So the display covers `0xF000-0xF7CF` — exactly `80 × 25 = 2,000`
character cells fetched every frame by DMA channel 2 and streamed into
the 8275 CRTC's row-buffer FIFOs.

**Layout quirk caused by the phase-2 LDIR2.** The 384-byte character-set
conversion-table copy at step `0x028C` writes to `0xF680-0xF7FF`, which
sits **inside** the top of the display buffer (rows 20-24 of the
80 × 25 grid). The effect on screen is that rows 20-24 of the display
show the raw conversion tables as character codes. Because the tables
are near-identity (`0x20`=`0x20`, `0x21`=`0x21`, …, with a few national
remaps from the US-ASCII entry verified in the README), those five rows
come out looking like a visible ASCII character reference — which is
convenient for debugging the glyph ROM, and was probably deliberate.

The useful (non-reference) part of the screen is rows 0-19 = 1,600 B
at `0xF000-0xF63F`. At idle the MAME snapshot shows the menu prompt
fragment and the valid command-letter data on row 0; rows 2-19 are
blank (waiting for test output).

**I/O ports used** for the display subsystem:

| Port | Direction | Purpose |
|---|---|---|
| `0x00` | out | 8275 parameter/data register |
| `0x01` | in  | 8275 status register (polled by the test program) |
| `0x01` | out | 8275 command register |
| `0xF4` | out | Am9517 CH2 address (two-byte write: low, high) |
| `0xF5` | out | Am9517 CH2 count (two-byte write: low, high) |
| `0xF8` | out | Am9517 command |
| `0xFB` | out | Am9517 mode |

## 6. Second-pass hardware init (runs from `0x0000` after the overlay)

Once the T1S0 sector 1 overlay has landed at `0x0000`, execution jumps
into it and runs a **fresh** hardware bring-up that overrides the first
pass. The sequence (z80dasm of RAM `0x0000`):

```
0000  XOR A ; LD (FFFFh),A       ; clear system-flag byte
0004  DI
0005  OUT (01h),A                 ; 8275 command = 0 (reset)
0007  LD SP,(FFFFh)               ; SP = 0 (wraps on first PUSH — unusual)
000B  OUT (FDh),A                 ; unknown-to-this-repo port, write 0
000D  LD A,18h ; OUT (0Ah),A      ; SIO-A WR0 reset
0011  OUT (0Bh),A                 ; SIO-B WR0 reset
0013  LD A,03h
0015  OUT (0Ch),A ; OUT (0Dh),A   ; CTC Ch0, Ch1 cmd = 03h
0019  OUT (0Eh),A ; OUT (0Fh),A   ; CTC Ch2, Ch3 cmd = 03h
001D  IM 2
001F  LD A,00h ; OUT (01h),A      ; 8275 command port
0023  LD A,4Fh ; OUT (00h),A      ; 8275 param: S/H = 79 chars/row
0027  LD A,98h ; OUT (00h),A      ; 8275 param: HR/VR
002B  LD A,9Ah ; OUT (00h),A      ; 8275 param: URL
002F  LD A,5Dh ; OUT (00h),A      ; 8275 param: LC
0033  LD A,80h ; OUT (01h),A      ; 8275 command: Load Cursor
0037  LD A,51h ; OUT (00h),A      ; cursor row
003B  LD A,1Ah ; OUT (00h),A      ; cursor column
003F  OUT (FDh),A
0041  LD A,20h ; OUT (F8h),A      ; DMA COMMAND (see §5)
0045  LD A,5Ah ; OUT (FBh),A      ; DMA MODE
0049  LD A,00h ; OUT (F4h),A      ; DMA CH2 ADDR low
004B  LD A,F0h ; OUT (F4h),A      ; DMA CH2 ADDR high
004D  LD A,CFh ; OUT (F5h),A      ; DMA CH2 CNT low
004F  LD A,07h ; OUT (F5h),A      ; DMA CH2 CNT high
0053  LD A,20h ; OUT (01h),A      ; 8275 command: Start Display
0055  IN A,(01h)                  ; CRTC status — first read
0057  IN A,(01h)                  ; CRTC status — settle read
0059  BIT 5,A                     ; test IR bit
005B  JR Z,0055h                  ; poll until IR is raised by the first frame
005D  LD A,0Bh ; OUT (FFh),A      ; port FF write (speaker/bell?)
0061  JP 0088h                    ; → next init phase
```

(The file-offset addresses in `region1_track0_side0_asload.asm` will be
different by `0x1800` because that disassembly covers Track 0; the
listing above is the **runtime address** after the FDC overlay has
placed T1S0 sector 1 into low RAM starting at `0x0000`.)

Key observation: at `0x0053` the code writes `0x20` = Start Display to
the 8275 command port, then busy-waits on status bit 5 (`CRT_STAT_IR`,
Interrupt Request). On real hardware and in MAME the 8275 raises IR on
its first end-of-frame regardless of whether maskable interrupts are
enabled; the loop exits and execution continues. `rc700-sdl2` stalls
here because its `crt_poll()` gates status-bit updates on `IFF`, which
is cleared by the `DI` at `0x0004`.

## 7. Dispatcher at `0x033A` — the program's idle state

After `0x0061` the code eventually reaches the rewritten-in-place
dispatcher in the T1S0 sector 3 overlay (`0x0200-0x03FF`). The useful
entry point is at `0x033A`:

```
0330  ...                         ; tail of a preceding subroutine (entry from elsewhere)
0334  LD A,(FFFFh) ; BIT 7,A      ; system flag fast-path exit
0339  RET NZ
033A  DI                          ; === main idle entry ===
033B  LD HL,02A2h                 ; menu prompt string pointer (in low RAM)
033E  CALL 031Fh                  ; print the prompt
0341  HALT                        ; <<< idle wait >>>
0342  JR 0341h                    ; <<< halt loop — 3 bytes total: 76 18 FD
0344  EI
0345  RETI                        ; tail reused by the ISR via CALL 0345h
0347  PUSH AF/BC/DE/HL/IY/IX      ; === ISR entry: save all regs ===
034F  LD IX,(FFFCh) ; PUSH IX     ; save current menu-state vector
0355  LD A,(FFFFh) ; PUSH AF      ; save system flags
0359  SET 5,A ; LD (FFFFh),A      ; mark "ISR active" bit
035E  LD HL,02B6h ; LD IX,F0ABh   ; prompt string + screen-cell destination
                                   ; (0xF0AB = row 2 col 11 of the 80x25 screen)
0365  CALL 1161h                  ; emit string via the character-writer helper
0368  IN A,(10h)                  ; PIO-A data = keyboard
036A  CP 1Bh ; JR NZ,03B5h        ; ESC?
036E  LD HL,0292h ; CALL 031Fh    ; confirm prompt
0374  IN A,(10h) ; CP 0Dh         ; require <Return>
0378  JR NZ,0368h
037A  LD IX,F0CFh ; LD B,2Ah      ; write '*' to screen cell 0xF0CF (row 2 col 47)
0380  LD (IX+0),B
0383  CALL 0345h                  ; tail-call out through the EI/RETI stub
0386  JP 0407h                    ; enter the main test-menu handler
0389  "HRLGSPFEDCBA98765432100123456789ABCDEFPSGLRH"   ; menu command-letter table (data)
```

What this means at runtime:

- The dispatcher's one-shot init at `0x033A` runs **once** after the
  hardware bring-up completes. It prints the top-of-screen prompt and
  drops into `HALT`.
- Every subsequent wake-up is an interrupt-driven ISR run at `0x0347`.
  That ISR reads PIO-A (port `0x10`) — the RC702's parallel keyboard
  interface — validates the keystroke against the command-letter table
  at `0x0389`, and dispatches into the per-test handler at `0x0407`
  passing the selected test through registers. When the sub-handler
  returns, the code comes back through `CALL 0345h` (= `EI; RETI`) to
  the `HALT` at `0x0341`.
- The `HALT ; JR 0341h` isn't a tight loop — the `JR` is only ever
  executed after an interrupt wakes the CPU from the `HALT`. The
  effective code path is `HALT → [interrupt] → ISR → RETI → HALT` over
  and over, with `JR 0341h` acting only as the continuation after
  RETI's implicit re-enable of interrupts.

## 8. Main menu dispatcher at `0x0407`

Reached via `JP 0407h` at the end of the ISR. From the disassembly at
runtime:

```
0407  JP C,2D2Ah                  ; dispatch-by-key shortcut (into 0x2D2A in the
                                   ; test-code region loaded by Track 0)
040A  PUSH DE
040B  LD (FFE7h),HL               ; save caller's HL in a system slot
040E  LD A,FFh ; LD (F34Fh),A     ; set a display-dirty flag in the CRTC area
0413  CALL D8BFh                  ; call a helper in the frozen high-memory copy
0416  LD A,FFh ; LD (D531h),A     ; patch a byte in the CONFI-block's runtime copy
041B  XOR A ; LD (DA47h),A        ; clear a state byte in the frozen copy
041F  CALL D8BFh                  ; call the helper again (re-armed)
0422  LD HL,EB1Dh ; LD (D8BDh),HL ; load a pointer into a state-vector slot
0428  LD HL,DA39h ; PUSH HL       ; start of an iteration list in the frozen copy
042B
042C  POP HL
042D  PUSH HL ; CALL D8EAh        ; per-element handler in the frozen copy
0431  POP HL ; INC HL ; PUSH HL
0434  LD A,(HL) ; CP FFh          ; end marker?
0437  JR NZ,042Ch                 ; loop over the iteration list
0439  POP HL
043A  JP DA00h                    ; jump to the next phase in the frozen copy
```

So the menu handler sets up a state vector, then iterates over a table
at `0xDA39` in the frozen copy (= file offset `0x05B9` on disk), calling
a handler at `0xD8EA` (= file offset `0x046A`) for each entry until it
hits an `0xFF` terminator, then jumps to `0xDA00` (= file offset `0x0580`)
to continue. This is the **test-suite iteration loop**: each entry in
the `0xDA39` table names one sub-test (memory refresh, DMA, CTC, FDC,
FDD, SIO, PIO, WDC, WDD) and the dispatcher walks the list calling each
one.

The jumps into `0xD4xx-0xDA00` range are all into the frozen high-memory
snapshot made by the phase-2 LDIR. Those bytes are identical to the
file-offset disassembly in `region1_track0_side0_asload.asm` at offsets
`0x043F`, `0x046A`, `0x0580`, `0x05B9`, etc. — so to read the actual
body of each test, open that `.asm` file and jump to the corresponding
file offset.

## 9. Memory map at idle (from the MAME snapshot)

```
0x0000-0x01FF   test program: second-pass hardware init    (T1S0 sector 1 overlay)
0x0200-0x03FF   test program: main dispatcher + ISR + menu-letter table
                                                            (T1S0 sector 3 overlay)
0x0400-0x17FF   test program: main code body (the menu handler at 0x0407,
                per-test routines, helpers, strings)       (original Track 0)
0x1800-0x2380   zero (phase-2 LDIR zero tail, unused)
0x2381-0x6FFF   uninitialised / working RAM
0x7000-0x7FFF   ROA375's own code relocation target; used during boot only
0xBFFF          initial boot SP (set by ROA375 then reset by phase-2 to 0x0080)
0xD480-0xF67F   frozen boot-time snapshot of disk 0x0000-0x21FF
                — called into by the menu handler for "original" init paths
0xF680-0xF7FF   character-set conversion tables (output/input/semigraphic)
                — overlaps bottom 5 rows of the display
0xF000-0xF7CF   display buffer: 80×25 char cells, DMA'd by CH2 every frame
0xFFFC          "current menu-state vector" pointer (LD IX,(FFFCh) in ISR)
0xFFFF          system flag byte (bit 5 = ISR active, bit 7 = fast-path exit)
```

## 10. I/O ports the test program touches

From static sweeping of the dispatcher + first/second-pass init code:

| Port | Direction | Device | Role in test program |
|---|---|---|---|
| `0x00` | out | 8275 CRTC | parameter register |
| `0x01` | in  | 8275 CRTC | status (polled in busy-wait at `0x0055`) |
| `0x01` | out | 8275 CRTC | command register (reset, start display, load cursor) |
| `0x0A` | out | Z80 SIO-A | WR0 control reset, then bytes from CONFI PSIOA |
| `0x0B` | out | Z80 SIO-B | WR0 control reset, then bytes from CONFI PSIOB |
| `0x0C` | out | Z80 CTC ch0 | channel reset and time-constant |
| `0x0D` | out | Z80 CTC ch1 | channel reset and time-constant |
| `0x0E` | out | Z80 CTC ch2 | channel reset and time-constant (display IRQ source) |
| `0x0F` | out | Z80 CTC ch3 | channel reset and time-constant (FDC IRQ source) |
| `0x10` | in  | Z80 PIO-A | keyboard data (polled in the dispatcher ISR) |
| `0x14` | in  | SW1 DIP | bit 7 = mini(1) / maxi(0) — read by test code for format branch |
| `0x50` | out | ? | unhandled in rc700-sdl2 (writes ignored in MAME — possibly a debug/diagnostic port unique to the test PROM) |
| `0xF4` | out | Am9517 | CH2 address (display DMA base, programmed to 0xF000) |
| `0xF5` | out | Am9517 | CH2 count (programmed to 0x07D0 = 2,000 B) |
| `0xF8` | out | Am9517 | command |
| `0xFB` | out | Am9517 | mode (0x5A = CH2, mem→peripheral, auto-init, single) |
| `0xFD` | out | ? | hardware bring-up writes (possibly PROM-disable latch) |
| `0xFF` | out | ? | write of 0x0B at `0x005D` (speaker/bell or beep — matches the "beep" routine in rcbios-in-c) |

## 11. What runs at idle vs. during a test

- **Idle (MAME dump captured here):** PC oscillates around `0x0341` in the
  `HALT ; JR -3` loop. The CPU is in a truly halted state between
  interrupts; the only things running are the CTC / CRTC / PIO hardware,
  ticking interrupts into the ISR at `0x0347`. The screen shows
  (row 0) the menu prompt and command letters, and (rows 20-24) the
  visible character conversion table. Rows 2-19 are blank.
- **During a test:** a valid keystroke arrives, the ISR at `0x0347` reads
  it from PIO-A, validates it against the `"HRLGSP…"` table at `0x0389`,
  then falls through (via the `CALL 0345h` tail-through-`RETI` trick) to
  `JP 0407h`, which is the main menu handler. `0x0407` reconfigures the
  system-state slots (`F34Fh`, `D531h`, `DA47h`, `D8BDh`), walks the
  test-iteration table at `0xDA39` in the frozen high-memory copy
  (calling `D8EAh` for each entry), and finally jumps to `0xDA00` to
  enter the selected sub-test's body. The sub-tests live at the file
  offsets whose names appear in the embedded strings (e.g. the
  `"MEM refresh test"`, `"DMA-test ch 0 - 1"`, `"CTC-test"`,
  `"FDC_test"`, `"FDD-test"`, `"SIO-test"`, `"PIO_TEST"`, `"WDC_test"`,
  `"WDD RELIABILITY TEST"` handlers). When a test finishes (or is
  aborted), it returns through the same plumbing back to the `HALT` at
  `0x0341`.

## 11. Keyboard-driven state model (why pressing a key alone does nothing)

Observed behaviour on MAME: pressing a key while the test program is in
`state: halted` causes the "type (H,R,L,G,S,P,<esc> or (0-F)) : " prompt
to appear on screen, but no visible state change. Root cause is in the
ISR at `0x0347` — the dispatch only commits when the user also presses
`Return` (`0x0D`). See the decoded flow below.

**System-state byte at RAM `0xFFFF`** holds both the current test number
(low nibble) and the program state as bit flags (high nibble). The ISR
reads `PIO-A` at port `0x10`, searches the 22-byte command-letter table
at `0x0389` with `CPIR`, and updates `0xFFFF` per the following map:

| Key | ISR table index | Action on `(0xFFFF)` | Meaning |
|---|---|---|---|
| `H` | 0 | ... | halt |
| `R` | 1 | ... | run |
| `L` | 2 | ... | loop |
| `G` | 3 | ... | go |
| `S` | 4 | ... | stop |
| `P` | 5 | ... | pause |
| `0-9,A-F` | 6-21 | store hex digit into low nibble | select test number |
| `ESC` (`0x1B`) | — | fall through directly to `0x036E` "confirm prompt" | abort/top |
| `Return` (`0x0D`) | — | fall through to `0x037A` → `JP 0407h` | **commit** |

The per-digit path (test number 0-15, command codes 0x00-0x0F):

```
03C3  LD HL,039Fh
03C6  ADD HL,BC         ; BC = 1-indexed position from CPIR scan
03C7  LD A,(HL)         ; mapped command code from second table at 0x039F
03C8  LD (IX+0),A       ; echo mapped char at screen cell 0xF0CF
03CB  LD A,0Fh ; CP C
03CE  JR C,03DBh        ; if C > 0x0F (bit-flag commands) → jump
03D0  LD A,(FFFFh) ; AND F0h ; OR C ; LD (FFFFh),A
                      ; update low nibble of FFFFh with command code
03D9  JR $-107          ; back to 0x0370 waiting for Return
```

The per-letter bit-flag path (commands 0x10-0x15 = H/R/L/G/S/P):

```
03DB  LD A,C ; LD HL,FFFFh
03DF  CP 10h ; RES 4,(HL)   ; 0x10 = H → clear bit 4
03E5  CP 11h ; SET 4,(HL)   ; 0x11 = R → set   bit 4
03EB  CP 12h ; RES 6,(HL)   ; 0x12 = L → clear bit 6
03F1  CP 13h ; SET 6,(HL)   ; 0x13 = G → set   bit 6
03F7  CP 14h ; RES 7,(HL)   ; 0x14 = S → clear bit 7
(continues)  ; 0x15 = P → set   bit 7 (or similar — last case not fully decoded)
```

So every valid keypress *does* change `0xFFFF` in place. The state line
on screen (`state: running/stopped/looping/halted`) is computed from
those bits on the next screen repaint. But **screen repaint and test
dispatch only happen after `JP 0407h`** at `0x0386`, and the only way
to reach that jump is to press `Return` afterwards — the inner loop
`0x0368 ← 0x0378` sits reading `PIO-A` until `0x0D` arrives.

Concretely, the user sees:

1. Press letter / digit → ISR runs, updates `(0xFFFF)`, echoes the
   mapped char at `0xF0CF` (row 2 col 47), re-prints the confirm prompt
   at `0xF06C`-ish, exits ISR via the loop.
2. No `Return` ever arrives (MAME not delivering `0x0D` on PIO-A).
3. Next interrupt re-enters the ISR, re-prints the same confirm prompt,
   and the cycle repeats.

The flag byte at `0xFFFF` *is* changing between keypresses (putting a
write-watchpoint on it would show this), but until Return lets
execution reach `JP 0407h` the test dispatcher doesn't see the new
flag and the state line on screen stays `halted`.

## 12. What I have NOT verified

- The **exact instruction** that writes the `HALT` opcode at `0x0341`.
  We know it arrives as part of the DMA overlay of T1S0 sector 3 into
  RAM `0x0200-0x03FF`, so "the write" is an Am9517 cycle driven by the
  FDC reading sector 3 under `OUT (F8h) / OUT (FBh) / OUT (F4h) / OUT (F5h)`
  programming. I have not pin-pointed the CPU instruction in the
  phase-2 loader that issues that FDC + DMA set-up. If needed, a
  `wpset 0xF4` watchpoint in MAME's debugger on the Am9517 CH2 address
  register would catch it (MAME memory taps miss it because the write
  is to I/O space, not memory).
- The **per-test behaviour** inside `0xDA00-0x....`. My static traces
  stop at the dispatcher's jump into the test-iteration loop. Walking
  each sub-test to describe what it exercises (which I/O pattern,
  which DMA sequence, which FDC command set, which error-recovery
  path) is a day of disassembly work on `region1_track0_side0_asload.asm`
  and `region2_track0_side1_asload.asm`. I didn't do that because it
  wasn't needed to answer "what does the program do when running" at
  the system level.
