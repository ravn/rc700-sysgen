# UPD765 Read Track ST1_ND Analysis

Analysis of the ND (No Data) flag behavior during the Read Track command on the
NEC µPD765A / Intel 8272A floppy disk controller, prompted by review feedback on
MAME PR #15031.

## The Bug in MAME

In `src/devices/machine/upd765.cpp`, the `read_track_continue()` function at the
`SCAN_ID` case was toggling ST1_ND per sector:

```cpp
// Old code (before fix)
case SCAN_ID:
    ...
    if(!sector_matches())
        st1 |= ST1_ND;
    else
        st1 &= ~ST1_ND;
```

This made the final ST1_ND state depend on whether the **last** physical sector
happened to match `command[4]` (the R value from the command phase). Since Read
Track reads sectors in physical order but the command specifies only one R value,
the outcome was essentially arbitrary from the caller's perspective.

### Impact

The RC703 boot PROM (rob357) uses Read Track to load boot sectors and checks ST1
with a mask of `0xB5` (EN | DE | OR | ND | MA). The spurious ST1_ND caused every
Read Track to be reported as failed, preventing boot. The RC702 boot PROM (roa375)
was unaffected because it uses Read Data instead of Read Track.

## Datasheet Analysis

### Source: NEC µPD765A Datasheet (docs/765.pdf)

This is the same datasheet linked by cracyc in the PR review:
http://dunfield.classiccmp.org/r/765.pdf

#### Read Track Command Description (p. 13 / PDF p. 471)

> "This command is similar to READ DATA Command except that this is a continuous
> READ operation where the entire data field from each of the sectors are read.
> Immediately after encountering the INDEX HOLE, the FDC starts reading all data
> fields on the track, as continuous blocks of data. If the FDC finds an error in
> the ID or DATA CRC check bytes, it continues to read data from the track. The
> FDC compares the ID information read from each sector with the value stored in
> the IDR, and sets the ND flag of Status Register 1 to a 1 (high) if there is
> no comparison. Multi-track or skip operations are not allowed with this command."

Key sentence: *"The FDC compares the ID information read from each sector with
the value stored in the IDR, and sets the ND flag of Status Register 1 to a 1
(high) if there is no comparison."*

This describes an ID comparison happening during Read Track. **The PR description's
claim that "the sector number is not compared" was inaccurate with respect to this
datasheet.**

#### ST1 ND Bit Definition (p. 17 / PDF p. 475)

The ST1 ND bit has **three separate definitions** depending on the command:

1. **Read Data / Write / Deleted Data / Scan**: "During execution of READ DATA,
   WRITE DELETED DATA or SCAN Command, if the FDC cannot find the Sector
   specified in the IDR Register, this flag is set."

2. **Read ID**: "During executing the READ ID Command, if the FDC cannot read
   the ID field without an error, then this flag is set."

3. **Read A Cylinder (Read Track)**: "During the execution of the READ A Cylinder
   Command, if the starting sector cannot be found, then this flag is set."

The Read Track entry says ND means **"starting sector cannot be found"** — a
different and narrower condition than "any individual sector ID didn't match the
IDR."

#### Internal Contradiction

The command description (p. 13) says ND is set during per-sector comparison, but
the ST1 bit definition (p. 17) says ND for Read Track means only "starting sector
cannot be found." These two descriptions are inconsistent. The ST1 bit definition,
being the authoritative specification of what each status bit means per command,
should take precedence.

### Ambiguity: "if there is no comparison"

The phrase "sets the ND flag ... if there is no comparison" is grammatically
ambiguous. It could mean:

1. "if the comparison result is no match" (values differ)
2. "if no comparison can be performed" (ID field unreadable)

Reading (2) would align with the ST1 ND bit definition (ND = starting sector
not found, i.e., no valid ID to compare against), while reading (1) contradicts
it.

### Earlier µPD765 Datasheet (Dec 1978, archive.org)

The earlier (non-A) µPD765 datasheet has identical wording for both the Read
Track command description and the ST1 ND bit definition. The ambiguity is present
in both revisions.

Source: https://archive.org/details/bitsavers_necdatasheec78_1042541

### Secondary Source: FDC Programming Reference (isdaman.com)

The well-known FDC programming reference at
https://www.isdaman.com/alsos/hardware/fdc/floppy.htm
(covering µPD765 and Intel 82072/82077) describes Read Track as:

> "the sector specification in the command phase is ignored for this command,
> and the reading starts with the first sector after the index address mark IDAM,
> reading sector by sector (paying no attention to the logical sector number given
> in the ID address mark)"

This explicitly states sector numbers are not compared during Read Track.

## cracyc's Suggestion

The MAME maintainer (cracyc, author of the original regression commit) suggested:
*"It's possible the value should not be reset after each sector."*

This is a reasonable reading of the command description: the FDC compares IDs and
**sets** ND on mismatch, but perhaps never **clears** it (accumulates). Under this
interpretation, ND would be set if any sector ID mismatched, and only be clear
if all sectors matched the IDR.

### Problem with accumulation approach

Read Track reads sectors in physical (rotational) order. Unless the disk has
sectors in strict sequential order matching the IDR's incrementing R value, some
sectors will inevitably not match. On interleaved disks (e.g., RC702 mini with
2:1 interleave), the physical order differs from the logical numbering, so
accumulating ND mismatches would still leave ND set after an otherwise successful
Read Track.

## The Fix

The submitted fix removes the `sector_matches()` call entirely from
`read_track_continue()`:

```cpp
// New code
case SCAN_ID:
    ...
    // Read Track does not compare sector IDs (UPD765/8272A datasheet:
    // "data is read continuously from index hole ... the sector number
    // is not compared").  Do not set ST1_ND based on sector matching.

    sector_size = calc_sector_size(command[5]);
```

### Alternative approach (offered to maintainer)

Set ND only in the `SCAN_ID_FAILED` path, which handles the case where no valid
sector ID is found after two index holes — matching the ST1 definition "starting
sector cannot be found." The `SCAN_ID_FAILED` case already exists in the code:

```cpp
case SCAN_ID_FAILED:
    fi.st0 |= ST0_FAIL;
    // st1 |= ST1_ND;  // currently commented out
    fi.sub_state = COMMAND_DONE;
    break;
```

Uncommenting the `st1 |= ST1_ND` line here would implement the ST1 bit definition
precisely.

## Real Hardware Evidence

The RC703 boot PROM (rob357) uses Read Track and checks ST1 with a mask that
includes ND. This PROM works on real RC703 hardware with a physical NEC µPD765A
FDC. If Read Track on real hardware set ND for mismatching sector IDs, the PROM
would fail on real hardware too.

## PR Status

- **PR #15031**: https://github.com/mamedev/mame/pull/15031
- **Status**: Under review, awaiting maintainer response
- **Clarification comment posted**: 2026-02-28, acknowledging the inaccurate
  datasheet quote and presenting the ST1 ND bit definition evidence

## Lesson Learned

The original PR description attributed a quote to the NEC µPD765A datasheet that
was actually from a secondary FDC programming reference. When citing datasheets
in upstream PRs, always verify the exact wording against the primary source
document. The NEC datasheet's actual text is more nuanced (and internally
contradictory) than the simplified secondary source suggests.

## References

1. NEC µPD765A datasheet: http://dunfield.classiccmp.org/r/765.pdf (local: docs/765.pdf)
2. NEC µPD765 datasheet (Dec 1978): https://archive.org/details/bitsavers_necdatasheec78_1042541
3. FDC programming reference: https://www.isdaman.com/alsos/hardware/fdc/floppy.htm
4. MAME UPD765 source: https://github.com/mamedev/mame/blob/master/src/devices/machine/upd765.cpp
5. MAME regression commit: 272ec75ca61 ("upd765: reset st0 when starting a seek")
