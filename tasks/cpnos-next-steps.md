# CP/NOS next steps

Forward-looking handover for the CP/NOS client work.  Historical
details live in `session24-cpnos-snios.md` and
`session29-ccp-prompt.md`; this doc is the short "where are we and
what's next" snapshot.

## Where we are (2026-04-21, session 29 close)

CP/NOS cold-boots on MAME `rc702` against the Python
`netboot_server.py` and runs real CP/M programs against a Python-
backed directory.  **All seven smoke-plan steps are green.**
Automated tests:

| Make target | What it proves | Wall time |
|-------------|----------------|-----------|
| `cpnos-netboot` | cold boot to `A>` | ~3 s |
| `cpnos-warmboot-test` | ^C warm boot (step 1) | ~3 s |
| `cpnos-sub-test CPNOS_SUB='dir'` | DIR listing (steps 2-4) | ~3 s |
| `cpnos-sub-test CPNOS_SUB='copy mailcopy.com mail.com'` | end-to-end file copy, byte-verified | ~7 s |
| `cpnos-sub-test CPNOS_SUB='mac sysgen $$pz\|load sysgen'` | MAC+LOAD assembling SYSGEN.ASM (step 7) | ~14 s |
| `cpnos-interactive` | leave MAME up; PIO-A keyboard + SIO-B injection both drive CONIN | (manual) |

Last SYSGEN assembly run produced output that is **1401 / 1408
bytes byte-identical to `sysgen/RCSYSGEN.COM`** (the zmac-built
gold reference).  The 7-byte diff is inside a string-table gap
where DRI's MAC leaves leftover bytes from the prior literal
(`'RETURN TO SKIP'`) that zmac zero-pads — unrelated to any
server or transport issue.

## Smoke plan status

| Step | What | Status |
|------|------|--------|
| 1 | ^C warm boot | PASS |
| 2 | ENTER on empty line | PASS (via SUB) |
| 3 | `DIR` → NO FILE | PASS |
| 4 | `DIR` on populated dir (13 files) | PASS |
| 5 | Transient `.COM` (PIPNET, MAIL, DONE, COPY) | PASS |
| 6 | File copy, byte-verified | PASS via `testutil/copy.com` (8192 B of MAIL.COM round-trip identical) |
| 7 | MAC+LOAD of SYSGEN.ASM, byte-diff against gold | PASS (1401/1408 B match; 7 B are a MAC vs zmac string-table quirk) |

## Known open items (none blocking)

### Issue N — PIPNET.COM sends a zeroed FCB on WRITE SEQ
PIPNET-specific quirk, not a server bug.  Our write path is
proven correct via `testutil/copy.com` (same server, same NDOS,
same wire protocol → step 6 + 7 PASS).  Resolving would mean
disassembling `cpnet-z80/dist/pipnet.com` (no source in cpnet-z80
or z80pack) to find what FCB pointer PIPNET actually hands to
BDOS fn 21 and why its contents are wiped between MAKE and WRITE.
Pick up only if PIPNET specifically is required.

### Deferred (none urgent)

| ID | Summary | Why deferred |
|----|---------|--------------|
| D  | `mame_boot_test.lua` hardcodes `cfg_addr = 0xF4D4` | Resident moved; probe needs `llvm-nm` lookup at build time |
| E  | Lua PASS gate doesn't test CONIN | Now covered by step-1 warm-boot test |
| F  | BDOS vector "want c3 06 de" is stale | Cosmetic — cpbios rewrites to `c3 06 cc` by design |
| J  | SEARCH FIRST preamble ambiguity (stsf1 vs stsf2) | Absorbed by `data[len-35:len-24]`; revisit if we touch CP/NET docs |
| K  | Single-client SEARCH iterator state | Only matters with >1 slave |
| L  | Task-notification ≠ MAME-exit | Known; use `pgrep -f regnecentralend` |
| M  | DIR entries are single-extent only | No served file exceeds 16 KB yet |

## What could happen next

- **Back to the actual project goal** (per `~/z80/CLAUDE.md`):
  optimize the LLVM-Z80 backend against SDCC code density.  PROM
  is 1756 B clang vs 1910 B SDCC; BIOS 6021 vs 6123.  Paused for
  the CP/NOS detour — ready to resume.
- **Physical RC702 test** of today's work: laptop running
  `netboot_server.py` on SIO-A, real hardware booting the new
  PROM.  Would flush out any MAME-specific assumptions.
- **PIPNET disassembly** (issue N) — only if required.
- **zmac instead of MAC** in step 7 — closes the 7-byte diff, but
  returns zero functional value.

## Where files live

- `cpnos-rom/netboot_server.py` — CP/NET server, dispatcher, file map
- `cpnos-rom/cpnos-build/` — CP/NOS monolithic image builder (DRI ASM → clang → ld.lld)
- `cpnos-rom/resident.c` + `init.c` + `isr.s` — our RC702 BIOS
- `cpnos-rom/testutil/` — test fixtures (done.com, copy.c/com, mac.com, load.com, sysgen.asm)
- `cpnos-rom/sio_b_driver.py` — SIO-B TCP bridge + keystroke injector
- `cpnos-rom/mame_sub_test.lua`, `mame_boot_test.lua` — gate scripts
- `cpnet-z80/dist/` — DRI reference binaries (read-only, frozen)
- `/tmp/cpnos_writes/` — server-flushed copies of written files (populated during tests)
