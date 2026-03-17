# CP/NET 1.2 Wire Format: MAME RC702 ↔ z80pack MP/M

## Transport Layer

MAME's null_modem device connects as a TCP client to the z80pack MP/M
CP/NET server. The TCP connection carries raw bytes with no additional
framing — the DRI binary serial protocol provides its own framing.

```
MAME rc702                          z80pack MP/M
  SIO Ch.A hardware                   Console 3 (ports 44/45)
    ↓                                   ↓
  null_modem device                   TCP listener
    ↓                                   ↓
  TCP client ──── localhost:4002 ────► TCP server
```

MAME flags: `-rs232a null_modem -bitb "socket.localhost:4002"`

The TCP connection is baud-rate agnostic (raw TCP). MAME's SIO hardware
emulation adds realistic serial timing (38400 baud), but the z80pack
server sees only raw bytes without timing.

## DRI Binary Serial Framing

Every CP/NET message exchange follows this pattern:

```
Requester                              Responder
    |                                      |
    |── ENQ (0x05) ───────────────────────>|  Request to send
    |<── ACK (0x06) ──────────────────────-|  Go ahead
    |                                      |
    |── SOH FMT DID SID FNC SIZ HCS ─────>|  Header (7 bytes)
    |<── ACK (0x06) ──────────────────────-|  Header OK
    |                                      |
    |── STX data[0..SIZ] ETX CKS EOT ────>|  Data block
    |<── ACK (0x06) ──────────────────────-|  Data OK
    |                                      |
```

After the client sends a request, the server sends a response using
the same framing (server becomes requester, client becomes responder).

### Header Fields (5 bytes)

| Byte | Field | Description |
|------|-------|-------------|
| 0 | FMT | Format: 0x00=request, 0x01=response |
| 1 | DID | Destination node ID (0x00=server) |
| 2 | SID | Source node ID (0x01=client) |
| 3 | FNC | BDOS function number |
| 4 | SIZ | Data length minus 1 (0x00 means 1 byte) |

### Checksums

**Header checksum (HCS):** Two's complement of (SOH + FMT + DID + SID + FNC + SIZ).

**Data checksum (CKS):** Two's complement of (STX + data[0..SIZ] + ETX).

Verification: sum all bytes including the checksum; result must be 0x00.

### SIZ Field

SIZ encodes length as **N-1**: SIZ=0x00 means 1 data byte, SIZ=0xFF
means 256 data bytes. There is always at least 1 data byte. This matches
the Z80 `INC E` idiom in the SNIOS (`INC E ; 0 MEANS 1 BYTE`).

## Observed Wire Trace

Captured via TCP proxy between MAME and z80pack MP/M (2026-03-17).
Annotations show the DRI framing decoded.

### Successful Session (with LOGIN)

```
CPNETLDR runs — no wire traffic (loads SNIOS/NDOS from local disk)

LOGIN PASSWORD — sends BDOS F39 (Access Drive) and F64 (Network Login)

  Client sends LOGIN request (BDOS F39 — Access Drive)

  MAME→SRV:  05                             ENQ
  SRV→MAME:  06                             ACK
  MAME→SRV:  01 00 00 01 27 01 D6          SOH hdr(5) HCS
             FMT=00 DID=00 SID=01 FNC=27(39) SIZ=01
  SRV→MAME:  06                             ACK
  MAME→SRV:  02 02 00 03 F9 04             STX data(2) ETX CKS EOT
             data: 02 00
  SRV→MAME:  06                             ACK

  Server responds:

  SRV→MAME:  05                             ENQ
  MAME→SRV:  06                             ACK
  SRV→MAME:  01 01 01 00 27 01 D5          SOH hdr(5) HCS
             FMT=01 DID=01 SID=00 FNC=27(39) SIZ=01
  MAME→SRV:  06                             ACK
  SRV→MAME:  02 FF 0C 03 F0 04             STX data(2) ETX CKS EOT
             data: FF 0C  ← error! (not logged in yet)
  MAME→SRV:  06                             ACK

  ... LOGIN sends F64 (Network Login) with password ...
  ... server returns success ...

NETWORK H:=B: — sends BDOS F14 (Select Disk)

  MAME→SRV:  05                             ENQ
  SRV→MAME:  06                             ACK
  MAME→SRV:  01 00 00 01 0E 00 F0          SOH hdr(5) HCS
             FMT=00 DID=00 SID=01 FNC=0E(14) SIZ=00
  SRV→MAME:  06                             ACK
  MAME→SRV:  02 01 03 FA 04                STX data(1) ETX CKS EOT
             data: 01 (drive B on server)
  SRV→MAME:  06                             ACK

  Server responds (success):

  SRV→MAME:  05                             ENQ
  MAME→SRV:  06                             ACK
  SRV→MAME:  01 01 01 00 0E 00 EF          SOH hdr(5) HCS
             FMT=01 DID=01 SID=00 FNC=0E(14) SIZ=00
  MAME→SRV:  06                             ACK
  SRV→MAME:  02 00 03 FB 04                STX data(1) ETX CKS EOT
             data: 00  ← success
  MAME→SRV:  06                             ACK
```

### Failed Session (without LOGIN)

Without `LOGIN PASSWORD`, the MP/M server returns error 0x0C for every
BDOS function. The NDOS reports this as `NDOS Err 0C, Func 0E`.

```
Server response data for all functions: FF 0C
  FF = error flag
  0C = error code 12 (unauthenticated / invalid requester)
```

## CP/NET Message Format (Inside DRI Frames)

### Request Messages (Client → Server)

The SNIOS packages NDOS requests into DRI frames. The header FNC field
carries the BDOS function number. The data payload contains the function
parameters (usually starting with the FCB or a drive number).

| FNC | BDOS Function | Data Payload |
|-----|---------------|--------------|
| 0x0E (14) | Select Disk | [drive_number] |
| 0x0F (15) | Open File | [FCB: 33 bytes] |
| 0x10 (16) | Close File | [FCB: 33 bytes] |
| 0x11 (17) | Search First | [FCB: 33 bytes] |
| 0x12 (18) | Search Next | [FCB: 33 bytes] |
| 0x14 (20) | Read Sequential | [FCB: 33 bytes] |
| 0x15 (21) | Write Sequential | [FCB: 33 bytes + 128 bytes DMA] |
| 0x16 (22) | Make File | [FCB: 33 bytes] |
| 0x21 (33) | Read Random | [FCB: 36 bytes] |
| 0x22 (34) | Write Random | [FCB: 36 bytes + 128 bytes DMA] |
| 0x25 (37) | Reset Drive | [drive_vector: 2 bytes] |
| 0x27 (39) | Access Drive | [drive_vector: 2 bytes] |
| 0x40 (64) | Network Login | [password string] |
| 0x41 (65) | Network Logoff | [] |
| 0x46 (70) | Network Status | [] |
| 0xFF | Network Init | [] |
| 0xFE | Network Shutdown | [] |

### Response Messages (Server → Client)

Responses echo the FNC code. The first data byte is the return code
(0x00=success, 0xFF=error). Additional bytes depend on the function.

| FNC | Return Data |
|-----|-------------|
| 0x0E (14) | [rc] — 0x00=OK, 0xFF=error |
| 0x0F (15) | [rc, FCB...] — 0x00=OK with updated FCB |
| 0x11 (17) | [rc, dir_entry...] — 0x00=OK with 32-byte directory entry |
| 0x14 (20) | [rc, data...] — 0x00=OK with 128-byte record |
| 0x40 (64) | [rc] — 0x00=logged in |
| 0xFF | [client_id, server_id, flags] — node assignment |

### Error Response Format

When the server rejects a request:
```
data[0] = 0xFF    (error flag)
data[1] = code    (error code)
```

Known error codes from z80pack MP/M:
| Code | Meaning |
|------|---------|
| 0x0C | Unauthenticated (LOGIN required) |

### Response Header Convention

Responses use FMT=0x01 (vs FMT=0x00 for requests). DID and SID are
swapped: the server's SID becomes the response DID, and vice versa.

```
Request:  FMT=00 DID=00(server) SID=01(client) FNC=xx SIZ=xx
Response: FMT=01 DID=01(client) SID=00(server) FNC=xx SIZ=xx
```

## Boot Sequence (Wire-Level)

### 1. CPNETLDR (no wire traffic)

Loads SNIOS.SPR and NDOS.SPR from local A: drive. Patches the BDOS
vector at 0x0005 to point to NDOS. The SNIOS `NTWKIN` routine drains
any stale bytes from the SIO ring buffer and sets the ACTIVE flag.
No FNC=0xFF handshake is sent (CP/NET 1.2 mode).

### 2. LOGIN PASSWORD (authenticates with server)

LOGIN.COM sends a network login request:
```
FNC=0x40 (64), data = "PASSWORD" (or configured password)
```
The server validates the password and returns success. Without this
step, all subsequent requests fail with error 0x0C.

### 3. NETWORK H:=B: (maps drive)

NETWORK.COM sends BDOS F39 (Access Drive) and F14 (Select Disk) to
configure drive H: as a network drive mapped to server drive B:.
NDOS updates the drive mapping table in the SNIOS configuration.

### 4. Application I/O (DIR, TYPE, PIP, etc.)

Applications call BDOS normally. NDOS intercepts calls for network
drives and routes them through SNIOS. Each BDOS call becomes one
request/response exchange over the wire.

## Timing

Observed from proxy trace at 38400 baud:
- Boot to first CP/NET message: ~8.5 seconds
- Round-trip per message: <100ms (dominated by MAME serial emulation)
- LOGIN + NETWORK sequence: ~1 second total
- Multiple retries visible when server returns errors (1-2 second gaps)

## Key Differences from Python server.py

| Aspect | server.py | z80pack MP/M |
|--------|-----------|--------------|
| Authentication | None (always accepts) | LOGIN required |
| FNC=0xFF init | Responds with node IDs | Not used (CP/NET 1.2) |
| Error code | 0xFF (generic) | 0x0C (unauthenticated) |
| Drive mapping | Host directories | MP/M disk drives |
| Console redirect | Supported (--console) | Via MP/M console ports |
| Server platform | Python on host | Z80 MP/M in emulator |
