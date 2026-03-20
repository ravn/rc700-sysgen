# RC700 Emulator FTP File Transfer

Source: `/Users/ravn/git/rc700/ftp.c`, `FGET.PAS`, `FPUT.PAS`

## Overview

The "FTP" device is **not real FTP**. It is a custom byte-stream file transfer mechanism
between the host OS and CP/M, accessible via two Z80 I/O ports. The name is informal.

## Starting the Emulator with FTP

```bash
rc700-sdl2 -ftp /path/to/host/dir disk.imd
```

The `-ftp DIR` argument specifies a **base directory** on the host. All filenames sent by
CP/M programs are automatically prefixed with `DIR/`. If omitted, the current working
directory is used.

## I/O Ports

| Port | Direction | Purpose |
|------|-----------|---------|
| 0xE0 | Write | Send command byte |
| 0xE0 | Read  | Read status byte (clears status after read) |
| 0xE1 | Write | Send filename char (in filename mode) or write file byte |
| 0xE1 | Read  | Read file byte (returns 0xFF on EOF) |

## Commands (write to 0xE0)

| Value | Name        | Action |
|-------|-------------|--------|
| 0x00  | RESET       | Close any open file, reset state |
| 0x01  | FILENAME    | Enter filename accumulation mode; subsequent writes to 0xE1 append to filename |
| 0x02  | OPEN        | Open accumulated filename for reading |
| 0x03  | CREATE      | Create (or truncate) accumulated filename for writing |
| 0x04  | CLOSE       | Close the open file |

## Status Codes (read from 0xE0)

| Value | Meaning |
|-------|---------|
| 0x00  | OK |
| 0xFF  | EOF (end of file during read) |
| other | Unix `errno` value from `fopen()`/`fputc()` — e.g. ENOENT=2, EACCES=13 |

## Read Protocol (host -> CP/M)

```
OUT (0xE0), 0x00         ; RESET
IN  A, (0xE0)            ; check status
OUT (0xE0), 0x01         ; FILENAME mode
OUT (0xE1), 'f'          ; stream filename bytes
OUT (0xE1), 'o'
OUT (0xE1), 'o'
OUT (0xE1), '.'
OUT (0xE1), 't'
OUT (0xE1), 'x'
OUT (0xE1), 't'          ; last char (no NUL needed)
OUT (0xE0), 0x02         ; OPEN for read
IN  A, (0xE0)            ; must be 0x00 = OK
loop:
  IN  A, (0xE1)          ; read byte
  CP  0xFF               ; potential EOF marker
  JR  NZ, got_byte
  IN  A, (0xE0)          ; read status
  OR  A
  JR  NZ, done           ; status != 0 means real EOF
got_byte:
  ; process byte
  JR  loop
done:
OUT (0xE0), 0x04         ; CLOSE
```

Note: 0xFF is a valid data byte. Only 0xFF *and* status != 0 together indicate EOF.

## Write Protocol (CP/M -> host)

```
OUT (0xE0), 0x00         ; RESET
OUT (0xE0), 0x01         ; FILENAME mode
; stream filename bytes to 0xE1 ...
OUT (0xE0), 0x03         ; CREATE (truncates if exists)
IN  A, (0xE0)            ; must be 0x00 = OK
; for each byte to write:
  OUT (0xE1), A          ; write byte
  IN  A, (0xE0)          ; check for write error (0 = OK)
OUT (0xE0), 0x04         ; CLOSE
```

## CP/M Pascal Utilities

Two ready-made Pascal programs are in `/Users/ravn/git/rc700/`:

### FGET.PAS — download file from host to CP/M

```
A>FGET filename.ext
filename.ext: 12345 BYTES RECEIVED
```

Reads in 128-byte CP/M blocks. Detects EOF via the 0xFF + status check.

### FPUT.PAS — upload file from CP/M to host

```
A>FPUT filename.ext
filename.ext: 12345 BYTES SENT
```

Reads CP/M file in 128-byte blocks, writes byte-by-byte to port 0xE1, checks status after each.

## Compiling the Pascal Utilities

The `.PAS` files are written for Turbo Pascal or similar CP/M Pascal. They use `PORT[]`
array syntax for direct I/O port access:

```pascal
CONST
  FTP_STAT = $E0;
  FTP_DATA = $E1;
  FTP_RESET    = $00;
  FTP_FILENAME = $01;
  FTP_OPEN     = $02;
  FTP_CREATE   = $03;
  FTP_CLOSE    = $04;
```

## Notes

- Filename buffer is 256 bytes including the base directory prefix. Long paths may overflow.
- The FGET 128-byte block padding: if the last block is short, the file on CP/M will be
  padded with 0x1A (CP/M EOF) characters — standard CP/M behaviour.
- No subdirectory navigation from the CP/M side; flat filenames only (the base dir is fixed).
