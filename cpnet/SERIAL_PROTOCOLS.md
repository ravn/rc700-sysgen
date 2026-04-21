# CP/NET Serial Protocol Investigation (2026-03-07)

## Three Serial Protocols (from cpnet-z80 project)

| Protocol | ID | Framing | Encoding | Checksum | Server config |
|----------|----|---------|----------|----------|---------------|
| ASCII | `serial` | `++`...`--` | Hex nibbles | CRC-16 (poly 0x8408) | `proto=ASCII` |
| DRI | `ser-dri` | ENQ/ACK/SOH/STX/ETX/EOT | Binary or ASCII | Two's complement sum | `proto=DRI` |
| z80pack | (built-in) | DRI protocol | Binary (`Binary$ASCII=FFh`) | Two's complement sum | N/A |

### Current RC702 SNIOS uses DRI binary protocol (switched 2026-03-07)
- ENQ/ACK/SOH/STX/ETX/EOT framing, binary mode, two's complement checksum
- Compatible with DRI standard and z80pack
- Previous version used ASCII hex-encoded CRC-16 (`++`...`--`)

### DRI protocol details (from snios-0.asm in z80pack)
**Send sequence:** ENQ -> wait ACK -> SOH FMT DID SID FNC SIZ -> HCS -> wait ACK -> STX DATA ETX -> CKS -> EOT -> wait ACK
**Receive sequence:** wait ENQ -> send ACK -> receive SOH+header -> check HCS -> send ACK -> receive STX+data+ETX -> check CKS -> receive EOT -> send ACK (or NAK on bad checksum)

**Binary mode flag:** `Binary$ASCII` byte at runtime. 0=7-bit ASCII (hex nibbles), FFh=8-bit binary (raw bytes). z80pack defaults to FFh (binary).

**Checksum:** Simple two's complement sum of bytes (NOT CRC-16). Much simpler than CRC.

**`Net$out` routine** checks `Binary$ASCII` flag:
- Binary mode: `CALL Char$out` (send raw byte)
- ASCII mode: split into nibbles, `CALL Nib$out` (send hex)

### Protocol savings (binary DRI vs current hex ASCII)
- Wire: 8+N bytes vs 18+2N per message (2x bandwidth, ~4.8 KB/s vs 2.4 KB/s)
- SNIOS code: ~80 bytes smaller (no hex encode/decode, simpler checksum)
- Server code: ~90% smaller framing logic

## CP/NET Version Compatibility
- **CP/NET 1.1 and 1.2 are NOT binary compatible** (wire protocol differences)
- Our CPNETLDR.COM says "CP/NET 1.2"
- z80pack has both snios-1 (1.1) and snios-2 (1.2) variants
- Must match client and server versions

## z80pack Architecture
- **MP/M II V2.0** on mpm-1.dsk, mpm-2.dsk (boot via `./mpm` script)
- **Network I/O**: Port 50 (status) / 51 (data) -> TCP socket
- **Config**: `conf/net_client.conf` (host:port), `conf/net_server.conf` (listen ports)
- **SNIOS variants**: snios-0 (original DRI 1980), snios-1 (CP/NET 1.1), snios-2 (CP/NET 1.2)
- All use DRI protocol in binary mode

## CpnetSerialServer.jar (Java)
- Located: `~/git/cpnet-z80/contrib/CpnetSerialServer.jar`
- Distributed as .class files only (no source)
- Protocol classes: CpnetDRIProtocol, CpnetSerialProtocol, CpnetSimpleProtocol
- Supports DRI and ASCII protocols via `cpnet_proto=` config
- Key classes: HostFileBdos (BDOS emulation), ServerDispatch, NetworkServer

## MP/M Server for CP/NET
- cpnet-z80 has NETSERVR.RSP (MP/M resident server process)
- Currently only builds for W5500 NIC (Ethernet), not serial
- Would need serial NIOS for MP/M server side
- Server NIOS is reverse of client: receives first, then sends (ENQ from client initiates)

## Related Repos
- **z80pack**: `z80pack/` submodule (fork: https://github.com/ravn/z80pack)
- **cpnet-z80**: `~/git/cpnet-z80/` (https://github.com/durgadas311/cpnet-z80)
- **cpmtools3**: `~/git/cpmtools3/` (disk image file injection)
