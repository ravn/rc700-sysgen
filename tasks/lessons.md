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
