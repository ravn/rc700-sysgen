# CP/NOS-next-steps

Forward-looking handover for the CP/NOS client work.  Historical
details + decisions live in `session24-cpnos-snios.md` and
`session29-ccp-prompt.md`; this doc is the short "where are we and
what's next" snapshot.

## Where we are (2026-04-21)

CP/NOS cold-boots on MAME `rc702` against the Python `netboot_server.py`
and reaches a fully functional CCP `A>` prompt.  Automated smoke
tests exercise:

- `make cpnos-netboot`        — cold boot to `A>` (4.5 s emulated)
- `make cpnos-warmboot-test`  — ^C warm boot via SIO-B (step 1)
- `make cpnos-sub-test CPNOS_SUB='...'` — arbitrary CCP commands
  driven by a server-seeded `$70.SUB` (steps 2-5, ~6 s emulated).
  Auto-appends `done` at the end; DONE.COM prints a marker on
  SIO-B and the Lua gate exits the instant the marker appears.
- `make cpnos-interactive`    — boot to `A>`, leave MAME running,
  PIO-A keyboard + SIO-B injection both drive CONIN concurrently.

Transients confirmed running from the network: PIPNET, MAIL, plus
anything in `cpnet-z80/dist/` and `cpnos-rom/testutil/`.
DIR listing honours SYS + R/O FCB attributes so test plumbing
stays invisible.

## What's broken / blocked

### Issue N — PIPNET WRITE SEQ FCB is zero
See `session29-ccp-prompt.md` §"Issue N".  Blocks step 6 (PIP copy
end-to-end).  Best next lead: MAKE reply likely under-populates
the FCB; need to diff against canonical BDOS fn 22 and trace
`cpndos.asm funtb2` entry 0x15.

## What's deferred

| ID | Summary | Why deferred |
|----|---------|--------------|
| D  | `mame_boot_test.lua` hardcodes `cfg_addr = 0xF4D4` | Resident moved; probe needs symbol lookup from `llvm-nm` at build time |
| E  | Lua PASS gate doesn't test CONIN | Now covered by step-1 warm-boot test; lower priority |
| F  | BDOS vector "want c3 06 de" is stale | Cosmetic — cpbios rewrites to `c3 06 cc` by design |
| J  | SEARCH FIRST preamble ambiguity (stsf1 vs stsf2) | Absorbed by `data[len-35:len-24]` hack; document if we ever touch CP/NET docs |
| K  | Single-client SEARCH iterator state | Only matters when running >1 slave |
| L  | Task-notification ≠ MAME-exit | Know it; use `pgrep -f regnecentralend` |
| M  | DIR entries are single-extent only | No file >16 KB is served; revisit at step 7 |

## Steps of the smoke plan

| Step | What | Status |
|------|------|--------|
| 1 | ^C warm boot | PASS (`cpnos-warmboot-test`) |
| 2 | ENTER on empty line | PASS (implicitly, via sub-test) |
| 3 | `DIR` → NO FILE | PASS (empty-map case) |
| 4 | `DIR` on populated dir | PASS |
| 5 | Run a transient `.COM` | PASS (PIPNET, MAIL, DONE all load) |
| 6 | `PIP B:FOO=A:BAR` copy | BLOCKED on issue N |
| 7 | Assemble SYSGEN.ASM + byte-diff | deferred |

## First thing to do next session

1. Re-read `session29-ccp-prompt.md` §"Issue N" for the raw WRITE SEQ
   DAT hex and the user hints about MAKE populating the FCB.
2. Add a `print(f"-> MAKE reply: {reply.hex()}")` to
   `netboot_server.py` and compare against a real CP/M-80 BDOS fn 22
   return (dump via MAME under a disk-based BIOS, or cross-check
   against a BDOS source listing).
3. Populate the alloc-map bytes in the MAKE reply with plausible
   non-zero block numbers.  If WRITE SEQ then arrives with a
   populated FCB, the root cause is confirmed and the fix is
   straightforward; if not, walk cpndos.asm's send path for fn 21.

## Where files live

- `cpnos-rom/netboot_server.py` — CP/NET server, dispatcher, file map
- `cpnos-rom/cpnos-build/` — CP/NOS monolithic image builder (DRI ASM → clang → ld.lld)
- `cpnos-rom/resident.c` + `init.c` + `isr.s` — our RC702 BIOS
- `cpnos-rom/testutil/done.com` — test marker binary
- `cpnos-rom/sio_b_driver.py` — SIO-B TCP bridge + keystroke injector
- `cpnos-rom/mame_sub_test.lua` + `mame_boot_test.lua` — gate scripts
- `cpnet-z80/dist/` — DRI reference binaries (read-only, frozen)
