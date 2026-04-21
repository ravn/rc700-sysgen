# Session 29 — CP/NOS reaches `A>` prompt

Date: 2026-04-21

## Milestone

Full cold-boot chain works end-to-end in MAME:

```
netboot stream -> cpnos.com at 0xD000/0xCC00
  -> cpbios banner "RC702 CP/NOS v1.2"
  -> cpndos NWBOOT
  -> 20x SNIOS READ SEQ of CCP.SPR (128 B/record) from Python server
  -> CCP at A>
```

`mame_boot_test.lua` now gates on `A>` appearing in the 8275 display
buffer (0xF800). Observed at frame 225 (4.5 s emulated).

## Changes landed

- **`netboot_server.py`** — DRI SNIOS wire dispatch extended to real
  file serving. `CCP     SPR` mapped to `cpnet-z80/dist/ccp.spr` via
  `_FILE_MAP`; `_OPEN_FILES` caches file contents across OPEN/READ/
  CLOSE. `_fcb_key` normalises FCB name+ext to the canonical 11-char
  key. READ SEQ walks `ex` and `cr` FCB fields (cr 0..127, then rolls
  to next extent), returning 128-byte records padded with `0x1A` at
  EOF. Unhandled BDOS fns return success+empty FCB (placeholder).

- **`mame_boot_test.lua`** — PASS gate rewritten. Old gate fired at
  2.5 s when PC happened to land in 0xD000..0xF800 with C3 opcodes
  in zero page; that condition is satisfied mid-way through NDOS's
  CCP load and produced false-green runs. New gate scans the display
  for `A>` anywhere in rows 0..24. Timeout extended to 60 s.

- **`Makefile`** — `-seconds_to_run 40` -> `70` so MAME outlives
  the Lua 60 s timeout on slower hosts.

- **`.gitignore`** — `cpnos-build/d/` (XIZ+dri2gnu.pl intermediate
  output, regenerated on every build).

## Validation

- `make cpnos-netboot` prints `PASS (A> at row 13 col 0)` and exits
  cleanly. Server log shows OPEN/READ x 20/CLOSE for CCP.SPR, no
  protocol retries.

## Known issues / open work

### Issue A — CCP is at the prompt but nothing has been typed
No command has been executed yet. No DIR, no TYPE, no warm-boot.
Before declaring CCP "works", we need to inject keystrokes via SIO-B
or null_modem bitbang and see CCP echo + respond. Candidate tests:
- `DIR` -> should list empty directory (server returns FILE-NOT-FOUND
  for every SEARCH FIRST) + `A>` reprompt
- `^C` -> warm boot -> re-fetches CCP.SPR

### Issue B — Server's SNIOS dispatch is stub-shaped for most fns
Only fns 13/14/15/16/20 actually do anything sensible. Fns unhandled
(return all-zeros success): 17 (SEARCH FIRST), 18 (SEARCH NEXT), 19
(DELETE), 21 (WRITE SEQ), 22 (MAKE), 23 (RENAME), 33/34 (RANDOM I/O),
35 (FILE SIZE), 36 (SET RANDOM RECORD). DIR will call 17/18 and get
back garbage. First keystroke likely exposes this.

### Issue C — File map is hardcoded single entry
`_FILE_MAP = {'CCP     SPR': '.../ccp.spr'}`. A real server needs to
walk a directory (e.g. `cpnet-z80/dist/`) per slave and per user area,
honour drive letter (A..P) plus user number (0..15), and translate
CP/M wildcards (`*`, `?`) to SEARCH FIRST/NEXT results.

### Issue D — `mame_boot_test.lua` uses hardcoded `cfg_addr = 0xF4D4`
CFGTBL symbol address is linker-determined; dump shows that address
now holds cpbios code, not CFGTBL. The Lua probe should read the
linker map / `llvm-nm cpnos.elf` output and be handed the right
address at build time (e.g. emit a generated `mame_symbols.lua`).

### Issue E — Lua PASS gate doesn't verify CCP responds to input
Finding `A>` proves CCP reached its prompt, not that the BIOS/CONIN
path works. Next-level gate: write a char to SIO-B, observe echo on
display or in serial log.

### Issue F — BDOS vector dump says `want c3 06 de`
Cosmetic: after cpbios runs, 0x0005 is rewritten to `c3 06 cc` (BDOS
lives inside the 0xCC00 data region). The "want" string in
`mame_boot_test.lua:finish()` is stale from pre-cpbios days.

## Follow-up work landed this session

- **CONIN dual-path** (commit `d939759`) — `impl_const`/`impl_conin`
  drain from a 16-byte PIO-A keyboard ring buffer in addition to the
  existing SIO-B poll. New `isr_pio_kbd` (isr.s) enqueues on each
  PIO-A interrupt; `init_pio_kbd` configures input mode + IRQ with
  vector 0x20 at IVT slot 16. SIO-B wins when both have a byte so
  automation via the serial line sees deterministic ordering.

- **SIO-B output capture** (commit `61c8860`) — `cpnos-netboot` now
  writes every CONOUT byte through the second null_modem to
  `/tmp/cpnos_siob.raw`; `make` target prints a printable-filtered
  view of it. Complements screen scrape as a text-only channel.

## Newly raised issues

### Issue G — SIO-B drain timing cuts off late output
Bytes still in the SIO TX FIFO when Lua calls `manager.machine:exit()`
never reach the `bitb2` file. At 38400 baud each byte needs ~260 us;
four bytes of `\r\nA>` lose the race. Fix: once the pass/fail gate
matches, keep the frame loop alive for ~10 more frames (200 ms
emulated) before calling `finish()`. Affects all tests that assert on
SIO-B content.

### Issue H — SIO-B injection path not wired
User intent: SIO-B = automation injection (from me), PIO-A = physical
keyboard (from user). Output capture currently uses `bitb2 <file>`
which is unidirectional in practice. For bidirectional injection we
need `-rs232b null_modem -bitb2 socket.127.0.0.1:PORT2` + a small
Python helper that accepts, sends keystrokes, and appends received
bytes to a log file. Strictly needed before step 1 can drive CCP
from automation.

### Issue I — PIO-A ISR functionally untested
New code paths (`isr_pio_kbd`, ring buffer, init sequence) compile
and do not regress the cold boot, but nothing has enqueued a byte
yet. First test: MAME `natkeyboard:post("A\r")` after the `A>` gate;
expect the typed text echoed through `impl_conout` to the display
and SIO-B log. Pinning this down doubles as the first real CONIN
exercise.

## Next session

Pick one:
1. **Type a char into CCP** (Issue A+E) — minimal new code, exercises
   the input side of the stack. Likely reveals Issue B immediately
   when CCP runs the command.
2. **Implement SEARCH FIRST/NEXT + WRITE on the server** (Issue B+C)
   so `DIR` and `SAVE` work against a real directory.
3. **Wire CFGTBL address from `llvm-nm`** (Issue D) so the boot test
   can re-check SLAVEID/NETST post-NDOS.

Recommendation: 1 first — it's the smallest step that still proves
the stack is alive in both directions.

## Progress against the smoke plan

- Step 1 (^C warm boot) — PASSES via `make cpnos-warmboot-test`
- Step 2 (ENTER on empty line) — passes implicitly (see PIP session below)
- Step 3 (DIR -> NO FILE) — PASSES once DELETE returned 0xFF for absent
  files; earlier catch-all's fake-success confused CCP's post-command
  housekeeping and stalled the CONOUT path.
- Step 4 (DIR against populated directory) — PASSES.  Server now scans
  `cpnet-z80/dist/` at startup (`_build_file_map`) and SEARCH FIRST/NEXT
  iterate matching `_FILE_MAP` keys; CCP prints a 13-file listing in
  the standard four-up format.
- Step 5 (run a transient .COM) — PASSES spontaneously.  Typing
  `pipnet` at A> loaded PIP.COM end-to-end: SEARCH → OPEN → 8 x READ
  → JP 0x0100 → PIP's `*` prompt.  That proves the full network
  transient path works for arbitrary .COMs.
- Step 6 (PIP cross-drive copy) — server side ready (MAKE fn 22,
  WRITE SEQ fn 21, DELETE fn 19 all in place).  First attempt with
  `pipnet foo.txt=login.com` via SUB:
    * CCP parses + loads PIPNET.COM successfully
    * PIPNET opens LOGIN.COM (read) — 384 B, works
    * PIPNET issues MAKE for temp file `FOO.$70` (note the slave-ID
      extension — PIPNET reserves `$<slave_hex>` namespace for
      per-slave temp files) — works
    * PIPNET issues WRITE SEQ — fails with a garbled FCB key of
      nine NUL bytes + `$$` in the extension slot
  Investigation parked; WRITE SEQ wire layout likely differs from
  READ SEQ (my handler assumes the same `data[1:37]` slice).
  Revisit by capturing the raw DAT hex and decoding against NDOS
  send path.
- Step 7 (SYSGEN.ASM byte-diff) — deferred.

## $$$.SUB automation is live

Commit `b66c8a2` adds CP/NET-native batch execution.  Server seeds
`$<slave>.SUB` in `_WRITES` from the `CPNOS_SUB` env var; CCP reads
the file at the first prompt via fns 33/34/35 (RANDREAD / RANDWRITE
/ FILE SIZE) and runs each command, then deletes the SUB.  New
target `make cpnos-sub-test CPNOS_SUB='dir|pip foo=bar'` runs a
canned session and asserts the server saw the SUB OPEN — catches
regressions across the full SEARCH / OPEN / FILE SIZE / RANDREAD /
DELETE pipeline as a single integrated smoke test.

This is the preferred automation surface going forward.  SIO-B
injection (`sio_b_driver.py --trigger / --inject`) stays for mid-
program input (e.g. feeding PIP's `*` prompt or MAIL's menu).

## Newly raised issues

### Issue J — SEARCH FIRST preamble ambiguity
NDOS's `stsf` routes through two different branches depending on
whether `FCB[0]` is `'?'` (wildcard-drive) or a specific drive code,
producing different on-wire preambles (37 B vs 38 B) before the FCB
body.  Current server code uses `data[len-35 : len-24]` to extract
the 11-char name+ext pattern from the tail of the FCB block,
absorbing the preamble difference.  Robust but fragile if any future
BDOS fn packs a different tail layout.  Document in
`cpnet/DRI_PROTOCOL.md` when we next touch it.

### Issue N — CP/NET WRITE SEQ FCB not decoded (blocks step 6)
WRITE SEQ from PIPNET during `A>pipnet foo.txt=login.com` arrives
with a nearly all-zero FCB:
  `00 01 00×9 24 24 00×24 [128-byte sector]`
Only the `$$` bytes at offsets 11-12 (ext) are non-zero.  MAKE for
`FOO.$70` succeeded immediately before, so PIPNET does hold a
populated FCB — the wire frame just doesn't carry it as expected.

User hints (directly from the session):
 - "MAKE should populate the FCB correctly"
 - "WRITE method assumes ownership of the FCB and updates fields
    inside for record keeping purposes"
Best guess: the server's MAKE reply under-populates (missing
allocation map / per-NET fields) so PIPNET's subsequent WRITE
emits a zeroed-out FCB.  Alternative: CP/NET fn 21 wire format
differs from fn 20 in ways I haven't traced yet.

Next steps when revisiting:
 - Log MAKE reply hex as sent and diff against canonical BDOS.
 - Trace `cpndos.asm funtb2` entry for fn 21 (opcode 0x15) to see
   the send-side packing.
 - Populate MAKE reply alloc map with realistic block numbers and
   retry; if WRITE then arrives populated, under-population was
   the bug.

### Issue M — Directory entry is single-extent only (deferred)
`_dir_entry` in `netboot_server.py` builds one 32-byte CP/M directory
entry per file, assuming the whole file fits in extent 0 (max 128
records = 16 KB).  Files larger than 16 KB should emit multiple
extents (extent 0, 1, 2 …) so operations like FILE SIZE (fn 35) and
SEARCH NEXT iteration return accurate info.  All files currently
served from `cpnet-z80/dist/` are well under 16 KB so the first-
extent-only shortcut is fine today; revisit when we serve a larger
binary (e.g. MAC.COM or SYSGEN.ASM listings for step 7).

### Issue K — Single-client SEARCH iterator state
`_SEARCH_STATE` is a module-global dict.  Only one CP/NOS slave can
search concurrently.  Fine now (one MAME), breaks if we ever run two
slaves against the same server.  Key on `(did, sid)` from the SNDMSG
header when it becomes relevant.

### Issue L — Host-task completion != MAME exit
Background `make cpnos-interactive` runs MAME in the make's
foreground but backgrounds the Python servers; the Bash tool's
"task completed" signal does not reliably correspond to MAME being
dead (shell wrapper can finish setup while MAME keeps running; or
conversely, Python server exit can race).  Authoritative check is
`pgrep -f regnecentralend`.  Don't treat task-notification as
ground truth.

## Tiered smoke plan (growing workload)

Each step adds one dimension of coverage; failing early rules out
later work. Steps 1-3 need no server changes; 4-7 do.

1. **`^C` warm boot** — CONIN + CCP reload. Server sees a second
   OPEN/READ burst for CCP.SPR. Sanity check.
2. **ENTER on empty line** — CCP reprompts. Proves CONOUT + edit
   buffer round-trip.
3. **`DIR`** — SEARCH FIRST (17) + SEARCH NEXT (18). Currently stubs.
   Expected `NO FILE` until fns implemented.
4. **`DIR` against populated server dir** — drop 2-3 files in
   `cpnet-z80/dist/` visible to slave 0x70. Real directory scan.
5. **Run one transient `.COM`** — tiny "print banner + RET". Exercises
   OPEN / READ SEQ / CLOSE on arbitrary file + TPA jump + warm boot
   on exit. Declaring the core stack "works" happens here.
6. **`PIP B:=A:FOO.TXT`** — cross-drive read, WRITE SEQ (21) + MAKE
   (22).
7. **Assemble SYSGEN.ASM under CP/NOS and byte-diff output** — the
   strongest regression test in the repo.

   - Host `MAC.COM` on the server, feed it `sysgen/SYSGEN.ASM`
     (several KB, macros, conditionals).
   - Keystroke `MAC SYSGEN$PZ` via null_modem bitbang.
   - Server logs every WRITE by filename; after `A>` reappears,
     host-side diff `server_writes/SYSGEN.COM` vs
     `sysgen/RCSYSGEN.COM` — must be byte-identical.
   - Exercises: sustained READ (dozens of records), sustained WRITE
     (HEX + PRN + SYM emitted concurrently/sequentially), wildcard
     SEARCH, possibly random I/O, TPA occupancy (~8-10 KB for MAC),
     minutes of emulated time without a protocol hiccup.
   - Pinning caveat: byte-exact match against RCSYSGEN.COM assumes
     the CP/NOS-hosted MAC version matches the zmac `--dri` mode we
     use to verify on host. If they differ, pin the first successful
     output as the reference — the test still catches stack
     regressions either way.

Automation for all steps: MAME null_modem bitb socket injects
keystrokes, Lua gate looks for expected display substrings
(`NO FILE`, `HELLO`, re-prompt, etc.).
