# CP/NET for RC702

## Goal

Run CP/NET client on RC702 CP/M over SIO Channel A serial port,
talking to a CP/NET server on macOS host. Channel A runs at 38400 baud
(CTC divisor 1, x16 clock mode) — the maximum the hardware permits.

## Architecture

```
RC702 (CP/M 2.2)                    macOS host
+------------------+                 +------------------+
| Application      |                 |                  |
| NDOS.SPR         |  serial link    | CP/NET server    |
| SNIOS.SPR (RC702)|<--------------->| (Java or C)      |
| BDOS / BIOS      |  SIO Ch.A      | Host filesystem  |
+------------------+  (38400 baud)   +------------------+
```

## CP/NET Components

### Client side (runs on CP/M)
- **NDOS.SPR** — Network Disk Operating System, intercepts BDOS calls
- **SNIOS.SPR** — Slave Network I/O System (hardware-specific, must be written for RC702 SIO)
- **CCP.SPR** — Modified CCP with network commands
- **CPNETLDR.COM** — Loader: reads NDOS+SNIOS, relocates below BDOS, patches entry at 0005h
- **Utilities**: LOGIN.COM, LOGOFF.COM, NETWORK.COM, LOCAL.COM, CPNETSTS.COM

### Server side (runs on macOS)
- **CpnetSerialServer.jar** (Java) or **cpnet-server** (C) — see below
- Maps CP/M drives A-P to host directories
- Handles all BDOS function forwarding

### SNIOS for RC702
Must provide 8 jump table entries: NTWKIN, NTWKST, CNFTBL, SNDMSG, RCVMSG, NTWKER, NTWKBT, NTWKDN.

The actual serial I/O is just 4 routines (`chrio.asm`):
- `check` — init UART, verify present
- `sendby` — transmit one byte (poll TX empty, write)
- `recvby` — receive one byte with timeout (poll RX ready, read)
- `recvbt` — receive with longer initial timeout

For RC702: use SIO Channel A (ports 08h/0Ah) — the channel with the ring buffer
and BIOS READER/PUNCH assignment. The SNIOS can either call BIOS READER/PUNCH
entry points or drive the SIO directly for better performance.

**Closest reference**: Kaypro SNIOS in durgadas311/cpnet-z80 (also Z80-SIO).

### DRI Serial Protocol (Appendix E)
```
Requester sends ENQ → Server replies ACK
Header:  SOH FMT DID SID FNC SIZ HCS → ACK
Data:    STX data[0..n] ETX → ACK
Trailer: DCS EOT → ACK
```
Checksum: two's complement of sum of block bytes.

## Software Sources

### CP/NET client files
| Source | URL |
|--------|-----|
| DRI binaries (CP/NET 1.1 + 1.2) | http://www.cpm.z80.de/binary.html |
| DRI source (disassembly) | http://www.cpm.z80.de/source.html |
| hperaza client files (1.1 + 1.2) | https://github.com/hperaza/cpnet-server/tree/master/cpmfiles |
| durgadas311 full distribution | https://github.com/durgadas311/cpnet-z80 |
| CP/NET reference manual (PDF) | http://sebhc.durgadas.com/mms89/docs/dri-cpnet.pdf |
| Humongous CP/M Archive | https://archive.org/details/Humongous_CPM_Archive_Collection |

### CP/NET server implementations
| Project | Language | URL | Notes |
|---------|----------|-----|-------|
| durgadas311/cpnet-z80 | Java | https://github.com/durgadas311/cpnet-z80 | CpnetSerialServer.jar, supports DRI + BINARY protocols, macOS/Linux/Windows |
| hperaza/cpnet-server | C | https://github.com/hperaza/cpnet-server | Unix server, DRI protocol, CP/NET 1.1 + 1.2 |
| cm68/cpnet | C | https://github.com/cm68/cpnet | RomWBW/Z180, serial-over-WiFi |

### SNIOS reference implementations (Z80-SIO)
| Platform | Location |
|----------|----------|
| Kaypro (Z80-SIO) | durgadas311/cpnet-z80 `src/kaypro/` |
| RC2014 (Z80-SIO) | durgadas311/cpnet-z80 `src/rc2014/` |
| SC131 (Z180-SIO) | durgadas311/cpnet-z80 `src/sc131/` |
| DRI serial protocol | durgadas311/cpnet-z80 `src/ser-dri/snios.asm` |

## Alternative File Transfer (simpler, no CP/NET)

| Method | Effort | Notes |
|--------|--------|-------|
| PIP via RDR:/PUN: | Zero | Built into CP/M. Text only (Ctrl-Z terminated). BIOS RDR/PUN already mapped to SIO Ch.A. |
| Kermit-80 (generic) | Low | Works on any CP/M, no hardware-specific code. ~1 KB/s. https://www.columbia.edu/kermit/cpm.html |
| xmodem80 | Low | Uses CON: device, no UART code. https://github.com/SmallRoomLabs/xmodem80 |
| CP/NET | High | Full network filesystem, requires custom SNIOS |

## Version Compatibility Warning

CP/NET 1.0, 1.1, and 1.2 are **NOT wire-compatible**. Client and server must match.
The durgadas311 Java server supports multiple versions.

## Receive Buffering — Implemented in BIOS rel. 3.0

### Problem (original BIOS)

The original BIOS loses incoming serial characters when the CPU is busy:

- Z80 SIO has only a **3-byte receive FIFO**
- BIOS disables interrupts (`DI`) during FDC operations (seek, read, write)
- FDC operations take many milliseconds — at 38400 baud, ~3840 chars/sec,
  the 3-byte FIFO overflows in ~0.8 ms
- Original RCA ISR stored one character in a single-byte variable (CHARA);
  a second character arriving before READER is called overwrites the first

### Solution: ring buffers in BIOS rel. 3.0

BIOS rel. 3.0 (`-DREL30`) adds two ring buffers (see `rcbios/src/`):

**SIO Channel A** (serial READER/PUNCH):
- 256-byte page-aligned ring buffer at F400h (RXBUF)
- RCA ISR stores received character at RXBUF[RXHEAD], advances head
- READS checks RXTAIL != RXHEAD (returns 0 if empty, 0FFh if data)
- READER reads from RXBUF[RXTAIL], advances tail
- Overflow guard: if buffer full, incoming character is discarded
- READI called at BOOT to arm RTS/DTR and enable receive interrupts immediately

**PIO Channel A** (keyboard):
- 16-byte ring buffer at F37Fh (KBBUF), wraps with AND 0Fh
- KEYIT ISR reads key from PIO and stores in KBBUF[KBHEAD]
- CONST checks KBTAIL != KBHEAD
- CONIN reads from KBBUF[KBTAIL], then converts through INCONV table
- Overflow guard: if buffer full, keystroke is discarded

### Limitation during DI

Ring buffers don't help during `DI` (FDC operations) — the ISR can't fire,
so characters exceeding the SIO's 3-byte hardware FIFO are still lost.
Mitigations:
- Hardware flow control (RTS/CTS) to pause the sender during disk I/O
- MAME-side buffering between host connection and emulated SIO
- Accept the limitation (real hardware had the same problem)

### Future: automatic RTS flow control

To prevent data loss during DI periods, the BIOS could de-assert RTS before
entering DI (FDC operations) and re-assert it after EI. The SIO's WR5 controls
RTS (bit 1). The MAME null_modem device honours CTS, so dropping RTS would
cause the remote side's CTS to drop, pausing transmission.

Implementation sketch (in FLOPPY.MAC, around FDC read/write):
```z80
; Before DI:
    LD   A,05H
    OUT  (SIOAC),A      ; select WR5
    LD   A,(WR5A)
    ADD  A,88H          ; DTR=on, RTS=OFF, TX enable
    OUT  (SIOAC),A      ; drop RTS → sender pauses
    DI
    ... FDC operation ...
    EI
    CALL READI           ; re-arms RTS, DTR, RX interrupts
```

Not yet implemented — deferred until basic serial transfer is tested.

### Other REL30 changes
- RCB ISR (Channel B receive) removed — dead code, Ch.B receiver is never enabled
  (printer port is output-only). IVT entry points to DUMITR.
- Default baud rate: 38400 on SIO Ch.A (CTC count=1, max with x16 clock)
- SPECA (special receive error) resets ring buffer pointers instead of CHARA/RDRFLG

## MAME rc702.cpp — Serial Ports Wired

Both SIO channels are now connected to rs232 port devices in MAME:

```
SIO Channel A ("rs232a") — BIOS READER/PUNCH — serial I/O for CP/NET
SIO Channel B ("rs232b") — BIOS LIST — printer output
```

Each channel has TXD/RTS/DTR output callbacks and RXD/CTS input handlers.

### MAME serial testing procedure

The null_modem device with a TCP socket bitbanger is the practical way to
test serial I/O. MAME connects as a TCP client; a host-side Python script
acts as the server.

**Step 1: Configure null_modem baud rate**

The null_modem defaults to 9600 8-N-1. The BIOS rel. 3.0 SIO defaults to
38400 7-E-1 (INIPARMS.MAC: CTC count=1, WR4=47h, WR3=61h). These must
match. Override via MAME cfg file (`cfg/rc702.cfg`) inside `<system>`:

```xml
<port tag=":rs232a:null_modem:RS232_TXBAUD" type="TYPE_OTHER(6,0)" mask="255" defvalue="7" value="11" />
<port tag=":rs232a:null_modem:RS232_RXBAUD" type="TYPE_OTHER(6,0)" mask="255" defvalue="7" value="11" />
<port tag=":rs232a:null_modem:RS232_DATABITS" type="TYPE_OTHER(6,0)" mask="255" defvalue="3" value="2" />
<port tag=":rs232a:null_modem:RS232_PARITY" type="TYPE_OTHER(6,0)" mask="255" defvalue="0" value="2" />
```

Values: TXBAUD/RXBAUD 11=38400, DATABITS 2=7-bit, PARITY 2=even.
Type `TYPE_OTHER(6,0)` is MAME's internal token for `IPT_CONFIG` ports.
Alternatively, change settings at runtime via Tab → Machine Configuration.

**Step 2: Start host-side TCP server**

```python
#!/usr/bin/env python3
# serial_server.py — send file to CP/M via MAME null_modem
import socket, sys, time
port, delay = 4321, 15.0
filename = sys.argv[1] if len(sys.argv) > 1 else '/tmp/testfile.txt'
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind(('localhost', port))
server.listen(1)
print(f"Listening on port {port}...")
conn, addr = server.accept()
print(f"Connected. Waiting {delay}s for CP/M to boot...")
time.sleep(delay)  # wait for CP/M boot + PIP to start
with open(filename, 'rb') as f:
    data = f.read()
print(f"Sending {len(data)} bytes...")
for byte in data:
    conn.send(bytes([byte]))
    time.sleep(0.002)  # ~500 bytes/sec pacing
print("Done.")
time.sleep(5)
conn.close()
server.close()
```

The delay (15s) ensures data arrives after CP/M has booted and PIP is
waiting. MAME's bitbanger socket uses non-blocking `select()`, so no
data loss from timing — the null_modem simply polls and finds nothing
until the server starts sending.

**Step 3: Launch MAME**

```bash
cd ~/git/mame
./regnecentralend rc702 -rs232a null_modem \
    -bitb "socket.localhost:4321" \
    -flop /tmp/cpm22_rel30_maxi.imd \
    -skip_gameinfo -window -nomaximize
```

**Step 4: In CP/M**

```
A>pip con:=rdr:          (display received text on screen)
A>pip file.hex=rdr:      (save to disk — use Intel HEX for binary files)
A>load file              (convert FILE.HEX → FILE.COM)
```

Text files terminate on Ctrl-Z (0x1A). For binary transfer, convert to
Intel HEX format on the host (pure 7-bit ASCII: `:0-9A-F\r\n`), which
passes cleanly through the 7-bit even parity link. Use CP/M's LOAD.COM
to convert back to binary.

### Tested configurations

| Config | Result |
|--------|--------|
| 9600 8-N-1, 60 bytes, `pip con:=rdr:` | 3 lines displayed correctly |
| 9600 8-N-1, 5701 bytes (100 lines), `pip con:=rdr:` | All 100 lines received, no data loss |
| 9600 8-N-1, 1141 bytes (20 lines), ring buffer dump | Both ring buffers verified (see below) |
| Socket connection via `socket.localhost:PORT` | Works — non-blocking reads via POSIX `select()` |

Note: `pip con:=rdr:` does not write to disk, so DI periods from FDC
are not exercised. A full stress test with `pip file.hex=rdr:` at 38400
with matching null_modem config is needed to verify ring buffer survival
during disk writes.

### Ring buffer verification (memory dump)

MAME debugger breakpoints on RCA ISR (DDB8) saved memory at F370-F56F
during and after a 20-line (1141-byte) serial transfer at 9600 8-N-1.

**SIO ring buffer (RXBUF F400-F4FF):**
- Mid-transfer: RXHEAD=RXTAIL=0x74 — buffer momentarily empty, READER
  consuming data as fast as it arrives. Buffer contains residual data from
  previous writes (lines 0016-0019), confirming the ring wrapped multiple
  times through the 256-byte buffer.
- Near-end: RXHEAD=0x75, RXTAIL=0x74 — exactly 1 byte pending (0x1A =
  Ctrl-Z EOF). All 20 lines were received and consumed correctly.

**Keyboard ring buffer (KBBUF F37F-F38E):**
- KBHEAD=KBTAIL=0x0E (14) — buffer empty, all keystrokes consumed.
- Buffer contains `pip con:=rdr:\r` (14 chars from autoboot command),
  confirming keyboard ring buffer correctly stores and delivers keystrokes.

### Inspecting ring buffers with MAME debugger

After serial transfer, break into the MAME debugger (tilde key or `-debug`)
and dump the ring buffer memory region:

```
save /tmp/ringbuf.bin,F370,200
```

This saves F370-F56F (512 bytes) covering pointers + KBBUF + gap + RXBUF.

Ring buffer addresses (from BIOS.lst rel.3.0):
```
F37B  RXHEAD    SIO ring buffer write position (0-255)
F37C  RXTAIL    SIO ring buffer read position (0-255)
F37D  KBHEAD    Keyboard ring buffer write position (0-15)
F37E  KBTAIL    Keyboard ring buffer read position (0-15)
F37F  KBBUF     16-byte keyboard ring buffer (F37F-F38E)
F400  RXBUF     256-byte SIO ring buffer (F400-F4FF, page-aligned)
```

Analyze the dump with `/tmp/dump_ringbuf.py`:
```bash
python3 /tmp/dump_ringbuf.py /tmp/ringbuf.bin
```

When PIP has consumed all received data, RXHEAD == RXTAIL (buffer empty).
To catch data mid-flight, set a breakpoint on READER (DCF0):
```
bp DCF0,1,{save /tmp/ringbuf.bin,F370,200; g}
```

### CP/M batch commands via $$$.SUB

CP/M supports batch command execution via a file named `A:$$$.SUB` on disk.
The file contains 128-byte records, each holding a length byte followed by a
command string, padded with zeros. Commands are stored in **reverse order**
(last command first). SUBMIT.COM creates this file; CCP checks for it at
each command prompt.

This could automate multi-step serial transfers:
```
; $$$.SUB contents (reverse order):
; Record 0: "TYPE TEST.TXT"    (executed last)
; Record 1: "PIP TEST.TXT=RDR:" (executed first)
```

## RC702 SIO Hardware Notes

### Channel assignments

| Channel | Ports | BIOS role | Hardware label | Ring buffer |
|---------|-------|-----------|----------------|-------------|
| A | 08h/0Ah | READER/PUNCH | "Printer port" | 256 bytes (REL30) |
| B | 09h/0Bh | LIST | "Terminal port" | — (output only) |

Note: CONFI.COM labels are swapped vs BIOS assignments — its "PRINTER PORT"
menu configures SIO-B (terminal channel) and vice versa.

### Baud rate

- CTC input clock: 0.614 MHz, SIO WR4 x16 mode
- CTC divisor 0x20 = 1200 baud (original default)
- CTC divisor 0x02 = 19200 baud (rel.2.2 default)
- CTC divisor 0x01 = 38400 baud (rel.3.0 default, maximum for async serial)
- **In MAME**: emulated baud rate is artificial — run at max speed the
  emulated hardware permits
