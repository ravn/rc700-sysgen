# Extracting RC700 IMD files and staging them on cpmsim MP/M

How to take a Dansk Datamuseum-style ImageDisk (`.imd`) of an RC700
floppy, pull individual CP/M files off it, and drop them onto one of
the disks the master MP/M (`z80pack/cpmsim/mpm-net2`) exposes to the
cpnos slave over CP/NET.

This is the recipe used to put PolyPascal v3.10 (`PPAS.COM`,
`PPAS.ERM`, `PPAS.HLP`, plus the bundled `.PAS` samples) onto the
slave's `E:` (= master `I:`) -- see `cpnos-rom/e_drive_seed/` for
both the source script and the resulting tree.

## TL;DR

```bash
# 1. Inspect the IMD to confirm geometry
python3 rcbios/imdinfo.py ~/Downloads/PolyPascal_v3.10.imd

# 2. Extract files into a host directory
python3 cpnos-rom/e_drive_seed/extract_polypascal.py \
    ~/Downloads/PolyPascal_v3.10.imd \
    cpnos-rom/e_drive_seed/ppas

# 3. Copy them onto the master library disk
for f in cpnos-rom/e_drive_seed/ppas/*; do
    cpmcp -f z80pack-hd \
        z80pack/cpmsim/disks/library/mpm-net2-drivei.dsk \
        "$f" "0:$(basename "$f")"
done

# 4. (Re)start mpm-net2 so the launcher seeds disks/drivei.dsk
#    from the freshly populated library copy
screen -S mpm -X quit; sleep 1
( cd z80pack/cpmsim && screen -dmS mpm ./mpm-net2 )
```

The slave then sees the new files at `E:` after its next netboot.

## Why this is fiddly

RC700 5.25" diskettes are mixed-density:

| Side  | Track 0           | Tracks 1+              |
|-------|-------------------|-------------------------|
| 0     | FM,  16 x 128 B   | MFM, 9 x 512 B          |
| 1     | MFM, 16 x 256 B   | MFM, 9 x 512 B          |

The data area is 9 sectors x 512 B per side from cylinder 1 onwards
with sector translate `[0,2,4,6,8,1,3,5,7]`.  Track 0 is part of
the boot/reserved tracks (BIOS, CCP, BDOS).

A raw image (`.bin`) flattens this away -- different vendors do it
differently (some pad track 0 to the data-track size, some don't),
which is why the matching `cpmtools` `diskdef` has to be derived case
by case.  The `.imd` form keeps the per-track geometry explicit, so
parsing it straight is much more robust than guessing geometry from a
raw blob.

## IMD parser

`rcbios/imd2raw.py` exports `parse_imd(path)` which yields
`(cyl, head, mode, nsect, sectsize, sectors)` per track, where
`sectors` is a list of `(sector_number, data_bytes)`.

Sector numbers in IMD aren't necessarily 1..N in physical order --
sort by sector number to recover the IBM-3740-style logical order.

## CP/M layout on the data tracks

For RC702E rel.2.01-style disks (the ones used by the DataMuseum
PolyPascal image):

- Cylinders 0 + 1 are reserved (boot tracks): BIOS at 0xF200+,
  CCP/BDOS, and on PolyPascal disks the resident interpreter.
- Cylinder 2 onward is the CP/M data area (`block_size = 2048`,
  `maxdir = 64`, one 2 KB directory block followed by 2 KB blocks
  of file data).
- Sector skew on the data tracks is `[0,2,4,6,8,1,3,5,7]`; reading in
  logical order means re-ordering each physical track by that table
  before walking the directory.

`cpnos-rom/e_drive_seed/extract_polypascal.py` does exactly this:
parse the IMD, skip cyl 0+1 (boot), de-skew the rest, parse the 2 KB
directory block, walk each file's allocation list, write each file out
as `<NAME>.<EXT>`.

## A note about extents

Old Pascal/Compas disks store files with EXM = 1 (one directory entry
covers two 16 KB extents).  `EX` in the directory entry is the
*highest occupied logical extent*, and `RC` is records in that
highest extent.  File size is therefore:

```
file_bytes = EX * 16384 + RC * 128
```

across the LAST directory entry of the file, with all earlier entries
being full 16 KB extents.  An entry with `EX = 1, RC = 0x5e` does NOT
mean "extent 1 is partial and extent 0 is missing" -- it means "the
file uses both extent 0 (full) and extent 1 (94 records)".  The
extractor handles both single- and multi-entry files this way; if you
build a similar tool, watch for this -- the standard "last-rc only"
formula will truncate every file to a fraction of its real size.

## cpmtools diskdef for the master HD

The master MP/M's harddisks are `z80pack-hd` -- 4 MB images, 255
tracks x 128 sectors x 128 B, block size 2 KB:

```
diskdef z80pack-hd
  seclen 128
  tracks 255
  sectrk 128
  blocksize 2048
  maxdir 1024
  skew 0
  boottrk 0
  os 2.2
end
```

The diskdef is in both `~/.local/share/diskdefs` (cpmtools default
search path) and `rcbios/diskdefs` (project copy).

## Adding files to other slave drives

The slave's `cpnos-rom/cfgtbl.c` `cfgtbl_init()` maps slave drives to
master drives:

```c
cfgtbl.drive[0] = NET_DRV('A', 0x00);   /* slave A: -> master A: floppy */
cfgtbl.drive[1] = NET_DRV('B', 0x00);   /* slave B: -> master B: floppy */
cfgtbl.drive[2] = NET_DRV('C', 0x00);   /* slave C: -> master C: floppy */
cfgtbl.drive[3] = NET_DRV('D', 0x00);   /* slave D: -> master D: floppy */
cfgtbl.drive[4] = NET_DRV('I', 0x00);   /* slave E: -> master I: 4 MB HD */
cfgtbl.drive[5] = NET_DRV('J', 0x00);   /* slave F: -> master J: 4 MB HD */
```

Want files on `B:` (CP/M tools floppy)?  Drop them onto
`disks/library/cpm22-1.dsk` (the disk seeded into `disks/driveb.dsk`
on launch) using the IBM-3740 8" SS-SD diskdef:

```bash
cpmcp -f ibm-3740 z80pack/cpmsim/disks/library/cpm22-1.dsk \
      myfile.com 0:MYFILE.COM
```

Mappings of library disk -> slave letter (from
`z80pack/cpmsim/mpm-net2`):

| Library disk                          | Slave drive |
|---------------------------------------|-------------|
| `cpnetsmk-1.dsk` / `mpm-net2-1.dsk`   | `A:`        |
| `cpm22-1.dsk`                         | `B:`        |
| `cpm22-2.dsk`                         | `C:`        |
| `mpm-net2-2.dsk`                      | `D:`        |
| `mpm-net2-drivei.dsk`                 | `E:`        |
| `mpm-net2-drivej.dsk`                 | `F:`        |

`cpmcp -f` arguments:

| Library disk                | diskdef        |
|-----------------------------|-----------------|
| `*.dsk` 256 256 B floppies  | `ibm-3740`      |
| `mpm-net2-drive[ij].dsk`    | `z80pack-hd`    |

## Restarting MP/M after disk changes

`mpm-net2` `cp`s the library disks onto `disks/drive[a-d,i,j].dsk`
each launch (CCP's one-shot `$$$.SUB` deletion would otherwise mutate
the pristine library copies).  So after `cpmcp`-editing a library
disk you have to bounce MP/M:

```bash
screen -S mpm -X quit
sleep 1
( cd z80pack/cpmsim && screen -dmS mpm ./mpm-net2 )
```

If the slave is already running in MAME, it'll keep using its old
view until you cold-boot it (close the MAME window or `make
cpnos-install` then relaunch).

## Other RC700 disk formats

If the IMD reports a different geometry (e.g., 8" RC702 maxi: 26x128
FM + 26x256 MFM track 0, 15x512 MFM tracks 1+), tweak
`extract_polypascal.py`:

- `tracks` filter (`if cyl < 2: continue`) -- adjust for the disk's
  reserved track count.
- `nsect` / `sectsize` checks at the data-track loop.
- `SKEW` table -- for 15-sector tracks the i8275 mini was
  `[1,5,9,13,2,6,10,14,3,7,11,15,4,8,12]` (1-based) per
  `rcbios/diskdefs:rc702-8dd:skewtab`.

For a one-off where the geometry is unfamiliar, the safe fallback is
`mtools`-style: convert IMD to raw via `rcbios/imd2raw.py`, ask
`cpmls` to scan with several diskdefs (`for fmt in rc702-5dd
rc702-8dd ibm-3740 z80pack-hd ...`), and grow the table from there.

## Where the artifacts live

| Path                                               | Purpose                                                |
|----------------------------------------------------|--------------------------------------------------------|
| `cpnos-rom/e_drive_seed/extract_polypascal.py`     | IMD-aware extractor (PolyPascal v3.10, RC702E rel.2.01) |
| `cpnos-rom/e_drive_seed/ppas/`                     | extracted file tree (committed)                        |
| `cpnos-rom/e_drive_seed/ws/`                       | RC703 WordStar 3.x files (lifted from rc703-div-bios-typer/) |
| `z80pack/cpmsim/disks/library/mpm-net2-drive[ij].dsk` | 4 MB master HD images, seeded into slave E: / F:     |
| `rcbios/imd2raw.py`                                | low-level IMD parser (parse_imd)                       |
| `rcbios/imdinfo.py`                                | IMD geometry pretty-printer                            |
| `rcbios/diskdefs`                                  | cpmtools diskdef collection (rc702-5dd, rc702-8dd, etc.) |
