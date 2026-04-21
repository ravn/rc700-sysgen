# RC702 CP/NET with z80pack MP/M Server

## Overview

The RC702 (emulated in MAME) connects as a CP/NET 1.2 slave to a z80pack
MP/M II CP/NET server over TCP. This enables the RC702 to access MP/M
server drives as network drives (e.g., `H:` mapped to server `B:`).

## Architecture

```
┌─────────────────────────┐         TCP          ┌─────────────────────────┐
│  MAME RC702             │    localhost:4002     │  z80pack MP/M II        │
│                         │◄────────────────────►│                         │
│  CP/M 2.2 + NDOS        │   DRI binary serial   │  NETWRKIF RSP           │
│  SNIOS.SPR (SIO Ch.A)   │   ENQ/ACK framing     │  Console 3 (ports 44/45)│
│  C-BIOS (38400 baud)    │                       │  TCP listener on 4002   │
└─────────────────────────┘                       └─────────────────────────┘
```

**Connection path (MAME side):**
```
CP/M program (e.g., DIR H:)
  → NDOS intercepts BDOS call for network drive
  → SNIOS SNDMSG/RCVMSG (DRI binary framing)
  → BIOS PUNCH/READER (SIO Ch.A hardware)
  → MAME null_modem device
  → TCP client → localhost:4002
```

**MAME null_modem flags:**
```
-rs232a null_modem -bitb "socket.localhost:4002"
```

MAME connects as a TCP **client** to port 4002. The MP/M server must
already be listening before MAME starts.

## Protocol

Standard DRI CP/NET 1.2 binary serial protocol:

```
Client → Server:  ENQ → [ACK] → SOH HDR(5) HCS → [ACK] → STX DATA ETX CKS EOT → [ACK]
Server → Client:  ENQ → [ACK] → SOH HDR(5) HCS → [ACK] → STX DATA ETX CKS EOT → [ACK]
```

- Header: FMT(1) DID(1) SID(1) FNC(1) SIZ(1) — SIZ=0 means 1 data byte
- Checksum: two's complement of byte sum (single byte)
- Slave ID: 0x01

The z80pack MP/M server speaks this protocol natively on its CP/NET
console port (TCP 4002). No protocol translation is needed.

## Boot Sequence

The CP/NET connection requires three commands in order:

1. **`CPNETLDR`** — Loads SNIOS.SPR and NDOS.SPR, patches BDOS vector
2. **`LOGIN PASSWORD`** — Authenticates with the MP/M server (required!)
3. **`NETWORK H:=B:`** — Maps local drive H: to server drive B:

Without `LOGIN PASSWORD`, all subsequent CP/NET operations fail with
`NDOS Err 0C, Func 0E` (network error on Select Disk). The MP/M server
rejects requests from unauthenticated slaves.

## Quick Start

### Prerequisites

- z80pack MP/M with CP/NET server running, TCP listener on port 4002
- z80pack MP/M consoles on ports 4000 and 4001
- MAME regnecentralen subtarget built
- Reference disk image: `~/Downloads/SW1711-I8.imd`
- CP/NET binaries: `~/git/cpnet-z80/dist/`

### Launch

```bash
cd rc700-sysgen
bash cpnet/run_test.sh --no-server --inject
```

This will:
1. Create fresh disk from reference image
2. Build SNIOS.SPR (RC702 DRI binary serial, BIOS READER/PUNCH I/O)
3. Build and patch C-BIOS (38400 baud, maxi 8" format)
4. Inject all CP/NET utilities from `cpnet-z80/dist/` onto A:
5. Create `$$$.SUB` for auto-boot: CPNETLDR → LOGIN PASSWORD → NETWORK H:=B: → DIR H:
6. Launch MAME connecting to localhost:4002
7. Take a screenshot at 25 seconds (`/tmp/mame_cpnet.png`)

### Manual Operation

If not using `--inject`, boot MAME and type:
```
A>CPNETLDR
A>LOGIN PASSWORD
A>NETWORK H:=B:
A>DIR H:
```

## run_test.sh Flags

| Flag | Description |
|------|-------------|
| `--no-server` | Skip launching built-in `server.py`; connect to external server |
| `--inject` | Inject CP/NET files onto disk with cpmtools3 (vs hex serial transfer) |
| `--fast` | Run MAME at full speed (`-nothrottle`) |
| `--setup` | Use setup.lua (auto-types CPNETLDR/NETWORK, then hands control to user) |
| `--auto` | Fully automated test with autotest.lua |
| `--console` | Remote console mode (server.py foreground for raw terminal I/O) |
| `--gdb` | Launch MAME with gdbstub for Z80 debugging |

For z80pack MP/M testing, the typical invocation is:
```bash
bash cpnet/run_test.sh --no-server --inject [--fast]
```

## Verified Operations

- `CPNETLDR` — loads CP/NET 1.2 (SNIOS at C900h, NDOS at BD00h)
- `LOGIN PASSWORD` — authenticates with MP/M server
- `NETWORK H:=B:` — maps network drive
- `DIR H:` — lists server directory contents
- File access on mapped network drives

## Troubleshooting

### NDOS Err 0C, Func 0E
Missing `LOGIN PASSWORD` before `NETWORK`. The MP/M server requires
authentication. Error 0C = network error, Func 0E = Select Disk.

### MAME doesn't connect
MAME's bitbanger (`socket.localhost:PORT`) connects as a TCP client at
startup. The server must be listening **before** MAME launches. If the
connection fails, MAME continues silently without serial connectivity.

### Killing MAME
The MAME binary is `regnecentralend` (or `regnecentralen`), not `mame`.
Regular `kill` may be ignored; use `kill -9` or quit from the MAME window
(Cmd-Q).

### Baud rate
The Lua autoboot script sets MAME's null_modem to 38400 baud. This must
match the C-BIOS SIO configuration. The z80pack TCP port is baud-rate
agnostic (raw TCP), so only the MAME side matters.

## z80pack MP/M Server Setup

### Disk image provenance

The prebuilt MP/M II + CP/NET server disk pack is **not** on the
modern z80pack GitHub repo — it has to be fetched from Udo Munk's
cpmarchives mirror:

    http://cpmarchives.classiccmp.org/cpm/mirrors/www.unix4fun.org/z80pack/ftp/mpm-net-1.2.tgz

Local copy: `~/Downloads/mpm-net-1.2.tgz` (242 659 B, gzip 2008-07-05).
Unpacks to:
    mpm-net2                        (launcher: `./cpmsim` with drives a/b
                                     linked to mpm-net2-1/2.dsk)
    disks/library/mpm-net2-1.dsk    (256 256 B)
    disks/library/mpm-net2-2.dsk    (256 256 B)

Referred from the index page
`http://cpmarchives.classiccmp.org/cpm/mirrors/www.unix4fun.org/z80pack/index.html`.
The tarball is stamped 2008; the `mpm-net2` launcher inside is
2007-12-07.  These disks have been successfully used with the ravn
z80pack fork in session 28-ish work (see `MPMNET_ANALYSIS.md`).

### Installation into `z80pack/cpmsim/` submodule (session 32, 2026-04-21)

1. Build `srctools/` (`cd z80pack/cpmsim/srctools && make`).  Without
   `cpmrecv` on the path or in `./srctools/`, cpmsim does `kill(SIGQUIT)`
   on itself at startup (simio.c:427-428).
2. Copy prebuilt disks + launcher:
   ```
   cp ~/Downloads/mpm-net-1.2/disks/library/mpm-net2-{1,2}.dsk \
      z80pack/cpmsim/disks/library/
   cp ~/Downloads/mpm-net-1.2/mpm-net2 z80pack/cpmsim/
   ```
3. Patch the launcher: the 2007 tarball uses `.cpm` extensions; modern
   cpmsim wants `.dsk`.  Sed or hand-edit both `ln` lines.
4. Write `conf/net_server.conf` (consoles 1-4 on ports 4000-4003).
5. Inject `$$$.SUB` with "MPMLDR" as the only command, so CP/M 2.2
   auto-loads MP/M II on boot:
   ```
   python3 -c "
   cmd=b'MPMLDR'; rec=bytes([len(cmd)])+cmd+b'\0'*(127-len(cmd))
   open('/tmp/sub.bin','wb').write(rec)"
   cpmcp -f ibm-3740 disks/library/mpm-net2-1.dsk /tmp/sub.bin '0:$$$.SUB'
   ```
   Disk format is **ibm-3740** (77 × 26 × 128 = 256 256 B, SSSD 8").
6. Run `./mpm-net2`.  Expect banner sequence: Z80SIM → CP/M 2.2 →
   CCP reads `$$$.SUB` → `MPMLDR` → MP/M II V2.0 → `0A>` prompt on
   console 0; TCP 4002 open for CP/NET slaves.

Full run verified 2026-04-21: `MP/M 2 XIOS V1.6-NET for Z80SIM`
banner, `SERVR0PRRSP` + `NtwrkIP0RSP` both resident.

**Note:** the submodule's `srcmpm/netwrkif-2.asm:939-946` still has
the buggy CONIN-address calculation documented in `MPMNET_ANALYSIS.md`.
The 2007-vintage prebuilt disks apparently side-step the bug somehow
(either via a different netwrkif variant, or a patched MP/M build that
was never upstreamed).  If we ever rebuild the disks from submodule
sources we'll need to port the fix; for now, just use the prebuilt
tarball.

See `MPMNET_ANALYSIS.md` for z80pack bugs that needed fixing:
- **NETWRKIF nwinit** — incorrect CONIN address calculation (crashes MP/M)
- **GENSYS TMPs** — must be 5 (matching XIOS NMBCNS), not 2
- **TCPASYNC** — disable in sim.h (macOS SIGIO unreliable)

## Files

| File | Purpose |
|------|---------|
| `cpnet/run_test.sh` | Test orchestration script |
| `cpnet/snios.asm` | RC702 SNIOS — DRI binary serial via BIOS READER/PUNCH |
| `cpnet/build_snios.py` | Builds relocatable SPR from assembled SNIOS |
| `cpnet/server.py` | Standalone Python CP/NET server (alternative to MP/M) |
| `cpnet/cpnet12_client.py` | Python test client for probing CP/NET servers |
| `cpnet/MPMNET_ANALYSIS.md` | z80pack MP/M bug analysis and fixes |
| `cpnet/DRI_PROTOCOL.md` | DRI binary serial protocol specification |
| `cpnet/CPNET_SYSTEM.md` | CP/NET system architecture guide |
