# MAME GDB Stub Remote Debugging

## Setup
- Build MAME with `DEBUG=1` -> produces `regnecentralend` (debug binary)
- Launch: `regnecentralend rc702 -debug -debugger gdbstub -debugger_port 23946 -nothrottle`
- Connect via TCP to `localhost:23946` using GDB RSP protocol
- `run_mame.sh -g` automates this (saves PID to `/tmp/mame_gdb.pid`)

## GDB RSP Protocol Essentials
- Packet format: `$data#XX` where XX is 2-digit hex checksum (sum of bytes mod 256)
- ACK: `+` after each packet received; NACK: `-`
- Initial handshake: client sends `$?#3f`, server responds with stop reason (e.g., `$S05#b8`)

## Critical MAME-Specific Quirks
1. **Must fetch target XML first**: Before `g` (read registers) works, must call:
   `qXfer:features:read:target.xml:0,fff` — MAME checks `m_target_xml_sent` flag
   (source: `mame/src/osd/modules/debugger/debuggdbstub.cpp` line 1116-1117)
2. **CPU must execute first**: Registers return E01 until CPU runs at least one instruction.
   Send `c` (continue), wait ~0.5s, then send Ctrl-C (0x03) to break.
3. **Z80 register order** (from target XML): AF, BC, DE, HL, AF', BC', DE', HL', IX, IY, SP, PC
   Each is 16-bit little-endian hex (4 chars per register).

## Supported Commands
- `g` — read all registers
- `G<hex>` — write all registers
- `m<addr>,<len>` — read memory (hex addr, hex length)
- `M<addr>,<len>:<hex>` — write memory
- `Z0,<addr>,1` — set software breakpoint
- `z0,<addr>,1` — remove breakpoint
- `c` — continue execution
- `s` — single step
- `?` — query stop reason
- 0x03 byte — interrupt (break into debugger)

## Breakpoint Behavior
- When breakpoint hit, MAME sends `$S05#b8` (SIGTRAP)
- PC points to the breakpoint address (before instruction executes)
- Continue with `c` to resume; breakpoint fires again on next hit

## Python Client
- See `rcbios-in-c/gdb_trace.py` for full implementation
- Key classes: `GDBClient` (protocol), trace logic with state machine
- Injects keystrokes via memory writes to KBBUF(0xDC23)/KBHEAD(0xDC33)
