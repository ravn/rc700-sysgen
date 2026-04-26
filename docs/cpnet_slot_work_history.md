# CP/NET host-bridge slot work — history and current state

> Status as of 2026-04-27.  Living summary; update when material
> things change.  Companions:
> [`cpnet_fast_link.md`](cpnet_fast_link.md) (design context),
> [`cpnet_pio_direct_design.md`](cpnet_pio_direct_design.md) (no-slot
> alternative), [`mame-rc702-piob-slot-regression.md`](mame-rc702-piob-slot-regression.md) (ravn/mame#6 mirror).

## Goal

Plumb CP/NET frames between the Z80's PIO-B port inside MAME's
`rc702` driver and an external process (Pi/Mac harness, eventually
real MP/M-NET).  This is "Option P" in the fast-link design.

## Timeline

### Slot-based attempt (cpnet-fast-link branch)

Implemented as MAME's idiomatic peripheral pattern:

```
src/devices/bus/rc702/pio_port/
  pio_port.{h,cpp}    rc702_pio_port_device wraps device_single_card_slot_interface
  keyboard.{h,cpp}    generic_keyboard wrapped as a slot card on PIO-A
  cpnet_bridge.{h,cpp}  POSIX-socket TCP listener on :4003 + listener thread
                       + FIFO + emu_timer poll + STB pulse
```

`rc702.cpp` wired both PIO-A and PIO-B as slots:

```cpp
m_pio->in_pa_callback().set(m_pio_a, FUNC(rc702_pio_port_device::read));
m_pio->in_pb_callback().set(m_pio_b, FUNC(rc702_pio_port_device::read));
```

PIO-A defaulted to `keyboard` card (preserving existing behaviour);
PIO-B defaulted to empty slot (no card), `-piob cpnet_bridge`
populated it.

Merged into master via merge commit `588658b4327` "Option P slot
infrastructure + WIP fix" on 2026-04-25.

### Regression discovery (Session #32)

Symptom: with `-piob cpnet_bridge` (or `-piob keyboard`), cpnos-rom
guest initialization stalls — VRTC IRQ stops firing, CRT goes black,
CCP never loads.  Without `-piob` (empty slot), cpnos-rom appeared
to boot to A>.

Filed as **[ravn/mame#6](https://github.com/ravn/mame/issues/6)**.

### Workaround attempts (all failed)

**Path 2 — Einstein topology** (commit `54cccdbc3af`).  Hypothesis:
having two slots on a single Z80-PIO chip is the trigger; reverting
PIO-A to direct keyboard wiring while keeping PIO-B as the lone slot
should fix it.  Result: `-piob keyboard` still produced the regression.
**Falsified** the "two slots" hypothesis — a single slot card is
enough.

**Path 3 — bypass slot, wire `cpnet_bridge_device` directly to chip
callbacks**.  Two flavours:

- 3a: `devcb_write_line` + accessor pattern.
- 3b: `std::function<void(int)>` + lambda.

Both crashed at MAME config time (`device_t::config_complete + 428`)
with PAC-tagged garbage register dumps — before any data flowed.
Discarded.

### "Empty slot is benign" — wrong for cpnos (2026-04-27)

The 2026-04-26 morning comment on ravn/mame#6 stated empty PIO-B
slot is benign for normal RC702 use.  Verified at the time by booting
CP/M from `SW1711-I8.imd` (autoload PROM path).

**Subsequently invalidated** for cpnos-rom: cpnos-rom uses PIO-B's
IM2 IRQ vector for `isr_pio_par`.  Even with **no card plugged in**,
the empty `RC702_PIO_PORT(config, m_pio_b)` slot wrapper interferes
enough that cpnos-rom hangs at `PC=0x0039` and never sends ENQ on
SIO-A.  60s emulated, no A>, screen black.

The autoload-PROM CP/M boot doesn't engage PIO-B's IM2 vector, so it
isn't sensitive to the same break.  The bug fires when the guest
tries to use PIO-B for IRQ-driven receive — which is exactly cpnos's
use case.

The ravn/mame#6 issue title and body need amending to reflect this:
the regression is "any slot wrapper on PIO-B breaks IM2 vector
delivery", not just "any card on PIO-B".

### Master reverted (2026-04-27)

`master` was reverted to drop the merge: commit `b06f303737a`
"Revert 'Merge branch cpnet-fast-link'".  Working tree of the revert
is byte-identical to pre-merge `1f2d4d000db` (verified with `git
diff --stat 1f2d4d000db HEAD` returning empty).

Open puzzle: a freshly-built binary from the revert tree fails
cpnos-rom boot the same way the merge did, while the April-21
daily-use binary at `/Users/ravn/git/mame/regnecentralend` (built
from the same `1f2d4d000db` SHA) succeeds.  Same source, different
behaviour.  Suspects: stale `.o` cache pollution from earlier
slot-infra builds, or build-flag drift.  Still under investigation.

### Direct (no-slot) bridge attempt — branch `cpnet-pio-direct`

Designed in
[`cpnet_pio_direct_design.md`](cpnet_pio_direct_design.md):
drop slot/card entirely; wire `m_pio->in_pb_callback().set(FUNC(rc702_state::cpnet_pb_r))`
directly; use MAME's `osd_file` as TCP listener (no POSIX socket);
single emu thread via 1ms `emu_timer`; raw byte logs to
`/tmp/cpnet_pio_rx.bin` + `tx.bin`.

Implementation was written and built once.  At the byte layer it
worked: 6 bytes from the harness arrived in `rx.bin`, the strobe
fired once, the chip's `in_pb_callback` returned the right byte.
But the chip's IRQ never delivered (chip log: `IE=0 IP=1` at end —
cpnos-rom never enabled IRQ on PIO-B before our strobe arrived,
because cpnos-rom itself wasn't booting through to its PIO-B init
phase — the slot-infra regression was masking everything).

The implementation code was lost in a stash/checkout cycle.  Design
doc and rc700-gensmedet harness changes survive.  Re-implementation
should be straightforward from the design doc.

## Branch state (2026-04-27)

| Repo | Branch | Tip | Notes |
|---|---|---|---|
| `ravn/mame` | `master` | `b06f303737a` | Revert of merge `588658b4327`; not yet pushed (verification still pending) |
| `ravn/mame` | `cpnet-fast-link` | `54cccdbc3af` | Slot infra + Path 2 revert; pushed |
| `ravn/mame` | `cpnet-pio-direct` | (master tip) | No commits beyond master; design doc only in rc700-gensmedet |
| `ravn/rc700-gensmedet` | `main` | `3c0a1b1` | Has the merged Phase 3 cpnos-rom + harness pre-redesign |
| `ravn/rc700-gensmedet` | `cpnet-pio-direct` | (uncommitted) | `harness.py` switched mpm-net2 → `netboot_server.py`; `dump_logs.sh`; design doc |

## What we still don't know

1. **Why empty PIO-B slot breaks cpnos-rom IM2 vector**.  The
   structural mismatch (Z80-PIO is flat in MAME, no per-port
   subdevices) is suspicious but doesn't explain the specific
   failure mode (cpnos hangs at PC=0x0039 before its first SIO-A
   write).  Path 2 ruled out "two slots on one chip".  Path 3
   crashes ruled out one specific bypass approach.  The actual
   broken seam in MAME's slot/PIO interaction has not been
   localized.

2. **Why a freshly-built revert binary differs from the April-21
   daily-use binary built from the same SHA**.  Same source tree,
   different behaviour.  Build cache, link order, or compiler
   version drift are the candidates.

## Next steps

1. **Fix or work around the build delta** so the revert binary
   actually matches the daily-use binary's behaviour.  Without
   that, no clean baseline for the direct-bridge implementation.
2. **Re-implement the direct-bridge code** on `cpnet-pio-direct`
   from the design doc.  ~80 lines net change in `rc702.cpp`.
3. **Verify the direct bridge** with the harness: byte-level
   round-trip + cpnos-rom screen renders + isr_pio_par fires.
4. **Amend ravn/mame#6** comment to reflect "empty slot also
   breaks cpnos for IM2-using guests".
5. **(Eventually)** revisit the slot-on-PIO regression itself,
   either by debugging MAME's interaction or by accepting the
   no-slot pattern for RC702 and documenting the scope as a
   known limitation upstream.

## What survives if this work pauses

- `cpnet-fast-link` branch (mame): preserves all the slot work for
  reference, including the failed Path 2 attempt.
- `mame-rc702-piob-slot-regression.md`: factual bug report (needs
  amendment per the empty-slot finding).
- `cpnet_pio_direct_design.md`: the design doc for the no-slot
  approach, suitable for re-implementation.
- This file: connective tissue between them.
