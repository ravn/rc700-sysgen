# CP/M Source Code

## PL/M and ASM Sources
- **Location**: `~/Downloads/cpm2-plm/`
- **Build instructions**: https://www.jbox.dk/rc702/cpm.shtm

## CCP (OS2CCP.ASM) Key Labels
- `direct:` (line 539) — DIR command. Traverses directory sectors.
- `type:` (line 625) — TYPE command. Opens file, reads sectors, prints contents.
- Both are CCP built-ins, useful for testing BIOS file I/O (SETDMA, READ, SEARCH).

## Testing C BIOS File I/O
- `DIR` exercises directory sector reads
- `TYPE DUMP.ASM` opens a file and reads its data sectors
- Known bug (commit 6862e4e): TYPE/STAT/ASM read empty directory entries
