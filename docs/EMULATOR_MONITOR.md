# RC700 Emulator Monitor Reference

Source: `/Users/ravn/git/rc700/monitor.c` (Z80SIM ICE-type monitor by Udo Munk, modified by Michael Ringgaard)
Emulator docs: https://www.jbox.dk/rc702/emulator.shtm

## Entering the Monitor

Launch emulator with `-monitor` flag. Press **F10** to enter monitor (prompt: `>>>`).
Without `-monitor`, F10 exits the emulator.

## Commands

### Memory

| Command | Description |
|---------|-------------|
| `d [addr]` | Dump 256 bytes (16x16) as hex + ASCII. Continues from last address if no addr given. |
| `l [addr]` | Disassemble 10 instructions. Continues from last address if no addr given. |
| `m [addr]` | Modify memory interactively. Shows `addr = val :`, enter new hex value or ENTER to advance. Non-hex input exits. |
| `f addr,count,value` | Fill `count` bytes starting at `addr` with `value`. |
| `v from,to,count` | Move (copy) `count` bytes from `from` to `to`. |

### File Loading (`r`)

| Command | Description |
|---------|-------------|
| `r file,addr` | Load binary file at `addr`. |
| `r file` | Auto-detect format and load. |

**Format auto-detection** (first byte of file):
- `0xFF` -> **Mostek format**: bytes 1-2 are load address (lo,hi). Data follows. Sets PC to load address.
- `:` -> **Intel hex format**: standard `:llaaaattddcc` records. Type 0 = data, type 1 = EOF. Sets PC from EOF record address.
- Otherwise -> **Raw binary**: loads at specified address, or 0x0100 (CP/M TPA) if no address given.

All formats print load statistics (start, end, byte count).

### Execution Control

| Command | Description |
|---------|-------------|
| `g [addr]` | Run from `addr` (or current PC). Runs until breakpoint, HALT, or error. |
| `t [count]` | Trace `count` instructions (default 20) with full register dump per step. |
| ENTER (empty) | Single step one instruction. Shows registers and disassembly. |

### Registers (`x`)

| Command | Description |
|---------|-------------|
| `x` | Display all registers (PC, A, flags, I, IFF, BC, DE, HL, alt set, IX, IY, SP). |
| `x reg` | Modify register. Shows current value, prompts for new hex value. |

**Register names**: `a`, `f`, `b`, `c`, `d`, `e`, `h`, `l`, `i`, `bc`, `de`, `hl`, `ix`, `iy`, `sp`, `pc`
**Alternate registers**: `a'`, `f'`, `b'`, `c'`, `d'`, `e'`, `h'`, `l'`, `bc'`, `de'`, `hl'`
**Individual flags**: `fs` (sign), `fz` (zero), `fh` (half-carry), `fp` (parity), `fn` (N), `fc` (carry)

### I/O Ports

| Command | Description |
|---------|-------------|
| `p addr` | Show port value via `cpu_in(addr)`, prompt for new value to `cpu_out(addr,val)`. |

### Breakpoints (`b`)

Requires compile-time `SBSIZE` define. Software breakpoints replace opcodes with HALT (0x76).

| Command | Description |
|---------|-------------|
| `b` | List all breakpoints (number, address, pass count, current counter). |
| `b addr` | Set breakpoint at `addr`, auto-assigned number, pass count = 1. |
| `b addr,pass` | Set breakpoint at `addr`, triggers after `pass` hits. |
| `b0 addr` | Set breakpoint #0 at `addr` (explicit number 0-9). |
| `b0 c` | Clear breakpoint #0. Restores original opcode. |

### History (`h`)

Requires compile-time `HISIZE` define. Records PC + all registers for each executed instruction.

| Command | Description |
|---------|-------------|
| `h` | Show full history (AF, BC, DE, HL, IX, IY, SP per instruction). Pages at 20 lines. |
| `h addr` | Show history starting from `addr`. |
| `h c` | Clear history. |

### T-State Counting (`z`)

Requires compile-time `ENABLE_TIM` define.

| Command | Description |
|---------|-------------|
| `z start,stop` | Set trigger: count T-states while PC is between `start` and `stop`. |
| `z` | Show current T-state count and trigger addresses. |

### Disk Operations

| Command | Description |
|---------|-------------|
| `M file[,drive]` | Mount disk image `file` on `drive` (0-3, default 0). Calls `fdc_mount_disk()`. |
| `S` | Swap disk drives (drive 0 <-> drive 1). Calls `fdc_swap_disks()`. |

### Other

| Command | Description |
|---------|-------------|
| `n` | Dump screen buffer (calls `dump_screen()`). |
| `c` | Measure CPU clock frequency (runs tight JP loop for 3 seconds, computes MHz from R register). |
| `s` | Show compile-time settings (history size, breakpoint count, stack/PC overflow checking, T-state support). |
| `?` | Show help summary. |
| `q` | Quit monitor (exits emulator). |

## All Addresses are Hexadecimal

The monitor parses all numeric inputs as **hexadecimal** (no `0x` prefix needed). E.g., `d 900` dumps from 0x0900, `r file,d480` loads at 0xD480.

## BIOS Patching Workflow

SYSGEN buffers the **full** CP/M system (CCP+BDOS+config+INIT+BIOS) at LOADP=0x0900, not just the BIOS.
Mini=68 pages (17KB), maxi=107 pages (27KB). The .cim file only contains INIT+BIOS (~6KB).

1. Boot CP/M, run `SYSGEN`, read from source drive A (full system -> 0x0900)
2. At destination prompt, press F10
3. `r /path/to/zout/BIOS.cim,900` — patches INIT+BIOS at start of buffer
4. `g` to resume, specify destination drive

## CPU Error Codes

The monitor reports these after execution stops:
- **OPHALT** — HALT opcode reached (not a breakpoint)
- **IOTRAP** — I/O trap
- **OPTRAP1/2/4** — Unimplemented opcode (1/2/4 byte)
- **USERINT** — User interrupt (Ctrl+C or timer)
