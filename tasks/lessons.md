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
