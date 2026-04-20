# CP/M 2.2 BIOS Register Preservation Requirements

## Summary

**The CP/M 2.2 BDOS requires NO register preservation from any BIOS function.**

This means BIOS routines are free to clobber all registers (A, BC, DE, HL, IX, IY, flags).
The only contract is the documented input/output registers:
- Input: character in C (CONOUT, LIST, PUNCH), drive in C (SELDSK), etc.
- Output: status in A (CONST, READ, WRITE), character in A (CONIN, READER),
  disk_parameter_header pointer in HL (SELDSK), translated sector in HL (SECTRAN).

## Official Documentation

The **CP/M 2.2 Alteration Guide, Section 6** ([source](http://www.gaby.de/cpm/manuals/archive/cpm22htm/ch6.htm))
specifies only input/output register conventions for each BIOS function.
It contains **no statement** about register preservation requirements.

Additional references:
- [CP/M BIOS reference (seasip.info)](https://www.seasip.info/Cpm/bios.html)
- [CP/M 2.2 Alteration Guide PDF (bitsavers)](https://bitsavers.trailing-edge.com/pdf/digitalResearch/cpm/2.2/CPM_2.2_Alteration_Guide_1979.pdf)

Note: CP/M 3 (Plus) added preservation requirements for *new* functions
(e.g., SELMEM "must preserve all registers except A"), but these do not
apply to the original 17 CP/M 2.2 BIOS entries.

## Proof from BDOS Source Code

Source: `/Users/ravn/Downloads/cpm2-plm/OS3BDOS.ASM` (DRI original CP/M 2.2 BDOS).
Also: [github.com/brouhaha/cpm22](https://github.com/brouhaha/cpm22).

### CONOUT (`conoutf`) — lines 210-216

```asm
push b! call conbrk    ;check for screen stop function
pop b! push b          ;recall/save character
call conoutf           ;externally, to console
pop b! push b          ;recall/save character
```

BC (the character) is explicitly pushed/popped around `call conoutf`.
No other registers are used after the call — the BDOS reloads everything
from the stack.  The same pattern applies to `call listf`.

### CONIN (`coninf`)

Only A is used after the call (the returned character).  No other
registers are expected to survive.

### CONST (`constf`) — line 188

```asm
call constf
ani 1! rz
```

Only A is used after the call.

### SELDSK (`seldskf`) — lines 582-584

Only HL is used after the call (the returned disk_parameter_header pointer).  The BDOS
walks the disk_parameter_header structure entirely through HL/DE, reloading from the
returned pointer.

### READ (`readf`) / WRITE (`writef`) — lines 621-632

```asm
call readf     ; or writef
ora a! rz
```

Only A is used after the call.

### HOME (`homef`) — lines 610-613

No registers used after the call.  Fresh values loaded via `xra a`
and `lhld`.

### SETDMA / SETSEC

Called via `jmp` (tail call), not `call` — register preservation
is irrelevant.

### SETTRK (`settrkf`) — line 685

No registers used after the call — the BDOS pops saved values from
the stack for subsequent operations.

### SECTRAN

HL is the return value (translated sector number).  BC/DE are not
expected to survive.

## CCP Behavior

The CCP also saves/restores its own registers around BIOS calls.
No external CP/M component depends on BIOS register preservation.

## Implications for BIOS-in-C

The C compiler (sdcc via z88dk) freely uses A, BC, DE, HL as scratch
registers.  This is fully compatible with the CP/M 2.2 ABI.  The old
`bios_conout` wrapper that saved/restored all registers and switched
stacks was unnecessarily conservative — the current implementation
(a 1-byte `ld a, c` shim falling through to a normal C function) is
correct and saves ~2.5M cycles during TYPE FILEX.PRN.

## Exception: serial I/O shims preserve BC/DE/HL

`bios_punch_shim`, `bios_reader_shim`, and `bios_reads_shim` in
`clang/bios_shims.s` **do** push/pop BC/DE/HL around the body call.
This departs from the CP/M 2.2 spec in the conservative direction
(we preserve more than required) and costs a few T-states per call.

Why: **SNIOS** (the CP/NET slave-side serial handler in
`cpnet/snios.asm`) assumes DE survives across `CALL SENDBY → JP
B$PUNCH`.  Its `MSGOUT` loop holds the byte counter in E:

```
MSGOUT: LD D, 0
        CALL PREOUT
MSOLP:  LD C, (HL)
        INC HL
        CALL NETOUT      ; tail-chains to JP B$PUNCH
        DEC E            ; <- relies on E surviving BIOS PUNCH
        JR  NZ, MSOLP
```

Clang's `bios_punch_body` uses D and E as scratch (saves the byte
in D and `iobyte_pun` in E before the switch dispatch), so without
DE preservation SNIOS's loop counter is trashed every byte, the
loop exits after 1-2 iterations, and CP/NET frames abort mid-header.
SDCC's codegen happens not to touch DE, which is why the bug lay
dormant with SDCC.

SNIOS itself is internally inconsistent here — its `RECVBY` does
`push hl / push de` explicitly, but its send path does not.  A more
spec-literal fix would be to patch SNIOS to guard its send path too;
we chose to fix it on the BIOS side instead, as the pragmatic "cover
any slave code that makes the same assumption" option.

Fixed in commit 336d101 (BIOS shims preserve BC/DE/HL).  Fixes
ravn/rc700-gensmedet#12, #13, #14.
