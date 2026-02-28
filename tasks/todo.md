# Build all 13 CP/M BIOSes from source

## Completed
- [x] Step 1: Fetch jbox.dk originals → `rcbios/jbox-originals/` (16 files)
- [x] Step 2: Trivial targets — `rel14-mini`, `rel23-mini` added to Makefile
  - Updated verify_bios.py with ref_offset parameter
  - Switched verification from ref/ RAM dumps to extracted_bios/ disk extractions
  - All 6 targets (rel21-mini, rel22-mini, rel23-mini, rel23-maxi, rel14-mini, rel14-maxi) verified

## In Progress
- [ ] Step 3: REL13 conditional (58K rel.1.3) — analysis agent running
- [ ] Step 4: REL20 conditional (56K rel.2.0) — analysis agent running

## Pending
- [ ] Step 5: RC702E family (separate source tree) — analysis agent running
- [ ] Step 6: RC703 family (separate source tree) — analysis agent running
- [ ] Step 7: Update verify_bios.py for all families
- [ ] Step 8: Full verify-all target

## Verification Status (13 targets)
| # | Target | Flags | Status |
|---|--------|-------|--------|
| 1 | rel13-mini | -DREL13 -DMINI | pending |
| 2 | rel14-mini | -DREL14 -DMINI | assembles OK |
| 3 | rel14-maxi | -DREL14 -DMAXI | assembles OK |
| 4 | rel20-mini | -DREL20 -DMINI | pending |
| 5 | rel21-mini | -DREL21 -DMINI | MATCH |
| 6 | rel22-mini | -DREL22 -DMINI | MATCH |
| 7 | rel23-mini | -DREL23 -DMINI | MATCH |
| 8 | rel23-maxi | -DREL23 -DMAXI | MATCH |
| 9 | rc702e-rel201 | separate src | pending |
| 10 | rc702e-rel220 | separate src | pending |
| 11 | rc703-rel10 | separate src | pending |
| 12 | rc703-rel12 | separate src | pending |
| 13 | rc703-relTFj | separate src | pending |
