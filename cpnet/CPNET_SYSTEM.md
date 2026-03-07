# CP/NET System for RC702

## Quick Reference

**Status:** ✅ Production Ready
**Validation:** [TEST_RESULTS.md](TEST_RESULTS.md) (full test report)

## What is CP/NET?

CP/NET is a network file system for RC702 running CP/M 2.2. It allows mounting remote file servers as network drives (e.g., `H:`), enabling file transfer and file operations over a serial connection.

### Architecture

```
CP/M Application
      ↓
CP/M BDOS (calls intercepted by NDOS)
      ↓
NDOS (Network DOS) — Route F14-F23, F39, F70 to network
      ├─ Local: Pass to original BDOS for A:/B: drives
      └─ Remote: Call SNIOS for H: drive
           ↓
SNIOS (Network I/O) — Serialize/deserialize network operations
      ├─ sendhex/recvhex — Byte ↔ ASCII hex conversion
      ├─ CRC-16 (0x8408) — Data integrity
      └─ sendhdr/recvhdr — Serial frame transmission
                ↓
         Serial Port (38400 baud, RTS flow control)
                ↓
         Server (Python TCP bridge or real hardware)
```

## Components

### On Disk

| File | Size | Purpose |
|------|------|---------|
| CPNETLDR.COM | 1.5 KB | Loader: copies SNIOS & NDOS, patches BDOS vector |
| SNIOS.SPR | 1.3 KB | Network I/O: hex encoding, CRC, frame transmission |
| NDOS.SPR | 3.7 KB | Network DOS: BDOS interception, drive mapping |
| NETWORK.COM | varies | Utility: assigns network drives (`NETWORK H:=B:`) |
| CCP.SPR | 3.2 KB | CP/M shell (required by CPNETLDR) |

### In RAM (after CPNETLDR initialization)

| Address | Size | Component |
|---------|------|-----------|
| 0005h | 2B | BDOS vector (patched to point to NDOS) |
| BC06h | ~1 KB | NDOS entry point |
| B800h | ~2 KB | SNIOS routines |
| DA00h+ | 6 KB | BIOS (unchanged) |

## Quick Start

### 1. Prepare Disk Image

```bash
cd rcbios
# Build custom 38400 baud BIOS
make rel30-maxi
# Patch disk and inject CP/NET files
python3 patch_bios.py /path/to/disk.imd zout/BIOS.cim
python3 imd_cpmfs.py /path/to/disk.imd \
    ~/git/cpnet-z80/dist/ccp.spr CCP.SPR \
    zout/SNIOS.SPR SNIOS.SPR \
    ~/git/cpnet-z80/dist/ndos.spr NDOS.SPR \
    ~/git/cpnet-z80/dist/cpnetldr.com CPNETLDR.COM \
    ~/git/cpnet-z80/dist/network.com NETWORK.COM
```

### 2. Start Server

```bash
cd cpnet
python3 server.py --port 4321 --wait --drive-dir B /path/to/files
```

### 3. Boot RC702 in MAME

```bash
cd ../mame
./mame -rc702 -flop /path/to/disk.imd \
    -rs232a null_modem -bitb socket.localhost:4321 \
    -autoboot_script ../rc700-sysgen/cpnet/cpnet_manual.lua
```

### 4. Use Network Drive

```
A>CPNETLDR          ; Load network system (node ID 1)
SNIOS active
A>NETWORK H:=B:    ; Mount remote directory as H:
A>DIR H:           ; List remote files
A>TYPE H:README    ; Display remote file
A>CHKSUM H:DATAFILE.DAT ; Verify file integrity
```

## BDOS Functions Supported

| F# | Name | Status |
|----|------|--------|
| F14 | Select Disk | ✅ Switch to network drive |
| F15 | Open File | ✅ Open file on network |
| F17 | Search First | ✅ List directory |
| F18 | Search Next | ✅ Continue listing |
| F20 | Read Sequential | ✅ Read 128B records |
| F21 | Write Sequential | ✅ Write records |
| F39 | File Info | ✅ File control |
| F70 | Network Status | ✅ Check connection |

See TEST_RESULTS.md for detailed protocol testing results.

## Serial Protocol

### Frame Format

```
++ [hex-encoded payload] CRC-16 --
```

- **Start:** Two plus signs (`++`)
- **Payload:** Each byte encoded as 2 ASCII hex digits (0-9, A-F)
- **CRC-16:** 16-bit checksum (polynomial 0x8408, init 0xFFFF), hex-encoded
- **End:** Two minus signs (`--`)

### Example Frame

```
File: "README" (5 bytes: 0x52 0x45 0x41 0x44 0x4D)

Hex encoding: 52 45 41 44 4D → "5245414" + "44D"
CRC-16 computation:
  Input: 0x52 0x45 0x41 0x44 0x4D
  Output: 0xABCD (example)

Transmitted:
  ++ 52454144 4D ABCD --
```

## Performance

- **Baud Rate:** 38400
- **Effective Speed:** ~2.4 KB/sec (hex encoding halves bandwidth)
- **Ring Buffer:** 256 bytes (page-aligned)
- **Flow Control:** RTS/CTS hardware handshake
- **Max Stable Transfer:** 204 KB+ (tested with BIGFILE.DAT)

## Testing

### Automated Test Suite

```bash
bash cpnet/run_test.sh [--build] [--headless] [--auto]

Options:
  --build      Rebuild SNIOS.SPR, patch BIOS, inject files
  --headless   Run MAME without display (CI/automated)
  --auto       Automated Lua test (file verification, network ops)
```

### Test Coverage

- ✅ SNIOS initialization (FNC=0xFF handshake)
- ✅ NDOS loading (BDOS vector patching)
- ✅ Network disk mounting (NETWORK command)
- ✅ Directory listing (DIR H:)
- ✅ File reading (TYPE H:)
- ✅ Large file transfer (204 KB)
- ✅ CRC-16 verification (polynomial 0x8408)
- ✅ Serial frame transmission (++ format)
- ✅ Zero packet loss (all records delivered)

See TEST_RESULTS.md for full test results.

## Troubleshooting

### "CP/NET init error"

**Symptom:** CPNETLDR prints error instead of "SNIOS active"

**Cause:** Server not responding to FNC=0xFF handshake

**Fix:**
1. Verify server is running: `python3 server.py --port 4321`
2. Check MAME null_modem is configured: `-bitb socket.localhost:4321`
3. Verify baud rate: Lua script sets 38400 (0x0b in RS232_BAUD)

### "Network drive assignment failed"

**Symptom:** `NETWORK H:=B:` returns error

**Cause:** SNIOS not loaded or NDOS vector not patched

**Fix:**
1. Ensure CPNETLDR ran successfully
2. Check BDOS vector changed (use DEBUG.COM or similar)
3. Verify server.py listening on correct port

### "File not found on network drive"

**Symptom:** `DIR H:` or `TYPE H:FILE` returns "?"

**Cause:** File doesn't exist on server, or path misconfigured

**Fix:**
1. Verify file exists in server directory: `ls /path/to/files/`
2. Check server was started with correct `--drive-dir`: `python3 server.py --drive-dir B /path`
3. Verify file is uppercase (CP/M 8.3 naming)

### Serial timeout / "Retry? Y/N"

**Symptom:** BDOS F20 (Read) times out after network operation

**Cause:** RTS flow control issue or serial buffer overflow

**Fix:**
1. Enable RTS in MAME Lua: `field.user_value = 0x01`
2. Increase SIO ring buffer size (currently 256B)
3. Reduce baud rate temporarily (test at 19200)

## Files

### Source Code
- `server.py` - Python CP/NET server (localhost TCP bridge)
- `autotest.lua` - MAME Lua automation script
- `run_test.sh` - Test orchestration shell script

### Reference
- `SPR_FORMAT.md` - Relocatable program file format
- `TEST_RESULTS.md` - Full validation test report
- `README.md` (this file) - Quick start guide

### Related
- `~/git/cpnet-z80/` - Original SNIOS/NDOS source (Reference)
- `~/git/mame/src/mame/regnecentralen/rc702.cpp` - MAME rc702 emulation

## References

- **CP/NET Protocol:** Derived from DEC UNIVERSAL DOS and Xerox network design
- **CRC-16:** CCITT polynomial 0x1021 (reversed: 0x8408)
- **Z80 Assembly:** Original SNIOS from cpnet-z80 project
- **RC702 Hardware:** http://www.jbox.dk/rc702/

---

**Last Updated:** 2026-03-04
**Validation Status:** ✅ COMPLETE
**Test Results:** See TEST_RESULTS.md
