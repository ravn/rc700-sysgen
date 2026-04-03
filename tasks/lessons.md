# Lessons Learned

## 2026-02-28: Verify datasheet quotes against primary source

**Context**: MAME PR #15031 (Read Track ST1_ND fix) cited "the sector number is
not compared" as a µPD765A datasheet quote. The MAME maintainer (cracyc) asked
which datasheet says this and pointed to the actual NEC datasheet which says the
opposite — the FDC *does* compare IDs during Read Track.

**What happened**: The quote came from a secondary FDC programming reference
(isdaman.com), not from the NEC µPD765A datasheet. The NEC datasheet's command
description says the FDC compares IDs and sets ND "if there is no comparison."
However, the ST1 ND *bit definition* (a different page of the same datasheet)
says ND for Read Track means "if the starting sector cannot be found" — a
narrower condition.

**Lesson**: When citing hardware datasheets in upstream PRs:
1. Always verify exact wording against the primary source document
2. Don't conflate secondary reference material with official datasheets
3. Note when the datasheet is internally inconsistent (command description vs
   status register definition)
4. The correction was posted promptly and transparently, which is the right
   approach — acknowledge the error, present the correct evidence

**Files**: `rcbios/MAME_UPD765_READ_TRACK_ANALYSIS.md` has the full analysis.

## 2026-02-28: Always clearly identify AI authorship in PR comments

**Context**: When posting review replies on MAME PRs #15031 and #15032, the
comments must clearly state they were written by Claude Code on behalf of the
user, not claim to be the user. Use a closing line like
"(Analysis by Claude Code on behalf of Thorbjørn Ravn Andersen)".

**Lesson**: Never claim to be the user. Always state clearly what was written
and by whom. This is both honest and required by the user.

## 2026-03-07: zmac ORG inside .PHASE block causes Phase/Dephase error

**Context**: Adding an `ORG 0FFD0H` DS work-area block at the end of `src/BIOS.MAC`
triggered "Phase/Dephase error" on the ORG line.

**Root cause**: `INIPARMS.MAC` opens `.PHASE START` with no matching `.DEPHASE`.
The entire BIOS assembly after that include runs inside a phase block. zmac
rejects `ORG` inside a phase block.

**Fix**: Insert `.DEPHASE` immediately before the `ORG`. Since the DS block is at
the very end (after all code), re-entering `.PHASE` is not needed.

**Lesson**: Any time you add an `ORG` after the INIPARMS include in `src/BIOS.MAC`,
you must precede it with `.DEPHASE`. The existing alignment `DS (BIOS-$)` works
because DS does not trigger the phase check — only ORG does.

## 2026-03-07: Check for code labels before adding DS-layout labels with same name

**Context**: Adding a DS layout block in `src-rc702e/BIOS.MAC` with `MOTORTIMER:`
as a position label caused a "Mult. def. error" because `MOTORTIMER:` is also a
code function label in `FLOPPY.MAC` (REL201 FLOPPY ISR routine at ~0xE608).

**Lesson**: Before stacking a new label in a DS/work-area layout block, grep all
module files for that name to confirm it is not already a code label. When a symbol
has different roles across variants (code label in REL201, RAM variable in REL220),
use a conditional EQU alias in the variant-specific section rather than an
unconditional DS label.

## 2026-03-08: Always read AGENT.md and MEMORY.md at session start

**Context**: Started a session without reading the mandatory files. Used relative
paths for zmac which failed, then had to retry with absolute paths — a mistake
already documented in MEMORY.md line 38.

**Lesson**: The first action in every session must be reading `AGENT.md` and the
memory files. The auto-loaded MEMORY.md snippet in system context is truncated
(200 lines) and easy to skim past. Explicitly reading the files ensures full
coverage and primes the correct workflows.

## 2026-04-03: MAME Lua os.exit() does not flush MFI disk images

**Context**: SYSGEN wrote to disk in MAME, but the MFI file was unchanged
because the Lua script called `os.exit(0)` which kills MAME immediately.

**Fix**: Use `manager.machine:exit()` for clean shutdown. MAME flushes the
MFI file to disk during normal exit.

**Lesson**: Never use `os.exit()` in MAME Lua scripts when disk writes must
persist. Use `manager.machine:exit()` instead.

## 2026-04-03: CP/M LOAD.COM expects type 00 EOF, not Intel HEX type 01

**Context**: Generated Intel HEX with standard `:00000001FF` EOF record.
LOAD.COM reported "INVALID HEX DIGIT" because it doesn't recognize type 01.

**Fix**: Use `:0000000000` (zero-length type 00 data record) as EOF.
CP/M's ASM.COM also produces this format.

## 2026-04-03: MAME null_modem RS232 defaults override Lua settings

**Context**: Tried to change null_modem baud rate from Lua via
`field.user_value`. The setting appeared to change but the null_modem
didn't reconfigure — `DEVICE_INPUT_DEFAULTS` from the driver takes
precedence and is applied at device creation, before Lua runs.

**Fix**: Change the defaults in `rc702.cpp` and rebuild MAME.

## 2026-04-03: Original RC702 BIOS (rel 2.3) serial is 1200 7E1 with 1-char buffer

**Context**: Serial transfer via PIP dropped characters even at 1200 baud.
The original BIOS only buffers a single character in the SIO (no ring buffer,
no effective RTS flow control). The clang BIOS has a 256-byte ring buffer.

**Lesson**: Serial file transfer to the RC702 requires either the clang BIOS
(ring buffer + RTS), or an external pacing mechanism. The distribution disk
serial settings are 1200 baud, 7 data bits, even parity, 1 stop bit.

## 2026-04-03: SYSGEN CPM56.COM workflow from RC702 Users Guide

**Context**: Spent significant time trying to work around the fact that
LOAD.COM creates a .COM spanning 0x0100-0x6BFF which overlaps the SYSGEN
buffer. The official RC702 documentation (CPM_FOR_RC702_USERS_GUIDE.pdf
appendix C) describes the correct workflow: SYSGEN reads/writes a file
(CPM56.COM) directly, using a filename argument.

**Lesson**: Always check vendor documentation before inventing workarounds.
The SYSGEN file-based workflow is simple: `SYSGEN CPM56.COM` reads the
file and writes to system tracks in one step.
