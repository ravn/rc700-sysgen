# Session 24 (cont.) — SNIOS ported into cpnos-rom

Date: 2026-04-20

## What landed

- **`cpnos-rom/snios.s`** — SNIOS (CP/NET Slave Network I/O System)
  ported from `cpnet/snios.asm` (DRI syntax) to GNU-as for clang
  integrated assembly. 8-entry SNIOS jump table (NTWKIN / NTWKST /
  CNFTBL / SNDMSG / RCVMSG / NTWKER / NTWKBT / NTWKDN) exposed at
  `_snios_jt`. Body implements the DRI binary framing
  (ENQ→ACK→SOH+header+HCS→ACK→STX+data+ETX+CKS+EOT→ACK) unchanged.

- **Direct calls into the C transport.** The DRI original used BIOS
  READER/PUNCH/READS at hardcoded `0xDA12`/`0xDA15`/`0xDA4D`; cpnos-rom
  has no ring-buffered BIOS reader, so SENDBY / RECVBY / RECVBT call
  `_transport_send_byte` and `_transport_recv_byte` directly. The two
  transport functions have documented clobber patterns, so SNIOS
  saves HL/DE around each call to preserve protocol state.

- **CFGTBL unified.** Dropped the DRI inline CFGTBL from the asm;
  `cfgtbl.c` owns the canonical layout (173-byte struct with
  static_asserts on all key offsets).  SNIOS references it via
  `extern _cfgtbl` + symbolic offsets (`CFG_NETST`, `CFG_SLAVEID`,
  `CFG_SIZ`, `CFG_MSGBUF`).

- **Layout shift.** BIOS_BASE 0xF580 → 0xF200, RESIDENT region
  0x200 → 0x600. Required because SNIOS (463B) + existing BIOS jt +
  stubs + CFGTBL totals 867B, doesn't fit the old 512B window.
  Init stack moved from 0xF580 → 0xF200 in step.

- **Build harness.** Added `-g` to `ASFLAGS` so the linked-ELF
  listing (`make cpnos-lis`) interleaves snios source lines.
  `snios.o` added to `OBJS`; `.resident.snios_jt` + `.resident.snios`
  sections added as KEEP entries in `cpnos_rom.ld` (nothing references
  them yet; without KEEP they'd be gc'd).

- **Naming.** Renamed `_cfgtbl` → `cfgtbl` in `cfgtbl.c` to avoid the
  clang-Z80 ABI appending a second underscore when C identifiers
  already start with one.  Asm-visible symbol is now `_cfgtbl`,
  matching the natural SDCC calling convention.

- **Dead code trimmed.** DRI original reloaded SLAVEID in NTWKIN
  because its inline table started at `0xFF`; cfgtbl.c seeds the real
  value at build time, so the reload is dead.  Saved 3B.

## Size snapshot

| Metric | Before | After |
|---|---|---|
| PROM0 non-pad bytes | 777 | 1218 |
| `.resident` (VMA) | 0x194 @ 0xF580 | 0x363 @ 0xF200 |
| Resident budget | 0x200 (512B) | 0x600 (1536B) |
| Total image | 4096 | 4096 (fixed) |

SNIOS standalone: jt 24B + body 436B + data 3B = 463B.

## Verification

- `make cpnos` builds clean (all asserts satisfied, 4KB image).
- `make cpnos-netboot` **PASSes** in MAME:
  - PROM-disable sentinel `A5 5A` at `0x0000` intact after boot.
  - FNC=3 RET byte `C9` lands at `0xDF80`.
  - BIOS jt at `0xF200` (17 JPs); SNIOS jt at `0xF233` (8 JPs).
  - CFGTBL at `0xF4B3` shows SLAVEID=`0x70`, SID=`0xFF`, FNC=`5`.
  - Display shows `CPNOS` banner.

SNIOS wire protocol itself is **not yet tested end-to-end** — the
netboot smoke test just verifies the resident layout and data. A
cpnet/server.py round-trip against SNIOS on cpnos-rom is the next
protocol-level validation step.

## Issues raised

Appended to `rcbios-in-c/tasks/cpnos-issues.md` under "Session 24"
heading — NDOS/BIOS collision, SNIOS-to-NDOS wiring, drain timeout,
CHKACK 7-bit mask, protocol test, naming convention, stack vs netboot
DMA range.

## Next step

Per Phase 1 plan, after SNIOS lands: wire SNIOS into the cold-boot
handoff so NDOS knows where to find it, extend `netboot_server.py` /
`cpnet/server.py` to ship a real NDOS image, then run the wire
protocol round-trip.
