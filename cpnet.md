# CP/NET for RC702

## Goal

Run CP/NET client on RC702 CP/M over SIO Channel A serial port,
talking to a CP/NET server on macOS host. Channel A runs at 38400 baud 8-N-1
(CTC divisor 1, x16 clock mode) — the fastest 8-bit clean setting.

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

### DI analysis in the FDC code path (FLOPPY.MAC)

The floppy driver has three DI sections. Two are strictly necessary; one is
conservative and could be removed to reduce the interrupt blackout window:

| Location | Duration | Necessary? | Reason |
|----------|----------|------------|--------|
| CLFIT (742) | ~5µs | Yes | Atomic clear of FL_FLG — prevents race with FLITR ISR |
| FLPR/FLPW (763-786) | ~50µs | Yes | 8237 DMA byte pointer flip-flop is shared across all channels. DSPITR (display ISR) programs channels 2/3 — if it fires mid-setup, the flip-flop state is corrupted and address bytes go to the wrong register |
| GNCOM (790-828) | ~175µs | No (cautious) | Sends 9-byte command to µPD765 FDC. The FDC waits patiently in command phase (no timeout between parameter bytes). ISRs all save/restore registers. No ISR touches the FDC. The original programmer was being defensively correct |

The **actual disk data transfer** uses DMA with interrupts enabled — `WATIR`
(line 758) polls FL_FLG with EI. The ring buffer ISR fires normally during
data movement. DI is only during command setup.

At 1200 baud (original default), a character arrives every 8.3ms — these DI
periods are utterly invisible. At 19200 (rel.2.2), 520µs per character, still
fine. At 38400, one character per 260µs — the combined DI (~230µs) is tight
but should fit within the 3-byte SIO hardware FIFO.

**MAME z80sio.cpp FIFO verification**: MAME correctly emulates the 3-byte
receive FIFO (`m_rx_data_fifo` is a `uint32_t` with 3 packed bytes; overrun
detected at `m_rx_fifo_depth == 3`, line 2295). So the data loss in testing
is genuine, not a MAME simplification.

**Why 74% loss exceeds predictions**: The simple DI analysis above only counts
explicit DI instructions in FLOPPY.MAC. But the Z80 also disables interrupts
during ISR execution (IFF cleared on interrupt acknowledge, restored by EI
before RETI). The DSPITR display ISR fires every ~20ms and runs for ~125µs
with interrupts off. When DSPITR coincides with FDC DI periods, the combined
blackout can exceed the FIFO capacity. Additionally, PIP processes received
data in a loop that may include multiple BIOS calls per buffer fill, and each
RWOPER→WRTHST→SECWR sequence involves CLFIT+FLPW+GNCOM DI blocks plus
potential DSPITR overlap. The cumulative effect across hundreds of sector
writes explains the severe loss.

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
- Default serial format: 38400 8-N-1 on SIO Ch.A (CTC count=1, WR4=44h)
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
38400 8-N-1 (INIPARMS.MAC: CTC count=1, WR4=44h, WR3=C1h) — the fastest
8-bit clean setting the hardware permits. The null_modem baud rate must be
set to match.

**Method: Lua autoboot script** (reliable, tested)

Use `-autoboot_script` with a Lua script that sets baud rate via
`field.user_value` and types the CP/M command:

```lua
-- set_38400.lua — set null_modem to 38400 and type PIP command
local ports = manager.machine.ioport.ports
for tag, port in pairs(ports) do
    if tag:find("RS232_TXBAUD") or tag:find("RS232_RXBAUD") then
        for name, field in pairs(port.fields) do
            field.user_value = 0x0b  -- RS232_BAUD_38400
        end
    end
end

local typed = false
emu.register_periodic(function()
    if not typed and manager.machine.time.seconds >= 10 then
        typed = true
        manager.machine.natkeyboard:post("pip con:=rdr:\r")
        return false  -- unregister callback
    end
end)
```

The Lua `field.user_value` setter calls `set_user_settings()` internally,
which updates `live().value` and triggers the device callback. The plain
`field:set_value()` does NOT work for CONFIG ports (it only sets a boolean
digital value).

Note: `-autoboot_script` and `-autoboot_command` are mutually exclusive —
the script must handle both baud rate and keyboard input.

**Alternative: Tab menu** (manual, per-session)

Press Tab during emulation → Machine Configuration → TX Baud / RX Baud →
change both to 38400.

**Note on cfg files**: MAME's cfg file format supports `<port>` tags with
`type="TYPE_OTHER(6,0)"` for CONFIG ports, but in practice these settings
are not reliably applied for slot device ports like null_modem. Use the
Lua script method instead.

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
    -skip_gameinfo -window -nomaximize \
    -autoboot_script /tmp/set_38400.lua
```

The Lua script sets the baud rate and types `pip con:=rdr:` after 10 seconds.
To run a different CP/M command, edit the `natkeyboard:post()` line in the
script. Without `-autoboot_script`, use `-autoboot_command` instead (but then
the null_modem stays at 9600 — only works if BIOS is also set to 9600).

**Step 4: In CP/M** (if not using autoboot)

Receiving (host → CP/M):
```
A>pip con:=rdr:          (display received text on screen)
A>pip file.txt=rdr:      (save to disk — text, Ctrl-Z terminated)
A>pip file.hex=rdr:      (save Intel HEX to disk)
A>load file              (convert FILE.HEX → FILE.COM)
```

Sending (CP/M → host):
```
A>pip pun:=file.asm[z]   (send file to host, [z] appends Ctrl-Z)
```

Text files terminate on Ctrl-Z (0x1A). Binary files can be transferred
directly over the 8-N-1 link, or converted to Intel HEX format on the
host (pure 7-bit ASCII: `:0-9A-F\r\n`) and restored with CP/M's LOAD.COM.

For receiving on the host side, use a TCP server that saves incoming data:
```python
#!/usr/bin/env python3
# serial_receiver.py — receive file from CP/M via MAME null_modem
import socket, sys
port = int(sys.argv[1]) if len(sys.argv) > 1 else 4321
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind(('localhost', port))
server.listen(1)
conn, _ = server.accept()
data = bytearray()
while True:
    chunk = conn.recv(1024)
    if not chunk:
        break
    data.extend(chunk)
    if 0x1a in chunk:  # Ctrl-Z = end of file
        break
conn.close()
server.close()
# Strip leading nulls (SIO transmits zeros before PIP starts sending)
content = data.lstrip(b'\x00')
ctrlz = content.find(0x1a)
if ctrlz >= 0:
    content = content[:ctrlz]
with open(sys.argv[2] if len(sys.argv) > 2 else '/tmp/received.txt', 'wb') as f:
    f.write(content)
print(f"Received {len(content)} bytes")
```

### Tested configurations

| Config | Result |
|--------|--------|
| 9600 8-N-1, 60 bytes, `pip con:=rdr:` | 3 lines displayed correctly |
| 9600 8-N-1, 5701 bytes (100 lines), `pip con:=rdr:` | All 100 lines received, no data loss |
| 9600 8-N-1, 1141 bytes (20 lines), ring buffer dump | Both ring buffers verified (see below) |
| 38400 8-N-1, 5701 bytes (100 lines), `pip con:=rdr:` | All lines received correctly (host → CP/M) |
| 38400 8-N-1, 19443 bytes, `pip pun:=filex.asm[z]` | Byte-identical match (CP/M → host) |
| 38400 8-N-1, 51000 bytes, round-trip disk test | **74% data loss** — see below |
| Socket connection via `socket.localhost:PORT` | Works — non-blocking reads via POSIX `select()` |

### Disk-backed round-trip test results

Sent 51000 bytes (750 lines + 256 trailing Ctrl-Z) from host → CP/M disk →
host at 38400 8-N-1. PIP commands: `pip test.dat=rdr:` then `pip pun:=test.dat[z]`.

| Metric | Value |
|--------|-------|
| Sent | 51000 bytes content |
| Received back | 13014 bytes (stripped 40 leading nulls) |
| Data loss | 74% (37986 bytes) |
| First corruption | byte 337 (~line 5) — SIO FIFO overflow during FDC disk write |
| Ctrl-Z termination | Worked (256 trailing Ctrl-Z bytes — PIP terminates on first) |

**Root cause**: `DI` during FDC operations (seek, read, write) prevents the
RCA ISR from firing. At 38400 baud, the SIO's 3-byte hardware FIFO overflows
in ~0.8 ms. Data lost during DI is permanently gone — the ring buffer can only
help between DI periods.

**Key insight**: PIP saves the file with embedded corruption. When sent back
with `pip pun:=file[z]`, PIP stops at the first embedded Ctrl-Z (0x1A) in the
corrupted data, so the received-back file is truncated to the first uncorrupted
segment plus some garbled bytes.

**Workaround**: Use multiple trailing Ctrl-Z bytes (256) in the send file.
A single Ctrl-Z can be lost during DI, causing PIP to never terminate.

**Conclusion**: Reliable disk-backed serial transfer at 38400 requires
RTS flow control (drop RTS before DI, re-assert after EI) — see the
"Future: automatic RTS flow control" section above. Memory-only transfers
(`pip con:=rdr:`) work perfectly at any baud rate.

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
