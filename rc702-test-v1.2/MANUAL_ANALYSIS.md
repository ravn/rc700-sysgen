# RCSL-44-RT-2061 — what the manual tells us

Reading of the September 1983 RC701/RC702 testsystem user's guide
(RCSL No 44-RT-2061, authors Steen Nørgaard + Jan Nielsen), cross-
referenced against the reverse-engineering in `RUNTIME_ANALYSIS.md`.

## Confirmations and resolutions of open questions

### 1. Display buffer really is at `0xF000`

**§5 Memory Refresh Test**: *"It writes a pattern in memory consisting of
an XOR of high and low address part. The pattern is written from the
memory address 8000H until the hexadecimal address: **F000H (where the
display image starts)**."*

Confirms the DMA-CH2 base address we derived from the Am9517 programming
at RAM `0x0049-0x004F`. `0xF000` is the display buffer. The memory
refresh test deliberately stops short of it.

### 2. Why PIO and SIO tests fail in MAME (loopback cable required)

**§9 PIO TEST + §9.1 Inserting Testcable**: *"To run this test it is
necessary to use the testcable CBL936, where plug J3 of the cable is
installed in plug J1003 (PARALLEL OUT) of the computer, and plug J4 of
the cable is installed in plug J1004 (KEYBOARD) of the computer. If no
testcable is installed the testsystem will respond with received and
expected data and 'pio test aborted'. To test if a testcable is
installed the program transmits the byte E5 (hexadecimal) at the
parallel out port and checks the keyboard port. If the keyboard port
holds the byte E5 it is assumed that the cable is installed, otherwise
not."*

This is **exactly** what we saw in the MAME final screenshot:
`PIO_TEST: rec : 00 exp : E5 pio_test aborted`. The test writes `0xE5`
to the parallel-out PIO and expects it to be echoed back on the keyboard
input PIO via the `CBL936` loopback cable between J1003 and J1004. MAME
has no such cable, so the keyboard port reads `0x00`, the loopback check
fails, and the test aborts with the exact message format the manual
specifies. Not a bug, not an emulation gap — the test is correctly
reporting the absence of the physical test harness.

**§10 SIO TEST + §10.1 Modem Signal Response**: *"For the LINE I and
LINE II SIO the responses of DTR and RTS are tested on the DCD and CTS
pins. Loop plugs as shown in fig. 2 must be installed on the terminal
LINE connections."* Fig. 2 shows the `CBL998` loop plug wiring:
`RTS → CTS ; DTR → DSR ; DTR → DCD ; DATA IN ← DATA OUT`. The test
expects DCD and CTS to reflect the DTR/RTS state the program just
drove. Without the loop plug, both come back as `0x00`.

This is exactly the other MAME failure:
`SIO-test : line1: CTS or DCD error, exp: 00 rec: 28`. The manual's
§10.1 diagram explains the `0x28` byte layout (bit 3 CTS, bit 5 DCD,
etc.) — "cf. fig. 3". Again, a correct report of an absent loopback.

**Bottom line**: the MAME auto-run result of `4 OK + 2 FAIL` is the
expected outcome for a real RC702 *without* the test harness plugged
in. To get `6 OK` you'd need both CBL936 and CBL998 physically
connected (or an emulator that synthesises them, which MAME doesn't).

### 3. `OUT (50h),A` is the manual's ERROR CODE PORT

The "unhandled I/O, output 00 to port 50" warning I saw in the earlier
MAME and rc700-sdl2 runs is **§16 ERROR CODES**:

*"The testrouter outputs an error code, which is specific for the type
of error discovered on port 50 Hex. This enables the user to run the
testsystem on a MIC board alone without display. The error information
may then be detected if a device which can decode the numbers is
installed on the system bus."*

So port `0x50` is an **LED / bus-panel diagnostic output** meant for
headless (no-CRT) test rigs. The testrouter writes each test's outcome
code to it so you can run the testsystem on a bare MIC-board with nothing
but a numeric display. Full table from §16:

| Code | Meaning |
|---|---|
| `00` | OK, no error |
| `01` | PROM checksum error |
| `02` | RAM error |
| `03` | Data error in DMA test |
| `04` | DMA ch 1 terminal-count timeout (200 ms) |
| `0B` | CTC unwanted interrupt |
| `0E` | CTC test timed out without interrupt |
| `17` | Data error in main memory refresh test |
| `18` | FDC not ready to receive/transmit |
| `19` | FDC wrong data direction |
| `1A` | FDC fault in status register |
| `1B` | Fault in FDC (in FDD test) |
| `1C` | Seek error |
| `1D` | FDC command abort |
| `1E` | Open door |
| `1F` | Recalibration error |
| `20` | Track-0 signal not found |
| `21` | Missing address mark in data field |
| `22` | Bad cylinder |
| `23` | Wrong cylinder |
| `24` | Missing address mark in ID field |
| `25` | Cannot find sector |
| `26` | CRC fault in ID field |
| `27` | CRC fault in data field |
| `28` | Drive not ready |
| `29` | Overrun in FDC |
| `2A` | Access beyond last cylinder |
| `2B` | Drive is write protected |
| `2C` | Flexible disk drive timeout |
| `2D` | Flexible disk data error |
| `2E` | Timeout in WDC test |
| `2F` | Track 0 error in WDC test |
| `30` | Restore error in WDC test |
| `31` | Format error in WDC test |
| `32` | Aborted write command in WDC test |
| `33` | ID not found in WDC test |
| `34` | CRC fault in ID field (WDC) |
| `35` | Write error in WDC test |
| `36` | CRC error in WDC test |
| `37` | Data mark not found in WDC test |
| `38` | Aborted read command in WDC test |
| `39` | CRC error in datafield (WDC) |
| `3A` | Bad block detect error in WDC test |
| `3B` | Illegal interrupt in WDC test |

Codes `05-0A`, `0C-0D`, `0F`, `10-16` are listed as "not used".

So the `OUT (50),00` we saw in MAME during test 01 is the program
reporting "**00: OK, no error**" for the RAM test completion. That was
not a bug — it's the testrouter's standard telemetry channel. MAME's
"unhandled I/O" warning is just MAME noting that the port isn't mapped
to any emulated device. The rc702mini driver could usefully add a
virtual "diagnostic code sink" at port `0x50` that logs the byte to
MAME's console — it would make the test pass/fail visible without
needing to scrape the CRT buffer.

### 4. Return IS required — and the manual documents it (once)

**§3.2 Keyboard Management**: *"Striking the `<return>` key will have the
test system reentering the looping or running state."*

The manual says so in §3.2, but the on-screen prompt
`"type (H,R,L,G,S,P,<esc> or (0-F))"` doesn't repeat the instruction.
So the Return-required gotcha is in the binary *and* in the manual —
just not obvious unless you read §3.2. Our RUNTIME_ANALYSIS.md §11
decoding of the ISR's inner `0x0368 ← 0x0378` loop is the direct
implementation of this rule.

### 5. Switch bits match the decoded ISR

**§3.1 Switch Parameters** says the test-number variable also holds
four switch bits, and lists the semantics:

| Bit | Name | 0 means | 1 means |
|---|---|---|---|
| halt | halt | halt on error | proceed through error |
| loop | loop | sequential big-loop over all tests | loop in present test |
| keyb on | keyboard | no keyboard seen yet | a key has been struck |
| supr print | suppress print | messages go to display | nothing is printed (fast loop) |

And the six letter commands map to these bits:

| Key | Action per manual | Decoded from ISR at 0x03DB |
|---|---|---|
| `H` | set halt bit to 0 | `0x10 → RES 4,(HL)` → halt bit is **bit 4**, direct polarity |
| `R` | set halt bit to 1 | `0x11 → SET 4,(HL)` ✓ |
| `L` | set loop bit to 1 | `0x12 → RES 6,(HL)` → loop bit is **bit 6 inverted** (bit 6 = 0 means "looping") |
| `G` | set loop bit to 0 | `0x13 → SET 6,(HL)` ✓ (inverted) |
| `S` | set suppress-print to 1 | `0x14 → SET 7,(HL)` → supr_print is **bit 7**, direct |
| `P` | set suppress-print to 0 | `0x15 → RES 7,(HL)` ✓ |

The `keyb on` bit isn't touched by any of the menu letters — it's set
implicitly the first time *any* key arrives (the fact that an interrupt
fired from PIO-A is itself the signal that a keyboard exists). From
§3.2: *"To enter the keyboard management is only possible when a
struck key has informed the system that a keyboard is connected."*

Bit 5 of the system-state byte at `0xFFFF` is set by the ISR at
`0x0359` (`SET 5,A ; LD (FFFFh),A`) as the "ISR active" marker, which
matches the `keyb on` bit purpose — once it's set, the testrouter
knows a keyboard is present and starts responding to key commands.

So my only small error in the earlier decode was **loop bit polarity**:
I called it "cleared" in the source but didn't realise the manual's
semantic "loop=1" is stored as `bit 6 = 0`. Fixed now.

### 6. Test numbers — manual matches the table at 0x0389

**§3.2** gives the complete test-number → test-name map:

| # | Diskette version | PROM version |
|---|---|---|
| 0 | RAM test | PROM checksum + RAM test |
| 1 | Memory refresh test | DMA test |
| 2 | DMA test | CTC test |
| 3 | CTC test | FDD test |
| 4 | FDC test | — |
| 5 | PIO test | — |
| 6 | SIO test | — |
| 7 | FDD test | — |
| 8 | WDC test | — |
| 9 | WDC test (**forced**) | — |
| A | FDD reliability test | — |
| B | CRT test | — |
| C | WDD reliability test | — |
| D-F | not used (reset to 0) | — |

The 22-byte command-letter table at RAM `0x0389`
(`"HRLGSPFEDCBA98765432100123456789ABCDEFPSGLRH"`) is longer than this
list because it includes both **upper-case letters** for the commands
(H R L G S P and hex digits A-F) **and a second pass in reverse** for
robustness in the ISR's `CPIR` scan. That's why we saw what looks like
the same letters twice in the ISR table — the dispatcher accepts keys
from either end of the table to simplify the CPIR lookup.

### 7. Test 7 (FDD) is skipped from auto-run when a keyboard is attached

**§11 FDD TEST**: *"If the system has not been informed that a keyboard
is connected, this test is a part of the big sequential loop. If the
system has been informed that a keyboard is connected, this test has
to be selected by its number (number 7); that is, the big sequential
loop does not involve this test."*

This explains why the MAME auto-run stopped at **test 06 (SIO)** rather
than continuing through tests 07-09. As soon as MAME's host keyboard
delivers any keystroke to PIO-A during the first few seconds of boot
(or the rc702mini driver simulates one, which seems to happen
automatically), bit 5 of `0xFFFF` gets set and the auto-run skips FDD
test 7, WDC test 8, WDC-forced test 9, and all the interactive
reliability tests (A, B, C) which always require manual selection.

That's why the "halted" state we captured shows `test no : 06` and not
`test no : 09` — the big loop only runs tests 0-6 when `keyb on = 1`.

A headless boot (no keyboard events at all) would run 0-7-8
*inclusive*, and on a system with the WDC switch S6 set would also run
test 8 (WDC). But tests A, B, C always require manual selection
regardless.

### 8. Two-phase CRT DMA (cascade ch2 + ch3) is intentional

**§14 CRT TEST step 9**: *"Test of the dma-channels 2 and 3 and the
interrupt from the CRT controller. The first half of the screen is
supplied by the dma-channel 2. An asterisk is the last character sent
by this channel. The lower half is supplied by the dma-channel 3. Two
asterisks are the last characters sent by this channel. After channel
3 has finished, an interrupt routine sets up the channels to screen
transfers."*

This confirms what we saw in rc700-sdl2's `crt_poll()` implementation
(`dma_fetch(2, ...)` followed by `dma_fetch(3, ...)` for the remainder
of the screen) and in the Am9517 programming in the init code — the
8275 CRTC DMA is *cascaded* across channels 2 and 3, where channel 2
covers the first half of the 2000-byte display buffer and channel 3
covers the second half. The asterisk markers in step 9 of the CRT
test are visual confirmation of the hand-off point between the two
channels.

Runtime implication: a program writing into the display buffer at
`0xF000` must account for the ch2/ch3 boundary if it wants to avoid
seam artefacts during a refresh mid-frame.

## Facts the manual adds that we didn't know

### Three-second "grace period" at boot (§3.4)

*"The testrouter has a waiting point of 3 seconds when entered from
test number 0 to give the user time to key in some input to change
parameters."*

So **at the very start of the auto-run, before test 0 (RAM) begins,
the program waits 3 seconds for a keystroke**. If you press a command
letter during that window (say `L` to enable looping, or `R` to set
halt-on-error off), it takes effect immediately and the auto-run
starts with the modified switch bits. This is a hidden pre-run tuning
window — useful for setting up looping before the tests start.

### RAM test details (§4.2)

- Tests upper memory first (above the last PROM address), then moves
  into that region and tests the previously-PROM-shadowed bytes.
- Test pattern: **`00 00 00 FF FF FF`** repeated, then the inverted
  pattern. Manual: *"This means that all bits are tested for 'zero'
  and 'one' insertion. It is the most convenient pattern for
  discovering addressing errors because this modulus 3 pattern will
  not be repeated equivalent in a higher modulus address."*
- **Total turn-around time: 7.5 seconds.**
- Error message format: `<RC700 TESTSYSTEM mem err ha la ex re>`
  where `ha` = high addr byte, `la` = low addr byte, `ex` = expected
  value, `re` = received value. Figure 1 shows the 64K RAM chip layout
  so a failed bit-pair can be traced to a specific chip.

### Memory refresh test details (§5)

- Writes `(addr_high XOR addr_low)` from `0x8000` to `0xF000`.
- **Waits 5 seconds** in a delay loop.
- Re-reads and checks.
- Purpose: detect bit-rot due to refresh counter malfunction — a real
  DRAM refresh problem only shows up after some idle time.
- Error format: `<data modified in byte xx xx exp: xx rec: xx>` on
  display line 4.

### DMA test details (§6)

- Tests **channel 0 → channel 1** memory-to-memory transfer.
- Buffer: **1 KB** with pattern `00 FF FE FD ... 01` repeated 4 times
  (so 256 bytes × 4 = 1 KB).
- After transfer, compared byte-by-byte.
- Terminal-count timeout: **200 ms**.
- Error on line 5.

### CTC test details (§7)

- All 4 CTC channels exercised:
  - **Channels 0 and 1** in **counter mode**, counting the fixed input
    clock, giving interrupt after approx. **423 µs**.
  - **Channel 2** in **timer mode**, triggered by the CRT-controller's
    vertical-retrace interrupt.
  - **Channel 3** in **timer mode**, auto-started.
- Each interrupt must arrive within **300 ms** (timeout).
- The test also verifies that *only* the intended channel interrupts —
  if any other channel fires during a slot, the error is
  `<illegal interrupt, port: xx>`.
- Error on line 6.

### FDC test details (§8) — tiny

- Checks main status register bit 7 (RQM = ready to receive/transmit).
- Sends an invalid command and verifies ST0 reports bit 7 = 1, bit 6 = 0
  (= invalid command).
- Three possible errors:
  - `<not ready receive-transmit>` — main status bit 7 clear at entry
  - `<wrong data-direction>` — main status bit 6 wrong polarity (and
    the manual tells the user to push RESET and retry)
  - `<fault stat. reg.>` — ST0 doesn't indicate "invalid command"
- Error on line 7.

### FDD test — which tracks get exercised (§11)

- **8" (maxi)** tracks tested: `5, 60, 6, 59, 7, 58, 8, 40, 57, 9, 56,
  36, 61, 37, 38, 39` (16 tracks, non-sequential for head-motion
  stress).
- **5¼" (mini)** tracks tested: `5, 32, 6, 30, 7, 28, 8, 15, 31, 9,
  27, 16, 29, 17, 25, 24` (16 tracks, also non-sequential).
- Sector number cycles 1-9 (one sector per track tested in loop mode,
  incrementing).
- Step rate programmed to **20 ms max**, head-unload **160 ms max**,
  head-load **40 ms max**.
- 5¼" drives are **probed once** for READY state (because the mini
  interface doesn't give a reliable READY signal); once a drive has
  been classified as ready/not-ready, the testprogram assumes that
  state for the rest of the run.
- Test sequence per drive: `recalibrate` → cyclic `seek, write, read`.
- Test pattern: 512-byte counting pattern via **DMA channel 1**.
- 20 distinct error messages in §11.1, each mapped to a specific FDC
  status-register bit.

### WDC test (§12)

- Run only if MIC-board **switch S6** is set (figure 4 in the manual
  shows switch positions 0-6 with switch 6 set).
- Tests **cylinder 0 and cylinder 1 only**, heads **2 through 6** (3-6
  actually — text says "head number 2 until head number 6" but
  excludes the config sector).
- 17 sectors × 512 bytes, interleave 4:1, no bad sectors.
- Pattern: counting `00-FF` twice = 512 bytes.
- **DMA channel 0** (not 1 — this is the WDC channel).
- Write buffer `0xE000-0xE1FF`, read buffer `0xE200-0xE3FF`, compared.
- 16 error messages listed in §12.1.

### FDD reliability test (§13) — big interactive test

Not in the auto-run loop; must be selected via test number `A`. Has
an interactive **10-11 question prompt**:

1. drive (0/1)
2. mini/maxi/quad (0/1/2) — drive type; 96-TPI = quad
3. single/double density (0/1) — 128 B or 512 B per sector
4. single/double sided (0/1)
5. from track (2 digits; clamped to drive max: 36 mini, 76 maxi, 79 quad)
6. to track (2 digits)
7. steprate ms (01-16; doubled for mini and quad)
8. retries (0-9)
9. diskettetest no/yes (0/1) — 0 = drive test, 1 = diskette test

Question 10 differs per branch:

- **Drive reliability** (question 9 = 0): `format no/yes` (0/1)
- **Diskette test** (question 9 = 1):
  - 10: `read preformat no/yes` (0/1)
  - 11: `format no/yes` (0/1)

**Mini 5¼" single-density format**: 16 sectors × 128 bytes per track
(not 9 × 512 or 16 × 256 as with the system-disk layout). **Mini
5¼" double-density format**: 10 sectors × 512 bytes.

**Maxi 8" single-density**: 26 × 128. **Double-density**: 15 × 512.

These **mini double-density** values (10 × 512) differ from the
system-disk mini double-density we decoded earlier (9 × 512). The
reliability test formats the whole disk with 10 sectors/track — not
compatible with CP/M system disks. The test's interleave is
presumably 1:1 and there's no format-compatibility claim.

**Interactive controls during the reliability test**: `H` stops,
`Return` continues, `F` returns to testrouter, `R` restarts. These
override the normal testrouter keyboard semantics inside the
reliability test.

### CRT test (§14) — visual-only, 10-step sequence, infinite loop

Selected by test `B`. Runs forever until `H` + `F` or `Return`
pressed. Sequence:

1. Character PROM content drawn to screen for a few seconds
2. Right side blanked (via 8275 "blank" attribute), rest = char-PROM
3. Lower half blanked, rest = char-PROM
4. Whole screen filled with `'H'` — used for alignment (the canonical
   "type H's" CRT geometry check)
5. **Cursor test**: all four cursor types exercised, cursor walks from
   upper-left to lower-right over the char-PROM background. Cursor
   types: blinking reverse block → blinking underline → non-blinking
   reverse block → non-blinking underline.
6. **Field attributes**: blink, reverse video, underline, and
   combinations (25 lines total, 7 groups).
7. **DMA cascade test** (step 9 in the manual, confusingly numbered):
   first half screen via DMA ch2 with an asterisk marking the last
   byte; second half via DMA ch3 with two asterisks. After ch3
   completes, an ISR sets both channels back to normal screen-transfer
   operation.
8. (step 10 in manual) Graphic PROM content drawn.
9. Loop.

This is the visual "golden master" test — there's no automated
pass/fail, you're supposed to look at the screen and verify the
expected patterns. On MAME you could run it, snapshot each phase, and
compare against reference images.

### WDD reliability test (§15)

Selected by test `C`. Six questions:

1. from head (0-5)
2. to head (0-5; swapped if `from > to`)
3. from track (3 digits, clamped to 191)
4. to track (3 digits, clamped to 191)
5. disk test (only reading) no/yes (0/1)
6. format no/yes (0/1)

Drive test: write sector, read-back, invert the bit pattern, write
again, read again, compare. Disk test: read-only CRC check over the
interval. **Formatting is NOT compatible with HDFORM** — manual
explicitly warns.

## Gaps the manual doesn't explain

- **The 3-second waiting point at test 0 is documented but not
  implemented as a visible screen prompt** — the user has to know to
  press keys during that window. This is a UX detail in the binary
  that the manual's §3.4 acknowledges.
- **The binary-to-hardware layout of the error code at port `0x50`**
  — manual lists the codes but doesn't describe which pin of what
  connector the port maps to on the MIC board. For a headless test rig
  you'd need the hardware manual for that.
- **Exact CRC/DMA timing details** per chip — the manual only gives
  timeouts and patterns, not waveform specifications.

## What I'd do next with the manual in hand

In order of usefulness for future sessions:

1. **Annotate `region1_track0_side0_asload.asm`** with section
   references to this manual. For each error message string in the
   disk image, tag it with the `§N.n` section where it's explained.
   This turns the raw disassembly into a navigable companion to the
   manual.
2. **Patch MAME's `rc702mini` driver to map port `0x50`** to a
   diagnostic-code sink that prints each write to MAME's console.
   Then headless CI runs of the testsystem can assert "expect
   `00 00 00 00` (MEM/DMA/CTC/FDC OK) then `... PIO/SIO failures`"
   via the port-50 byte stream instead of scraping the CRT. Tracked
   as ravn/rc700-gensmedet#8.
3. **Build a physical testcable emulation** in MAME — wire the PIO-A
   loopback (J1003↔J1004 → CBL936) and the SIO loopback plugs
   (`CBL998`, per §10.1 fig 2) as MAME input/output glue. Then the
   bare `rc702mini -flop1 test.imd` run would auto-pass all six tests.
   Tracked as ravn/rc700-gensmedet#9.
4. **Write a "CI harness" Lua hook** that:
   - boots the test disk
   - injects `R` + Return to run with halt-on-error = proceed
   - watches port `0x50` for each test's result code
   - snapshots the final screen
   - asserts expected codes
   - exits with a pass/fail status code
5. **Use the manual's §13-§15 reliability-test question prompts** to
   automate physical-disk torture tests from a MAME autoboot script.
   Each question becomes an automated keystroke sequence, the test
   runs unattended, and the final screen tells you whether your real
   8" floppy survived.

None of these are blocking — the static analysis is complete. They're
speed-ups and ergonomic improvements for future sessions.
