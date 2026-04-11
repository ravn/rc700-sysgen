# RC702 TEST v1.2 — diagnostic floppy image

Preserved copy and best-effort disassembly of the **RC700 TESTSYSTEM v1.2**
diagnostic diskette, archived at Dansk Datamuseum as
[Bits:30003293](https://datamuseum.dk/wiki/Bits:30003293).

Original description (DA): *"Boot-diskette, som derefter kører en test af en
RC702 Piccolo"* — boot diskette that runs a hardware test of an RC702 Piccolo.

## Status: verified

This image is a **standalone version of the RC703 test PROM**, repackaged as an
autoload-bootable floppy for the RC702. The RC703 carries a dedicated diagnostic
PROM on-board; the RC702 does not, so to run the same suite on an RC702 the
PROM image is wrapped in the standard ROA375 autoload protocol and carried on
a diskette that reuses the **CP/M CONFI disk layout** so the test program boots
up with correctly localised keyboard, display, CRTC and baud configuration.

### What ROA375 does with this disk (verified from `roa375/roa375.asm`)

ROA375's boot flow for a " RC702"-signed disk is:

1. **FLDSK3 → BOOT4 loop**: recalibrate, DSKAUTO-detect Track 0, read Track 0
   side 0 and side 1 via `RDTRK0`. For a mini (5¼") disk the loop reads until
   `CURCYL` advances past 0, covering both sides of Track 0.
2. **BOOT7** checks two signatures in the loaded buffer (`roa375.asm:709–728`,
   see the `ISRC70X` comment block):
   ```
   Disk data layout at 0x0000:
     Old format (ID-COMAL):  [JP vector][" RC700"]...             signature at 0x0002
     New format (CP/M):      [JP vector][config  ][" RC702"]...   signature at 0x0008
   ```
3. On " RC702" match, **BOOT9** executes:
   ```
   BOOT9: LD HL,(FLOPPYDATA) ; JP (HL)   ; jump via word at 0x0000
   ```
   — i.e. ROA375 reads the 16-bit word at disk offset 0x0000 and does an
   indirect jump to that address.

On the test disk:
- word at `0x0000` = `80 02` (little-endian) = **`0x0280`** → entry point.
- bytes `0x0002–0x0007` = `00 00 00 00 00 00` → the 6-byte "confi" slot in the
  sector-1 header, all zero (defaults; this slot is *not* what carries the
  localisation — see below).
- bytes `0x0008–0x000D` = `" RC702"` → signature match, BOOT9 path taken.

The loader at `0x0280` does two LDIRs (see "Boot sequence as observed
statically" below) to lift its image to `0xD480–0xF801` and splice the
character-set table to `0xF680` (the 8275 CRTC DMA window), then brings up
CTC/SIO/DMA using the config block carried in sector 2 of the disk.

### The CONFI block — localisation mechanism

The test disk's Track 0 is **byte-exact** compatible with the standard RC702
CP/M CONFI configuration layout documented in
[`rcbios/sw1711_files/CONFI_ANALYSIS.md`](../rcbios/sw1711_files/CONFI_ANALYSIS.md).
Sectors 1–5 of Track 0 carry the same data CONFI.COM would read/write on a
normal system disk, in the same byte positions, so the test program can
consume the runtime config as if it were CP/M's BIOS INIPARMS.MAC block.

Verification (as produced by re-running the byte-dump script in this folder):

```
Sector 1 (file 0x0000–0x007F): boot + RC702 header
  [0x00] JP vector          : 80 02          -> entry 0x0280
  [0x02] 6-byte confi slot  : 00 00 00 00 00 00   (default — not used by PROM)
  [0x08] Signature          : " RC702"       (ROA375 BOOT9 path match)

Sector 2 (file 0x0080–0x00FF): CONFI hardware config — matches INIPARMS layout
  +00  0x47  MODE0    (CTC Ch0 mode, 0x47 = timer, prescaler 16)    ✓
  +01  0x20  COUNT0   (CTC Ch0 divisor — SIO-A baud = index 4 ≈ 300 scaled)
  +02  0x47  MODE1    (CTC Ch1 mode)                                ✓
  +03  0x20  COUNT1   (CTC Ch1 divisor — SIO-B baud)
  +04  0xD7  MODE2    (CTC Ch2 mode, 0xD7 = counter, display)       ✓
  +05  0x01  COUNT2                                                 ✓
  +06  0xD7  MODE3    (CTC Ch3 mode, 0xD7 = counter, floppy)        ✓
  +07  0x01  COUNT3                                                 ✓
  PSIOA  (+8..+16,  9B, OTIR→port 0x0A):
    18 04 47 03 61 05 20 01 1B
    ^WR0  ^sel-WR4=04  ^WR4=47  ^sel-WR3=03  ^WR3=61
    ^sel-WR5=05  ^WR5=20  ^sel-WR1=01  ^WR1=1B              ← SIO register-select
                                                               bytes at the exact
                                                               INIPARMS positions
  PSIOB  (+17..+27, 11B, OTIR→port 0x0B):
    18 02 10 04 47 03 60 05 20 01 1F
    ^WR0  ^sel-WR2=02  ^WR2-ivec=10  ^sel-WR4=04  ^WR4=47
    ^sel-WR3=03  ^WR3=60  ^sel-WR5=05  ^WR5=20  ^sel-WR1=01  ^WR1=1F
  DMODE0-3 (+28..+31)       : 48 49 4A 4B    (Am9517 DMA mode regs)
  PAR1-4   (+32..+35)       : 4F 98 7A 4D    (8275 CRTC params — 80-col screen)
  FDPROG   (+36..+39)       : 03 03 DF 28    (µPD765 Specify + step/HLT/HUT)
  +40  CBCURSOR        = 0x00
  +41  CBLANGUAGE      = 0x04  → US-ASCII       ← LOCALISATION INDEX
  +42  CURTERMBAUD     = 0x06  → 1200 bps       (SIO-A / terminal)
  +43  CURPRINTBAUD    = 0x06  → 1200 bps       (SIO-B / printer)
  +44  CBXB4Y          = 0x00  → H,V addressing
  +45  CBSTOPTIME (word) = 0x00FA = 250 ticks = 5.0 s motor stop timer

Sector 3 (file 0x0100–0x017F): output conversion table
  Exactly 9 differences from identity — matches CONFI_ANALYSIS.md's
  "US-ASCII: Out=9 diffs" entry:
    [0x40]=0x05   [0x5B]=0x0B  [0x5C]=0x0C  [0x5D]=0x0D  [0x60]=0x16
    [0x7B]=0x1B   [0x7C]=0x1C  [0x7D]=0x1D  [0x7E]=0x0F
  These remap @ [ \ ] ` { | } ~ onto the RC700 character ROM's national-character
  slots (0x05, 0x0B..0x0D, 0x0F, 0x16, 0x1B..0x1D) — i.e. the test disk carries
  the US-ASCII entry of the same 7-language conversion-table set that CONFI.COM
  manages on a CP/M system disk.

Sector 4 (file 0x0180–0x01FF): input  conversion table   (not re-verified here)
Sector 5 (file 0x0200–0x027F): semigraphic conversion table (not re-verified here)
```

Every field in sector 2 hits its expected constant at its expected INIPARMS
offset, every WR-select byte in the SIO init blocks is at the correct position,
and sector 3's diff count and diff positions match the published US-ASCII
conversion entry exactly. There is no ambiguity: **this is the CP/M CONFI
layout, reused verbatim to localise a non-CP/M test program.**

### Why carry a CONFI block on a non-CP/M disk

The test program needs the same runtime configuration as any RC702 CP/M system
(baud, CRTC, cursor style, character-set conversion table) so its menu, its
keyboard input and its status display all look right for the machine's
localisation. Rather than hard-code those values it reuses CONFI's format, so
one can run CONFI.COM on a genuine system disk, save the chosen configuration,
and transplant the resulting 512-byte Track 0 sectors 2–5 onto the test disk
to re-localise it — without touching any test code.

### Other supporting evidence

- Only **~38 KB of actual payload** (`0x0000–0x95FF`); the remaining ~290 KB of
  the 321 KB disk image is plain `0xE5` "formatted but unused" fill — i.e. this
  is a PROM-sized program dropped onto an otherwise empty diskette, not a CP/M
  disk with a rich file system.
- **No CCP + BDOS** in Track 1, **no CP/M directory** at Track 2 (see
  "Not a CP/M diskette" below).
- The embedded menu banner is `RC700 TESTSYSTEM ver 1.2` and the test suite
  list matches the RC703 built-in diagnostics (MEM refresh, DMA, CTC, FDC, FDD,
  SIO, PIO, WDC + WDD — including `RC763/RC763B` Winchester support).
- The strings `**NO SYSTEM FILES**`, `**NO KATALOG**`, `SYSM SYSC` visible in
  `strings(1)` output are baked-in error text lifted from the standard autoload
  PROM, not live CP/M directory contents — this loader speaks the autoload
  PROM's protocol, it is not CP/M.

## Files in this folder

| File | Purpose |
|---|---|
| `RC702_TEST_v1.2.bin` | Original disk image, 328,704 B, as downloaded from datamuseum.dk |
| `RC702_TEST_v1.2.imd` | IMD conversion of the raw image, loadable by MAME `rc702mini -flop1`. Produced by `python3 ../rcbios/bin2imd.py RC702_TEST_v1.2.bin RC702_TEST_v1.2.imd`. |
| `region1_track0_side0.bin` | Track 0 Side 0 (16 × 128 B FM) — 2,048 B |
| `region2_track0_side1.bin` | Track 0 Side 1 (16 × 256 B MFM) — 4,096 B |
| `region3_payload_mfm.bin` | Tracks 1–35 both sides (9 × 512 B MFM), trimmed to last non-`0xE5` byte — 32,256 B |
| `region{1,2,3}_*_asload.asm` | Disassembly with origin = file offset. Easiest to cross-reference with `xxd` on the raw disk image. |
| `region{1,2}_*_runtime.asm` | Disassembly with origin shifted by `+0xD480`. **Caveat:** this represents the *boot-time snapshot* in high memory; at runtime, only the high-memory copy stays in this form — the low-memory copy gets rewritten as the program runs. See "Runtime behaviour on MAME rc702mini" below. |
| `dispatcher_ram_0330_disasm.asm` | `z80dasm` of the rewritten low-RAM region containing the test program's menu dispatcher (idle `HALT ; JR -3` at `0x0341` + ISR body + menu command letters). |
| `mame_dump_on_halt.lua` | MAME autoboot Lua hook that polls for `HALT` at `0x0341` and dumps low + high RAM to `/tmp/` when the test program reaches its idle state, then exits. |
| `mame_run_f0200_loading.png` | MAME screenshot at frame 200 — "Loading test program" (early boot) |
| `mame_run_f0500_memtest.png` | MAME screenshot at frame 500 — memory refresh test pattern tiled on screen |
| `mame_run_f1000_menu_running.png` | MAME screenshot at frame 1000 — main banner, `test no : 01 state: running` |
| `mame_run_final_halted.png` | MAME screenshot at the final `state: halted` point, showing all 6 auto-run test results |
| `mame_run_final_ram_0000.bin` | MAME RAM snapshot at the halted state: `0x0000-0x26FF` (9,984 B) |
| `mame_run_final_ram_d480.bin` | MAME RAM snapshot at the halted state: `0xD480-0xF8FF` (9,984 B) |
| `RCSL-44-RT-2061_RC701_RC702_Testsystem_v1.1_ocr.pdf` | Official manual (RCSL 44-RT-2061, Sep 1983), searchable OCR PDF, 2.4 MB |
| `RCSL-44-RT-2061_RC701_RC702_Testsystem_v1.1.txt` | Plain-text sidecar of the manual (1,981 lines, eng+dan OCR) |
| `Dockerfile.ocrmypdf-dan` | Reproducible OCR image build recipe: `docker build -f Dockerfile.ocrmypdf-dan -t ocrmypdf-dan:latest .` |

The full disassembly of region 3 at file-offset origin is in
`region3_payload_mfm_asload.asm` — it covers the overlay sectors that the
test program loads from Track 1 Side 0 at runtime (sector 1 → RAM
`0x0000-0x01FF`, sector 3 → RAM `0x0200-0x03FF`) as well as the per-test
bodies that the menu dispatcher jumps into. Cross-reference this file with
the manual sections listed in `MANUAL_ANALYSIS.md` to walk any specific
test's implementation.

## Disk layout

Geometry as recorded by datamuseum.dk (three-region mixed-density):

```
1c × 1h × 16s × 128b   →  Track 0 Side 0     2,048 B   FM   (autoload boot area)
1c × 1h × 16s × 256b   →  Track 0 Side 1     4,096 B   MFM  (transitional)
35c × 2h × 9s × 512b   →  Tracks 1–35 both   322,560 B MFM  (main data area)
                                              -------
                                             328,704 B exactly
```

Real payload ends at file offset `0x9600` (38,400 B); everything from `0x9600`
to EOF is `0xE5` fill.

## Boot sequence as observed statically

The first 128 B sector carries the RC702 autoload header:
```
80 02 00 00 00 00 00 00   20 52 43 37 30 32 00 00
\____/ \_________________/  \______ " RC702" _____/
  ^          ^
  |          6-byte confi slot (all zero here, ROA375 does not read it)
  JP vector — word at offset 0x0000, little-endian = 0x0280, is the
  target of BOOT9's "LD HL,(FLOPPYDATA) ; JP (HL)".
```

The rest of sector 1 (`0x000E–0x007F`) is padding. Sectors 2–5 of track 0
(`0x0080–0x027F`) carry the CP/M **CONFI block** — 128 B hardware config
(sector 2) + 3×128 B conversion tables (output/input/semigraphic, sectors 3–5).
See the verification dump below.

The first executable byte of the test program is at **`0x0280`**, i.e. the very
start of sector 6 of track 0 side 0:

```
0280  F3                DI
0281  21 00 00          LD HL,0000h
0284  11 80 D4          LD DE,D480h
0287  01 81 23          LD BC,2381h
028A  ED B0             LDIR               ; relocate 9,089 B:  0x0000-0x2381 → 0xD480-0xF801
028C  21 80 D5          LD HL,D580h        ; post-LDIR that's file 0x0100 (charmap)
028F  11 80 F6          LD DE,F680h        ; CRTC DMA scan window
0292  01 80 01          LD BC,0180h
0295  ED B0             LDIR               ; copy 384 B charmap to 0xF680
0297  31 80 00          LD SP,0080h
029A  3A 25 EC          LD A,(EC25h)       ; IVT high byte, post-relocation
029D  ED 47             LD I,A
029F  ED 5E             IM 2
02A1  3E 20 D3 12       LD A,20h ; OUT (12h),A   ; CRTC reset
02A5  3E 22 D3 13       LD A,22h ; OUT (13h),A
02A9  3E 4F D3 12       LD A,4Fh ; OUT (12h),A
02AD  3E 0F D3 13       LD A,0Fh ; OUT (13h),A   ; CRTC parameters
...                                             ; CTC / SIO / DMA / PIO bring-up
```

So this is a **relocating loader**: ROA375's BOOT9 path does `LD HL,(0000h) ; JP (HL)`
which transfers control to `0x0280`, the phase-2 code then lifts itself and
its tables up to `0xD480–0xF801`, splices the character-set conversion table
to `0xF680` (the Intel 8275 CRTC's glyph DMA window), sets SP to `0x0080`,
arms IM 2 with the IVT at `0xEC00` (runtime), and brings up CRTC/CTC/SIO/DMA
using the config data carried in the CONFI block.

### Post-relocation address map

```
Disk file offset  Post-LDIR runtime  Source
0x0000–0x007F  →  0xD480–0xD4FF      sector 1  — JP vec + " RC702" header
0x0080–0x00FF  →  0xD500–0xD57F      sector 2  — CONFI hw config (INIPARMS-compatible)
0x0100–0x017F  →  0xD580–0xD5FF      sector 3  — output conv table (US-ASCII, 9 diffs)
0x0180–0x01FF  →  0xD600–0xD67F      sector 4  — input conv table
0x0200–0x027F  →  0xD680–0xD6FF      sector 5  — semigraphic conv table
0x0280–0x07FF  →  0xD700–0xDC7F      sectors 6–16 — phase-2 loader + test code
0x0800–0x17FF  →  0xDC80–0xEC7F      Track 0 Side 1 — more test code/data
0x1800–0x237F  →  0xEC80–0xF7FF      LDIR window tail — uninitialised on mini
                                      boot (see "Open puzzle" below)
0x2380–0x95FF  →  *not in LDIR*      overlays loaded from disk at runtime
```

The second LDIR (`0x028C`) copies 0x0180 bytes (384 B) from runtime `0xD580`
(= file sector 3, the **output conversion table**) to `0xF680`. That's the
memory location where the BIOS also lives the output conversion table on a
normal CP/M system, because the 8275 CRTC's character-generator DMA scans
glyph-index bytes written around `0xF680`. So when the test program prints
e.g. `@` (0x40), it goes through the conversion table at 0xF680 and comes out
as glyph 0x05 — whatever the RC700 character ROM has at position 5 — applying
the US-ASCII localisation you can also set via CONFI.COM on a system disk.

### LDIR length vs. ROA375 load count — resolved by MAME run

The LDIR at `0x028A` copies **0x2381 = 9,089 bytes** from `0x0000`, which is
larger than a mini 5¼" Track 0 can deliver (6,144 B). I set a MAME
breakpoint on the `rc702mini` target to capture what ROA375 actually put in
that range.

**Setup.** MAME debug script (`/tmp/rc702_test.dbg`):

```
bpset 0x028a,1,{save /tmp/rc702_test_pre_source.bin,0,0x2381; go}
go
```

Run:

```
python3 ../rcbios/bin2imd.py RC702_TEST_v1.2.bin RC702_TEST_v1.2.imd
regnecentralend rc702mini -rompath ~/git/mame/roms \
   -flop1 RC702_TEST_v1.2.imd -debug -debugscript /tmp/rc702_test.dbg \
   -skip_gameinfo -window -nomaximize
```

(`bin2imd.py` already knows the RC702 mini multi-density layout.)

**Observation.** At the moment the breakpoint fires (`PC = 0x028A`, about
to execute `LDIR`) the 9,089-byte source window looks like this:

| RAM range | Size | State at PC=0x028A | vs. disk file |
|---|---|---|---|
| `0x0000–0x07FF` | 2,048 B | fully populated | 2,048 / 2,048 bytes match |
| `0x0800–0x17FF` | 4,096 B | fully populated | 4,096 / 4,096 bytes match |
| `0x1800–0x2380` | 2,945 B | **all zeros** | 100 / 2,945 incidental |

So on a mini disk ROA375 reads **6,144 bytes** — all 16 × 128 B FM sectors
of T0S0 plus **all** 16 × 256 B MFM sectors of T0S1 — and the RAM tail
`0x1800–0x2380` stays at its power-on zero value. My static trace of the
`CALCTB` `L=10` mini-head-1 override was wrong: the real hardware reads all
16 head-1 sectors, not 10. The override must apply under different
conditions than I inferred from the assembly.

**Why the LDIR was sized for 9,089 B anyway** — adapted-from-maxi:

| Geometry | T0 side 0 | T0 side 1 | T0 total | Covers 0x2381? |
|---|---|---|---|---|
| Maxi 8" (26 sectors) | 26 × 128 = 3,328 B | 26 × 256 = 6,656 B | 9,984 B | **yes, 895 B spare** |
| Mini 5¼" (16 sectors) | 16 × 128 = 2,048 B | 16 × 256 = 4,096 B | 6,144 B | **no, 2,945 B short** |

The LDIR length `0x2381` fits cleanly inside a **maxi** Track 0 with ~900
bytes of headroom, but overshoots a mini Track 0 by the exact 2,945 bytes
that show up zero-filled in the RAM dump. Decisive: the phase-2 relocating
loader at `0x0280` was originally authored for an 8" maxi system where
Track 0 alone holds the full 9,089 B program image, and the mini port
reuses the same loader verbatim. On mini, the LDIR tail copies 2,945 zero
bytes into the high-memory destination, which the test program tolerates
because that region is either treated as zero-initialised working RAM or
overwritten by subsequent reads — see the second LDIR (below) which
clobbers `0xF680–0xF7FF` with the character-set conversion table.

### Runtime behaviour on MAME `rc702mini`

The test disk **boots successfully** and runs the suite to completion on
the `rc702mini` target. MAME warns about a ROA375 PROM checksum mismatch
against its bundled ROM set, which is expected because this repo ships a
modified autoload PROM:

```
roa375.ic66 WRONG CHECKSUMS:
    EXPECTED: CRC(6dbd088b) SHA1(bd4e84f3237d991bb97e15bac9e1fc4ee59eafc8)
       FOUND: CRC(3a2d4fc3) SHA1(25138240307898b849780843d9f079edf5013546)
```

After the tests finish, the program settles into a **`HALT ; JR -3`** idle
loop at **`0x0341`** — observed live in the MAME debugger, and confirmed
by a full RAM dump captured through this autoboot Lua hook:

```
-- /tmp/rc702_dump_running.lua
emu.register_periodic(function()
    local mem = manager.machine.devices[":maincpu"].spaces["program"]
    if mem:read_u8(0x0341) == 0x76 then        -- HALT opcode installed?
        local dbg = manager.machine.debugger
        dbg:command("save /tmp/rc702_running_0000.bin,0,0x2700")
        dbg:command("save /tmp/rc702_running_D480.bin,0xD480,0x2700")
        manager.machine:schedule_exit()
    end
end)
```

```
regnecentralend rc702mini -rompath ~/git/mame/roms \
   -flop1 RC702_TEST_v1.2.imd -debug \
   -autoboot_script /tmp/rc702_dump_running.lua \
   -skip_gameinfo -window -nomaximize
```

#### The two copies are NOT byte-identical after boot

Diffing the running RAM against the disk file, and against the relocated
copy at `0xD480+`, gives a very different picture from what my static
disassembly suggested:

| RAM range | State at halt | vs. disk file | Interpretation |
|---|---|---|---|
| `0x0000–0x03FF` | fully rewritten | all 1,024 B differ | test program's **main dispatcher + menu code**, installed at runtime |
| `0x0400–0x17FF` | unchanged | matches disk byte-for-byte | original test code / data from the boot load |
| `0x1800–0x267F` | still zero | ~all bytes differ | zero tail from the LDIR-past-end; never touched again |
| `0xD480–0xD87F` | fully rewritten | matches the disk file's `0x0000-0x03FF`, the **boot-time** snapshot | pristine copy of the loader's original init code, frozen at `LDIR` time |
| `0xD880+` | matches disk | — | rest of the high-memory copy, untouched |

Concretely, at `PC = 0x0341`:

```
RAM  0x0341..0x0348 = 76 18 FD  FB ED 4D  F5 C5  (HALT+JR loop + ISR tail + saves)
DISK 0x0341..0x0348 = DB 14 E6 80 CA F2 D7 21   (the ORIGINAL IN A,(14h) init code)
RAM  0xD7C1..0xD7C8 = DB 14 E6 80 CA F2 D7 21   (boot-time snapshot — unmodified!)
```

So my earlier disassembly of `0x032E-0x0351` — the `IN A,(14h) ; AND 80h ;
JP Z,D7F2h ; …` sequence — was reading the **disk file** bytes, which are
the program's initial appearance at boot. After the test suite runs, that
region of low memory has been completely rewritten by the program; the
only place those original bytes still exist is in the high-memory snapshot
that the phase-2 LDIR took at boot.

That also overturns one of my earlier claims. I said "execution ping-pongs
between the low and high copies, and the two copies are byte-identical so
it doesn't matter which you're in". That's wrong. The LDIR at boot made a
one-shot snapshot; the low-memory copy then diverges as the program
rewrites it. The `JP D7F2h` / `JP D7D3h` branches in the original init
code (which I saw only on disk) jump into the *frozen pristine* copy in
high memory, while the low-memory copy underneath is continuously modified
at runtime. The high-memory copy is effectively read-only boot-time data,
**not** a live execution target.

#### What the rewritten low-RAM dispatcher actually contains

Disassembling the live RAM dump at `0x0330-0x0388` (z80dasm on the saved
file, origin `0x0330`) shows this is the test program's **interactive menu
dispatcher**:

```
0330  ...            ; tail of a preceding routine
0334  LD A,(FFFFh)   ; read system flags at the top of RAM
0337  BIT 7,A
0339  RET NZ
033A  DI             ; === main idle entry ===
033B  LD HL,02A2h    ; pointer to the menu prompt string
033E  CALL 031Fh     ; print helper
0341  HALT           ; <<< wait for interrupt (3 bytes: 76 18 FD)
0342  JR 0341h       ; <<<
0344  EI ; RETI      ; tail used by the ISR body via CALL 0345h below
0347  PUSH AF/BC/DE/HL/IY/IX     ; === ISR body (keyboard dispatch) ===
034F  LD IX,(FFFCh) ; PUSH IX    ; save current state vector
0355  LD A,(FFFFh) ; PUSH AF     ; save system flags
0359  SET 5,A ; LD (FFFFh),A     ; mark "ISR active" bit
035E  LD HL,02B6h ; LD IX,F0ABh  ; prompt string + 8275 screen position
0365  CALL 1161h                 ; emit string
0368  IN A,(10h)                 ; PIO-A = keyboard port
036A  CP 1Bh ; JR NZ,03B5h       ; ESC?
036E  LD HL,0292h ; CALL 031Fh   ; confirm prompt
0374  IN A,(10h) ; CP 0Dh        ; require <Return>
0378  JR NZ,0368h
037A  LD IX,F0CFh ; LD B,2Ah     ; write '*' to the display buffer
0380  LD (IX+0),B
0383  CALL 0345h                 ; tail-return through the EI/RETI stub
0386  JP 0407h                   ; enter main test-menu handler
0389  "HRLGSPFEDCBA98765432..."  ; DATA: menu command letters
```

So the `HALT ; JR 0341h` is the **idle state of the test program's
keyboard-driven top-level menu**. When the emulator is parked there, it
means: the test suite has been initialised, ROA375 handed off cleanly,
the menu has been printed to the screen, and the CPU is now waiting for a
keystroke-triggered interrupt to dispatch the next command (`H R L G S P`
or a hex digit). The "test ran to completion" interpretation is
essentially "the test program is healthy and sitting at its prompt".

#### How the dispatcher gets into low RAM: FDC overlay reads

I originally tried to find the CPU instruction that installs the `HALT`
byte at `0x0341` by setting a write-tap via `install_write_tap`. The tap
never fired, which was a clue: the write isn't done by the CPU at all,
it's **DMA** from the µPD765 FDC straight into RAM, and MAME's Lua
memory-tap API hooks only the CPU side of the bus. So the search had to
move off the CPU and onto the disk.

Fingerprinting the 88-byte dispatcher from the RAM dump against the raw
disk image produces a single 88/88 byte match at **disk offset `0x1D30`**.
That address sits inside Track 1 Side 0 sector 3 (`0x1C00–0x1DFF` in the
file layout, 512 B MFM). Expanding the match to a full 512-byte window
gives a perfect match:

| RAM range | Size | Disk origin (file offset) | T1S0 sector |
|---|---|---|---|
| `0x0000–0x01FF` | 512 B | `0x1800–0x19FF` | **sector 1** (full 512 B) |
| `0x0200–0x03FF` | 512 B | `0x1C00–0x1DFF` | **sector 3** (full 512 B) |
| `0x0400–0x17FF` | 5,120 B | `0x0400–0x17FF` | original Track 0 load (untouched) |
| `0x1800–0x267F` | 3,712 B | *none* | zero tail of the phase-2 LDIR |

Both overlays are byte-exact 512/512 B matches, which means the phase-2
loader executes two **FDC+DMA reads of T1S0 sectors 1 and 3** (skipping
sector 2 of that track for this pair) with DMA destination addresses
set to `0x0000` and `0x0200` respectively. The second of those overlays
places disk byte `0x1D30` at RAM address `0x0330`, and disk byte `0x1D41`
— which is the literal `76` opcode of `HALT` — at RAM `0x0341`. There is
no CPU store instruction involved; the `HALT` is delivered as disk data
through the DMA controller.

Concretely, disk `0x1800–0x19FF` holds a **hardware re-initialisation
routine**:

```
1800  AF                XOR A
1801  32 FF FF          LD (FFFFh),A              ; clear system flags
1804  F3                DI
1805  D3 01             OUT (01h),A               ; PROM off (sanity)
1807  ED 7B FF FF       LD SP,(FFFFh)             ; SP = 0 (top of RAM)
180B  D3 FD             OUT (FDh),A
180D  3E 18 D3 0A D3 0B ; CTC Ch0/Ch1 reset
1813  3E 03 D3 0C D3 0D D3 0E D3 0F   ; CTC Ch0-3 time constants
181C  ED 5E             IM 2
...
```

— i.e. the test program brings up CTC, SIO, 8275 CRTC, DMA, PIO etc. a
second time from this overlay after `ROA375 + phase-2 loader` have
already done a first pass. The second pass uses values it reads out of
the CONFI block in high memory, which is why the CONFI verification in
this document matters: those bytes are consumed live.

Disk `0x1C00–0x1DFF` contains the **test program's main dispatcher**,
with the idle `HALT ; JR -3` at internal offset `0x130` (= byte 304 of
sector 3), followed by the keyboard ISR body and the menu command-letter
data (`"HRLGSPFEDCBA98…"`). That's how `dispatcher_ram_0330_disasm.asm`
in this folder came to contain the 88-byte window starting at `0x0330`.

#### The zero tail in the LDIR is safe because low RAM is about to be overwritten anyway

With the overlay picture above, the "the LDIR was sized for a maxi Track
0 and overshoots a mini Track 0 by 2,945 bytes" story becomes even more
benign. The phase-2 LDIR's zero tail ends up in the RAM range
`0xEC80–0xF7FF` (the high-memory copy). But **low RAM `0x0000–0x03FF` is
wiped and replaced by the FDC overlays** immediately afterwards anyway,
so even the low copy of that range loses its boot-time contents. Whether
the LDIR copied ROM-loader bytes or zeros into that high-memory tail
doesn't matter, because the test program's execution has already moved
on to code that lives outside the tail.

Side note on the memory layout the test program chose: it **reclaims low
RAM `0x0000–0x03FF` as its primary workspace**, because those bytes held
only the boot-time header, the CONFI block, and the conversion-table
sectors (sectors 1–5 of Track 0), which are no longer needed once the
program has read them, copied what it wanted to high RAM and the CRTC
glyph window, and latched the configuration into its hardware-setup
registers. Efficient reuse — there's no DRAM refresh penalty on a Z80,
and the program gets 1 KB of contiguous dispatcher+ISR workspace right
at the start of address space.

### CONFI conversion tables — US-ASCII verified byte-exact

Comparing Track 0 sectors 3–5 of the test disk against the US-ASCII
entry in `rcbios/sw1711_files/conversion_tables.bin` (extracted from
CONFI.COM by `extract_conv_tables.py`):

| Sector | Purpose | vs. CONFI US-ASCII | Result |
|---|---|---|---|
| 3 | output conversion (`0x0100–0x017F`) | 0 byte diffs | **identical** |
| 4 | input conversion (`0x0180–0x01FF`) | 0 byte diffs | **identical** |
| 5 | semigraphic mapping (`0x0200–0x027F`) | 1 byte diff at `[0x45]`: test `0xC5` vs CONFI `0x05` | essentially identical |

The single-byte difference in the semigraphic table is a bit-7 flip at
offset `0x45` (`0x05 | 0x80 = 0xC5`). That bit is the "video-attribute"
flag for the semigraphic region of the character ROM, and may be set
deliberately on the test disk for a screen-attribute reason — or it may
simply be a different CONFI.COM revision. Either way the 383/384 match
across the three tables is decisive: **the test disk's localisation
tables are the US-ASCII entry from CONFI.COM**, byte-exact modulo that
one video-attribute bit.

## Not a CP/M diskette

I verified directly: if this were a stock CP/M diskette, Track 1 would hold
CCP + BDOS (starting with a `C3 xx xx` cold-boot jump) and Track 2 would begin
with the 32-byte directory records. What we see instead:

- **Track 1 Side 0 (file `0x1800`)** — raw Z80 init code:
  ```
  AF 32 FF FF  XOR A ; LD (FFFFh),A
  F3           DI
  D3 01        OUT (01h),A          ; PROM map off
  ED 7B FF FF  LD SP,(FFFFh)
  D3 FD        OUT (FDh),A
  3E 18 D3 0A  LD A,18h ; OUT (0Ah),A
  D3 0B 3E 03  ...                  ; CTC channels 0/1 vector + channels 0-3 cmd
  D3 0C D3 0D D3 0E D3 0F
  ED 5E        IM 2
  ```
  That's a continuation of the test program's hardware bring-up path, not CCP.
- **Track 2 Side 0 (file `0x3C00`)** — more executable code (`CD 2A 1B`,
  `C3 7C 1D`, `DD 21 B8 F1` …). No 32-byte directory entries, no filename
  patterns, no erased-slot `0xE5` pattern.

So the disk is a bare-metal linear image, not a CP/M filesystem.

## Test-suite contents (from embedded strings)

```
MEM refresh test
DMA-test ch 0 - 1
CTC-test
FDC_test                — status register, TC timeout 200 ms, data compare
FDD-test / FDD RELIABILITY TEST
  drive 0/1, single/double density, track range, mini/maxi/quad,
  single/double side, steprate 01-16, retries 0-9, preformat, format
  Errors enumerated: main status reg, not ready, write protect, timeout,
  seek error, command abort, door open, recalibrate error, no track 0,
  missing address mark data/id, bad cylinder, wrong cylinder,
  cannot find sector, CRC fault id/data, overrun, access beyond last sector
SIO-test                — timeout, bps, CTS/DCD, CI/DSR, parity, rx overrun
PIO_TEST                — port A interrupt, channel B interrupt
WDC_test                — restore, track 0, id not found, CRC id/data,
                          data mark, aborted read/write, bad block, format
WDD RELIABILITY TEST    — RC763/RC763B Winchester, head/track range,
                          CRC/ECC check, format, soft/hard error counts
```

Interactive keyboard menu:

```
RC700 TESTSYSTEM          ver  1.2
test no :  , state: running/stopped/looping/halted
keyboard : type (H,R,L,G,S,P,<esc> or (0-F))
```

## How to re-disassemble

```bash
# As-loaded (origin = file offset)
z80dasm -a -l -t -g 0x0000 -o region1_track0_side0_asload.asm region1_track0_side0.bin
z80dasm -a -l -t -g 0x0800 -o region2_track0_side1_asload.asm region2_track0_side1.bin
z80dasm -a -l -t -g 0x1800 -o region3_payload_mfm_asload.asm  region3_payload_mfm.bin

# Runtime (post-relocation to 0xD480) — these disassemblies match the
# frozen boot-time snapshot the phase-2 LDIR copies to 0xD480+; the live
# low-memory copy diverges at runtime as the test program rewrites it.
z80dasm -a -l -t -g 0xD480 -o region1_track0_side0_runtime.asm region1_track0_side0.bin
z80dasm -a -l -t -g 0xDC80 -o region2_track0_side1_runtime.asm region2_track0_side1.bin

# Live runtime dispatcher (from the MAME RAM snapshot, not from the disk file)
dd if=mame_run_final_ram_0000.bin of=/tmp/dispatcher_0330.bin bs=1 skip=$((0x330)) count=$((0x100))
z80dasm -a -l -t -g 0x0330 -o dispatcher_ram_0330_disasm.asm /tmp/dispatcher_0330.bin
```

## TODOs

- ~~Dump memory `0x0000–0x2381` just before the phase-2 LDIR to resolve
  the LDIR-length-vs-load-count puzzle.~~ **Done.** See "LDIR length vs.
  ROA375 load count — resolved by MAME run" above. `rc702mini` target +
  `bpset 0x028a` + `save /tmp/rc702_test_pre_source.bin,0,0x2381`. Result:
  0x1800-0x2380 is zero-filled — test program was written for maxi.
- **Build MAME emulation of the `CBL936` and `CBL998` test-harness
  loopbacks** so all six auto-run tests pass in a bare `rc702mini` run.
  Tracked as ravn/rc700-gensmedet#9.
  See `MANUAL_ANALYSIS.md` §9 and §10 for the physical wiring.
    - **CBL936** (parallel loopback): plug J3 at J1003 (PARALLEL OUT),
      plug J4 at J1004 (KEYBOARD). The PIO test writes `0xE5` to the
      parallel-out PIO and expects to read it back on the keyboard
      input PIO. In MAME this needs a thin "loopback device" that
      shorts the parallel-out port's data into the PIO-A data latch
      whenever the cable is considered installed. Could be gated on a
      command-line flag like `-pio_loopback 1` or wired as a proper
      MAME slot option on the rc702mini driver.
    - **CBL998** (SIO line loopback, per manual fig 2):
      `RTS→CTS`, `DTR→DSR`, `DTR→DCD`, `DATA_OUT→DATA_IN`, on each of
      the two SIO LINE connectors. The SIO test asserts DTR/RTS and
      expects CTS/DCD to follow. In MAME this should already be
      possible via `-rs232a null_modem` variants or by wiring a
      dedicated "testplug" rs232 slot option that just ties the
      control lines back.
  Once both are in place, a `make rc702mini_selftest` target could
  run `regnecentralend rc702mini -flop1 RC702_TEST_v1.2.imd` with the
  loopbacks enabled and expect all six tests to report OK — a real
  end-to-end hardware-conformance test for the whole rc702mini
  driver using only assets already in this folder.

- **Create a real 8" boot diskette for the physical machine.** Tracked
  as ravn/rc700-gensmedet#10. The test
  program was authored for maxi geometry (Track 0 both sides fits the
  9,089-byte phase-2 LDIR), so a native maxi diskette would be the
  "natural" boot medium — no zero tail, no mini-vs-maxi translation. This
  needs a maxi-format IMD (26 sectors × 128 B FM side 0 + 26 × 256 B MFM
  side 1) built from the test program's payload, plus a writer that can
  push it onto physical 8" media (kryoflux / greaseweazle / similar).
- **Interactive dispatch requires `command + Return`.** The menu prompt
  `"type (H,R,L,G,S,P,<esc> or (0-F))"` doesn't say so, but the ISR at
  `0x0347` reads two keystrokes through PIO-A: first the command key,
  then `Return` (`0x0D`). Without the Return the ISR stays in its
  inner read loop, updating the system-state byte at `0xFFFF` in
  place but never reaching `JP 0407h` to let the main loop act on it.
  See `RUNTIME_ANALYSIS.md` §11 for the full key → flag-bit table.
  **Verified end-to-end on MAME `rc702mini`:** posting `"R\r"` via
  `manager.machine.natkeyboard:post()` from a Lua autoboot hook when
  the screen shows `state: halted` does flip the state line and
  restart the auto-run test suite — the test dispatcher re-runs
  tests 01-06 and halts again. So MAME keyboard → PIO-A routing
  works; the "nothing happens" observation was the missing Return.
- **Automate a full MAME test-suite run** to catch behavioural regressions.
  The goals:
    1. Boot `RC702_TEST_v1.2.imd` on the MAME `rc702mini` target
       (5¼" DD drives, 16×128 FM + 16×256 MFM track 0).
    2. Drive the interactive keyboard menu (`H R L G S P <0-F>`) from a
       Lua autoboot script so each test runs end-to-end unattended.
    3. Capture the display output (screenshot or serial trace) and diff
       it against a golden log so future PROM/BIOS changes don't silently
       regress the test-PROM compatibility.
  The existing `run_mame.sh` / `mame_autoboot_dir.lua` /
  `set_38400.lua` helpers under `rcbios/` are a starting point.
- ~~Work out what drives the loop at `0x0341`.~~ **Done.** `0x0341` is
  part of a dispatcher loaded from **disk T1S0 sector 3** via FDC+DMA as
  an overlay into RAM `0x0200`. The code is `DI ; LD HL,menu_prompt ;
  CALL print ; HALT ; JR back-to-HALT` — an idle wait between keyboard
  interrupts. See "How the dispatcher gets into low RAM: FDC overlay
  reads" above.
- ~~Verify sectors 4 and 5 (input + semigraphic conversion tables)
  byte-exact against the US-ASCII entries in CONFI_ANALYSIS.md.~~
  **Done.** Sectors 3 and 4 are 0-diff matches; sector 5 has exactly one
  bit-7 flip at offset 0x45. See "CONFI conversion tables — US-ASCII
  verified byte-exact" above.
- Label the disassemblies: name I/O ports, interrupt vectors, CONFI-block
  offsets, and subroutine entry points so the `.asm` files are readable
  without flipping back to the hex dump.
- Split code vs data regions in the disassembly with a z80dasm block-def
  file so the header, charmap, message strings, and jump tables stop
  disassembling as bogus opcodes.
- Verify sectors 4 and 5 of Track 0 (input + semigraphic conversion tables)
  byte-exact against the US-ASCII entries in `CONFI_ANALYSIS.md` to close
  out the CONFI-layout confirmation.

## Caveats

- z80dasm is a linear sweep disassembler. Data interleaved with code (the
  header at `0x00–0x0F`, the charmap at `0x100–0x27F`, jump tables, message
  strings) disassembles as nonsense instructions. Read these regions as bytes,
  not opcodes.
- z80dasm's "self modifying code detected" warning is triggered by the LDIR at
  `0x028A` overwriting its own runtime region — normal for a relocating loader.
- No attempt has been made to label I/O ports, interrupt vectors, or name
  subroutines. That's a follow-up pass; what's here is strictly a best-effort
  linear disassembly with file-offset and runtime-address views.
