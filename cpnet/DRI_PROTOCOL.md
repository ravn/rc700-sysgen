# DRI Binary Serial Protocol for CP/NET

This document describes the DRI (Digital Research Inc.) binary serial protocol
as implemented in the RC702 SNIOS and the Python CP/NET server. The protocol
is the standard CP/NET serial framing defined in the CP/NET Operating System
Manual, Appendix E.

## Overview

The DRI protocol uses control characters for framing and a two's complement
checksum for data integrity. All payload bytes are sent as raw binary (8-bit
clean), unlike the older ASCII hex-encoded protocol which doubled bandwidth
usage.

**Wire format:**

```
Requester                              Responder
    |                                      |
    |--- ENQ ---------------------------->|  "I want to send"
    |<-- ACK -----------------------------|  "Go ahead"
    |                                      |
    |--- SOH FMT DID SID FNC SIZ HCS --->|  Header (7 bytes)
    |<-- ACK or NAK ----------------------|  Header checksum OK/fail
    |                                      |
    |--- STX data[0..SIZ] ETX CKS EOT -->|  Data phase
    |<-- ACK or NAK ----------------------|  Data checksum OK/fail
    |                                      |
```

On NAK, the requester retries from ENQ. On timeout, the requester retries
up to MAXRETRY (10) times before reporting an error.

## Control Characters

| Char | Hex  | Name                | Role                            |
|------|------|---------------------|---------------------------------|
| SOH  | 0x01 | Start of Header     | Marks beginning of header block |
| STX  | 0x02 | Start of Text       | Marks beginning of data block   |
| ETX  | 0x03 | End of Text         | Marks end of data block         |
| EOT  | 0x04 | End of Transmission | Marks end of entire message     |
| ENQ  | 0x05 | Enquiry             | Initiates a transaction         |
| ACK  | 0x06 | Acknowledge         | Positive response               |
| NAK  | 0x15 | Negative Ack        | Negative response (bad checksum)|

These are standard ASCII control characters. They can appear freely inside
the data payload without escaping -- framing is positional, not delimiter-based.
The receiver counts bytes based on the SIZ field, not by scanning for
control characters.

## Message Structure

Every CP/NET message has a 5-byte header and a variable-length data payload.

### Header (5 bytes)

| Offset | Field | Description                                     |
|--------|-------|-------------------------------------------------|
| 0      | FMT   | Format byte (usually 0x00)                      |
| 1      | DID   | Destination ID (server=0x00, client=assigned)    |
| 2      | SID   | Source ID (sender's node ID)                     |
| 3      | FNC   | Function code (BDOS function number, or special) |
| 4      | SIZ   | Data length minus 1 (0 = 1 byte, 255 = 256 bytes)|

### Special Function Codes

| FNC  | Direction       | Purpose                          |
|------|-----------------|----------------------------------|
| 0xFF | Client -> Server| Network initialization request   |
| 0xFE | Client -> Server| Network shutdown notification     |
| 0x00-0x47 | Both      | BDOS function forwarding (F0-F71)|

### Data Payload

`SIZ + 1` bytes (1 to 256). Contents depend on the function code.
For BDOS operations, byte 0 is typically the return code, followed by
the FCB or DMA buffer data.

## Checksum Algorithm

The protocol uses a **two's complement checksum**: the arithmetic negation
of the sum of all bytes in the block. The receiver adds all bytes including
the checksum; if the result is zero, the block is valid.

### Header Checksum (HCS)

Covers the SOH byte and the 5 header bytes:

```
HCS = (0 - (SOH + FMT + DID + SID + FNC + SIZ)) AND 0xFF
```

The receiver computes `(SOH + FMT + DID + SID + FNC + SIZ + HCS) AND 0xFF`
and checks for zero.

### Data Checksum (CKS)

Covers the STX byte, all data bytes, and the ETX byte:

```
CKS = (0 - (STX + data[0] + ... + data[SIZ] + ETX)) AND 0xFF
```

The receiver computes the sum of STX + data + ETX + CKS and checks for zero.

### Python Reference Implementation

```python
def checksum(data, init=0):
    """Two's complement checksum."""
    s = init
    for b in data:
        s = (s + b) & 0xFF
    return (-s) & 0xFF
```

### Z80 Assembly Implementation

The SNIOS uses register D as a running accumulator:

```z80
; NETOUT - Send byte C, accumulate checksum in D
NETOUT: LD   A,D
        ADD  A,C
        LD   D,A        ; D += C
        LD   A,C
        JP   SENDBY     ; send raw byte

; At end of block, compute two's complement:
        XOR  A
        SUB  D           ; A = 0 - D = two's complement
        LD   C,A
        CALL NETOUT      ; send checksum byte
```

## Send Sequence (SNDMSG)

The client (requester) sends a message to the server:

```
Step  Sender  Bytes on wire         Notes
----  ------  --------------------  ----------------------------------
  1   Client  ENQ                   Request to transmit
  2   Server  ACK                   Permission granted
  3   Client  SOH                   Begin header
  4   Client  FMT DID SID FNC SIZ  5 header bytes
  5   Client  HCS                   Header checksum
  6   Server  ACK                   Header received OK
  7   Client  STX                   Begin data
  8   Client  data[0..SIZ]         SIZ+1 data bytes (raw binary)
  9   Client  ETX                   End data
 10   Client  CKS                   Data checksum
 11   Client  EOT                   End of transmission
 12   Server  ACK                   Message received OK
```

If the server sends NAK at step 6 (bad header checksum) or step 12
(bad data checksum), the client retries from step 1.

### Timeout and Retry

- After sending ENQ, the client polls for ACK with a timeout counter.
  If no ACK arrives, it decrements a retry counter and re-sends ENQ.
- After sending the header or data, `GETACK` waits for ACK with timeout.
  On timeout or NAK, the return address is discarded (`POP HL`) and
  control jumps back to `SEND` for a full retry.
- Maximum retries: 10 (MAXRETRY). After exhaustion, SNIOS returns 0xFF
  and sets the SNDERR bit in the network status byte.

## Receive Sequence (RCVMSG)

The client (responder) receives a message from the server:

```
Step  Sender  Bytes on wire         Notes
----  ------  --------------------  ----------------------------------
  1   Server  ENQ                   Server requests to transmit
  2   Client  ACK                   Client grants permission
  3   Server  SOH                   Begin header
  4   Server  FMT DID SID FNC SIZ  5 header bytes
  5   Server  HCS                   Header checksum
  6   Client  ACK                   Header OK (or NAK to reject)
  7   Server  STX                   Begin data
  8   Server  data[0..SIZ]         SIZ+1 data bytes
  9   Server  ETX                   End data
 10   Server  CKS                   Data checksum
 11   Server  EOT                   End of transmission
 12   Client  ACK                   Message OK (or NAK to reject)
```

### DID Validation

After receiving a complete message, the client checks the DID field
against its own node ID (`CFGTBL+1`). Special case: if `CFGTBL+1` is
0xFF (uninitialized), the client accepts any DID. This allows the
first NTWKIN handshake to succeed before the node ID is assigned.

The check uses the DRI idiom:

```z80
LD   A,(CFGTBL+1)
INC  A             ; 0xFF -> 0x00, sets Z flag
JR   Z,SNDACK     ; uninitialized: accept any DID
DEC  A             ; restore original value
SUB  (HL)          ; compare with received DID
JR   Z,SNDACK     ; match: A=0 (success)
LD   A,0FFH        ; mismatch: return error
```

## Initialization Handshake (FNC=0xFF)

```
Client                                 Server
  |                                      |
  |--- [FMT=0 DID=0 SID=FF FNC=FF] --->|  "Assign me a node ID"
  |<-- [FMT=0 DID=01 SID=00 FNC=FF] ---|  "You are node 1, I am node 0"
  |                                      |
```

After receiving the response:
1. Client stores DID (0x01) as its slave ID in `CFGTBL+1`
2. Client sets the ACTIVE flag (0x10) in `CFGTBL+0`
3. Client is now ready for BDOS operations

## Shutdown (FNC=0xFE)

```
Client                                 Server
  |                                      |
  |--- [FMT=0 DID=0 SID=01 FNC=FE] --->|  "I am shutting down"
  |                                      |
```

No response expected. The server logs the disconnection.

## Comparison with Hex-Encoded ASCII Protocol

The RC702 SNIOS previously used a hex-encoded ASCII protocol with CRC-16
checksums (`++`...`--` framing from cpnet-z80 `src/serial/`). The DRI
binary protocol replaced it for these reasons:

| Aspect          | Hex/CRC-16 ASCII     | DRI Binary              |
|-----------------|----------------------|-------------------------|
| Framing         | `++` ... `--`        | ENQ/ACK/SOH/STX/ETX/EOT|
| Encoding        | 2 hex chars per byte | Raw binary (1:1)        |
| Checksum        | CRC-16 (poly 0x8408) | Two's complement sum    |
| Wire overhead   | 18 + 2N bytes/msg    | 8 + N bytes/msg         |
| Throughput @38400| ~2.4 KB/s           | ~4.8 KB/s               |
| SNIOS code size | 637 bytes            | 673 bytes (+36B for ACK)|
| Compatibility   | cpnet-z80 `serial`   | Standard DRI, z80pack   |
| Error recovery  | None (drop frame)    | NAK + retry (10 attempts)|

The DRI protocol is the standard defined by Digital Research and is compatible
with z80pack and CpnetSerialServer.jar (`proto=DRI`).

## Hex File Bootstrap Phase

Before CP/NET starts, the server can deliver Intel HEX files (SNIOS.SPR,
NDOS.SPR, etc.) over the same serial link as raw ASCII text. DRI control
characters (0x01-0x06, 0x15) never appear in Intel HEX files (which use
only `:`, `0`-`9`, `A`-`F`, CR, LF), so the two phases cannot interfere.

The bootstrap sequence:
1. Server listens on TCP port, MAME connects via null_modem
2. Server sends Intel HEX files as raw ASCII (PIP RDR: receives them)
3. CP/M LOAD converts .HEX to .COM/.SPR
4. User runs CPNETLDR, which triggers FNC=0xFF -- DRI framing begins
5. All subsequent traffic uses DRI binary protocol

## Implementation Files

| File              | Role                                               |
|-------------------|----------------------------------------------------|
| `cpnet/snios.asm` | Z80 SNIOS: DRI framing, checksums, send/receive    |
| `cpnet/server.py` | Python server: DRI framing, BDOS emulation          |
| `cpnet/build_snios.py` | Assembler wrapper: builds SPR with relocation bitmap |

## References

- Digital Research, *CP/NET Operating System Manual*, Appendix E
  (serial protocol specification)
- `~/git/cpnet-z80/src/ser-dri/snios.asm` -- DRI reference SNIOS
- `~/git/z80pack/cpmsim/srcsim/` -- z80pack SNIOS (binary DRI)
- `~/git/cpnet-z80/contrib/CpnetSerialServer.jar` -- Java server
  (supports `proto=DRI`)
