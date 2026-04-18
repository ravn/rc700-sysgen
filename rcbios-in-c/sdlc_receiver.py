#!/usr/bin/env python3
"""sdlc_receiver.py — receive SDLC frames from RC702 SIO-B via FT2232D.

The RC702's MIC702 has no serial-clock pin on the DB-25 and the
Z80-SIO has no DPLL.  We therefore oversample the TxD line in async
bit-bang mode on the FTDI, do a software DPLL, NRZI-decode, HDLC
de-frame, and verify CRC-CCITT on the host.

Hardware:
  - RC702 SIO-B TxD (DB-25 pin 2) via its RS-232 driver, through the
    existing USB-FAST-SERIAL-ADAPTER, arrives at FT2232D interface B
    (ttyUSB1) as TTL on the RxD pin (FTDI ADBUS1 of channel B).
  - RC702 running SIOBSDLC.COM transmits at 125 kbaud SDLC NRZI with
    flag idle.

Sampling:
  - FT2232D async bit-bang max = 1 MHz sample rate.
  - baudrate value to libftdi = target_sample_hz / 16 = 62500 for
    1 MHz sampling.
  - 1 MHz / 125 kbaud = 8 samples per bit cell → comfortable for DPLL.

Uses libftdi1 via ctypes — no pyftdi dependency.

Usage:
  python3 sdlc_receiver.py [--seconds N] [--interface B]

Will print per-frame: byte count, CRC ok/bad, payload hex + ASCII.
"""
from __future__ import annotations

import argparse
import ctypes as C
import sys
import time


# --- libftdi1 bindings (minimal) -----------------------------------

_lib = C.CDLL("libftdi1.so.2")
_libusb = C.CDLL("libusb-1.0.so.0")
_libusb.libusb_attach_kernel_driver.argtypes = [C.c_void_p, C.c_int]
_libusb.libusb_attach_kernel_driver.restype = C.c_int

# struct ftdi_context is opaque to us; we only pass pointers.
ftdi_new = _lib.ftdi_new
ftdi_new.restype = C.c_void_p

ftdi_free = _lib.ftdi_free
ftdi_free.argtypes = [C.c_void_p]

ftdi_set_interface = _lib.ftdi_set_interface
ftdi_set_interface.argtypes = [C.c_void_p, C.c_int]
ftdi_set_interface.restype = C.c_int

ftdi_usb_open = _lib.ftdi_usb_open
ftdi_usb_open.argtypes = [C.c_void_p, C.c_int, C.c_int]
ftdi_usb_open.restype = C.c_int

ftdi_usb_close = _lib.ftdi_usb_close
ftdi_usb_close.argtypes = [C.c_void_p]
ftdi_usb_close.restype = C.c_int

ftdi_usb_reset = _lib.ftdi_usb_reset
ftdi_usb_reset.argtypes = [C.c_void_p]
ftdi_usb_reset.restype = C.c_int

ftdi_set_bitmode = _lib.ftdi_set_bitmode
ftdi_set_bitmode.argtypes = [C.c_void_p, C.c_ubyte, C.c_ubyte]
ftdi_set_bitmode.restype = C.c_int

ftdi_set_baudrate = _lib.ftdi_set_baudrate
ftdi_set_baudrate.argtypes = [C.c_void_p, C.c_int]
ftdi_set_baudrate.restype = C.c_int

ftdi_set_latency_timer = _lib.ftdi_set_latency_timer
ftdi_set_latency_timer.argtypes = [C.c_void_p, C.c_ubyte]
ftdi_set_latency_timer.restype = C.c_int

ftdi_read_data = _lib.ftdi_read_data
ftdi_read_data.argtypes = [C.c_void_p, C.c_char_p, C.c_int]
ftdi_read_data.restype = C.c_int

# libftdi1's struct ftdi_context layout (start):
#   struct libusb_context *usb_ctx;
#   struct libusb_device_handle *usb_dev;
# We peek at usb_dev to reattach the kernel driver on exit.
class _FtdiContextHead(C.Structure):
    _fields_ = [
        ("usb_ctx", C.c_void_p),
        ("usb_dev", C.c_void_p),
    ]

ftdi_get_error_string = _lib.ftdi_get_error_string
ftdi_get_error_string.argtypes = [C.c_void_p]
ftdi_get_error_string.restype = C.c_char_p

INTERFACE_A = 1
INTERFACE_B = 2
BITMODE_BITBANG = 0x01


def _check(ctx: int, rc: int, what: str) -> None:
    if rc < 0:
        msg = ftdi_get_error_string(ctx)
        raise RuntimeError(f"{what}: {rc}: {msg.decode() if msg else ''}")


# --- Signal processing --------------------------------------------

def samples_to_bits(samples: bytes, rxd_mask: int, sps: float) -> list[int]:
    """Oversampled line states → one bit per bit cell via run-length
    quantization.  Now that the C capture path delivers clean samples
    (no dropped bytes), runs of same level are reliably integer
    multiples of the bit-cell duration.

      1. Walk the samples, counting consecutive same-level runs.
      2. At each transition, emit round(run/sps) copies of the
         previous level — that's how many bit cells it occupied.
      3. Skip trailing idle (no transition for a long time).
    """
    bits: list[int] = []
    if not samples:
        return bits
    prev = 1 if (samples[0] & rxd_mask) else 0
    run = 0
    # Don't emit absurdly long runs (idle before/after the frame).
    MAX_RUN_BITS = 8
    for b in samples:
        cur = 1 if (b & rxd_mask) else 0
        if cur == prev:
            run += 1
            continue
        n_bits = max(1, round(run / sps))
        if n_bits > MAX_RUN_BITS:
            n_bits = MAX_RUN_BITS
        bits.extend([prev] * n_bits)
        prev = cur
        run = 1
    return bits


def nrzi_decode(bits: list[int]) -> list[int]:
    """SDLC NRZI: no transition = 1, transition = 0.

    A "bit" in our representation is the steady-state level across
    one bit cell; a transition happens at the bit boundary.  Our
    samples_to_bits output already gives us cell values, so the
    decoded bit is 1 iff current cell == previous cell.
    """
    out: list[int] = []
    prev = 1  # idle is marks, but SDLC idles on flags; pick either
    for cur in bits:
        out.append(1 if cur == prev else 0)
        prev = cur
    return out


def find_frames(bits: list[int]) -> list[list[int]]:
    """Find HDLC frames delimited by 0x7E flags, with zero-bit-
    deletion applied.

    A flag pattern is 0 1 1 1 1 1 1 0 (LSB-first over the line).
    HDLC convention: after five consecutive 1s in data, a 0 is
    inserted by the sender; the receiver deletes it.  Six 1s
    between 0s = flag; seven = abort.
    """
    # HDLC sends LSB first.  Scan the bit stream for flags and
    # accumulate between them with zero-deletion.
    FLAG = [0, 1, 1, 1, 1, 1, 1, 0]
    frames: list[list[int]] = []
    i = 0
    n = len(bits)
    while i < n - 8:
        if bits[i : i + 8] != FLAG:
            i += 1
            continue
        # Advance past this flag; skip any back-to-back flags.
        while i + 8 <= n and bits[i : i + 8] == FLAG:
            i += 8
        # Accumulate frame bits until the next flag, with
        # zero-deletion.
        frame_bits: list[int] = []
        ones = 0
        while i < n:
            b = bits[i]
            i += 1
            if ones == 5:
                ones = 0
                if b == 0:
                    # Stuffed zero; drop it.
                    continue
                else:
                    # Six 1s: either flag start (need one more 0)
                    # or abort (seventh 1).  Roll back to re-detect.
                    i -= 1
                    # Trim the five 1s we already emitted — they're
                    # actually part of the flag/abort.
                    frame_bits = frame_bits[:-5]
                    break
            if b == 1:
                ones += 1
            else:
                ones = 0
            frame_bits.append(b)
        if frame_bits:
            frames.append(frame_bits)
    return frames


def bits_to_bytes(bits: list[int]) -> bytes:
    """LSB-first bits → bytes.  Drops any trailing partial byte."""
    out = bytearray()
    for j in range(0, len(bits) - 7, 8):
        v = 0
        for k in range(8):
            v |= bits[j + k] << k
        out.append(v)
    return bytes(out)


def crc_ccitt(data: bytes) -> int:
    """CRC-CCITT (SDLC) with preset 1s, LSB-first, residual 0x1D0F.

    SDLC transmits the 1's-complement of the computed CRC so that a
    correctly received frame (data + CRC) yields the fixed residual
    0xF0B8 (standard) / 0x1D0F (bit-reversed form).  We just compute
    the forward CRC with preset 0xFFFF over data, then compare the
    complement to the two trailing bytes.
    """
    crc = 0xFFFF
    for byte in data:
        crc ^= byte
        for _ in range(8):
            if crc & 1:
                crc = (crc >> 1) ^ 0x8408  # reflected 0x1021
            else:
                crc >>= 1
    return crc ^ 0xFFFF


# --- Main ---------------------------------------------------------

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--seconds", type=float, default=5.0)
    ap.add_argument("--interface", choices=["A", "B"], default="B")
    ap.add_argument("--baudrate-hint", type=int, default=62500,
                    help="line baud (for sps calculation)")
    ap.add_argument("--sample-hz", type=int, default=1_000_000,
                    help="bit-bang sample rate")
    ap.add_argument("--rxd-bit", type=int, default=1,
                    help="FTDI ADBUS pin index for RxD (default 1)")
    ap.add_argument("--dump-raw", help="write raw sample bytes to this path")
    ap.add_argument("--decode-only", help="skip capture, decode this raw file")
    args = ap.parse_args()

    if args.decode_only:
        from pathlib import Path
        samples = bytearray(Path(args.decode_only).read_bytes())
        sps = args.sample_hz / args.baudrate_hint
        rxd_mask = 1 << args.rxd_bit
        print(f"# decode-only: {len(samples)} samples @ {args.sample_hz} Hz "
              f"(sps={sps:.2f}), line {args.baudrate_hint} baud")
        bits = samples_to_bits(bytes(samples), rxd_mask, sps)
        print(f"# {len(bits)} raw bits after DPLL")
        data_bits = nrzi_decode(bits)
        frames = find_frames(data_bits)
        print(f"# {len(frames)} frame candidates")
        for idx, fb in enumerate(frames):
            byte_count = len(fb) // 8
            frame = bits_to_bytes(fb[:byte_count*8])
            if len(frame) < 2: continue
            data_b, crc_rx = frame[:-2], frame[-2:]
            crc_val = crc_ccitt(data_b)
            crc_bytes = bytes([crc_val & 0xFF, (crc_val >> 8) & 0xFF])
            ok = crc_bytes == crc_rx
            if len(data_b) < 3 and not ok: continue
            ascii_ = "".join(chr(b) if 32<=b<127 else "." for b in data_b)
            print(f"frame {idx}: {len(data_b)}B CRC {'OK ' if ok else 'BAD'} "
                  f"rx={crc_rx.hex()} calc={crc_bytes.hex()}  "
                  f"{data_b.hex()}  |{ascii_}|")
        return 0

    ctx = ftdi_new()
    if not ctx:
        print("ftdi_new failed", file=sys.stderr)
        return 1
    try:
        iface = INTERFACE_B if args.interface == "B" else INTERFACE_A
        _check(ctx, ftdi_set_interface(ctx, iface), "set_interface")
        _check(ctx, ftdi_usb_open(ctx, 0x0403, 0x6010), "usb_open")
        # Deliberately NOT calling ftdi_usb_reset — that acts on the
        # whole chip and would briefly disturb interface A (ttyUSB0)
        # which the deploy script is keeping open for the CP/M
        # console.

        # Direction mask 0 = all pins as inputs.
        _check(ctx, ftdi_set_bitmode(ctx, 0x00, BITMODE_BITBANG),
               "set_bitmode")
        # libftdi docs: in bit-bang the baudrate arg is multiplied by
        # 16 internally for FT2232C/D.  62500 * 16 = 1 MHz sampling.
        baud_param = args.sample_hz // 16
        _check(ctx, ftdi_set_baudrate(ctx, baud_param), "set_baudrate")
        # Lower the latency timer so small-packet reads drain promptly.
        _check(ctx, ftdi_set_latency_timer(ctx, 1), "set_latency_timer")

        sps = args.sample_hz / args.baudrate_hint
        rxd_mask = 1 << args.rxd_bit

        print(f"# sampling ch{args.interface} at {args.sample_hz} Hz "
              f"({sps:.2f} samples/bit), RxD on ADBUS{args.rxd_bit}")
        print(f"# capturing for {args.seconds}s")

        # Tight read loop — avoid sleeps that could mis-align with
        # USB bulk-IN scheduling.  ftdi_read_data() is non-blocking
        # and returns 0 when no data's waiting; we just spin.  Pre-
        # allocate the ctypes buffer so GC doesn't thrash.
        BUF = 262144
        buf = (C.c_char * BUF)()
        samples = bytearray()
        t_end = time.time() + args.seconds
        while time.time() < t_end:
            n = ftdi_read_data(ctx, buf, BUF)
            if n < 0:
                _check(ctx, n, "read_data")
            if n > 0:
                samples.extend(buf[:n])
        print(f"# captured {len(samples)} samples "
              f"({len(samples)/args.sample_hz:.2f} s of data)")
        if args.dump_raw:
            from pathlib import Path
            Path(args.dump_raw).write_bytes(bytes(samples))
            print(f"# raw samples dumped to {args.dump_raw}")
        # Quick diagnostics.
        if samples:
            pin_hi = sum(1 for b in samples if b & rxd_mask)
            print(f"# RxD high fraction: {pin_hi/len(samples):.3f}")
            # Count transitions on RxD pin.
            trans = 0
            prev = samples[0] & rxd_mask
            for b in samples:
                cur = b & rxd_mask
                if cur != prev:
                    trans += 1
                prev = cur
            print(f"# RxD transitions: {trans} "
                  f"({trans/(len(samples)/args.sample_hz):.0f} Hz)")

        # Turn off bit-bang so the next tool to grab ttyUSB doesn't
        # get a surprise.
        ftdi_set_bitmode(ctx, 0x00, 0x00)

        # Re-attach the kernel ftdi_sio driver for this interface
        # BEFORE closing — otherwise /dev/ttyUSB* disappears for
        # this channel and we have to replug the USB cable.
        head = _FtdiContextHead.from_address(ctx)
        kernel_iface = 0 if iface == INTERFACE_A else 1
        _libusb.libusb_attach_kernel_driver(head.usb_dev, kernel_iface)
    finally:
        ftdi_usb_close(ctx)
        ftdi_free(ctx)

    # --- Decode ----------------------------------------------------
    bits = samples_to_bits(bytes(samples), rxd_mask, sps)
    print(f"# {len(bits)} raw bits after DPLL")
    data_bits = nrzi_decode(bits)
    frames = find_frames(data_bits)
    print(f"# {len(frames)} frame candidates")

    for idx, fb in enumerate(frames):
        # Trim to whole-byte count.  An SDLC frame is always an
        # integer number of bytes between flags; if we have a
        # remainder it means the decode is off by a few bits.
        byte_count = len(fb) // 8
        frame = bits_to_bytes(fb[: byte_count * 8])
        if len(frame) < 2:
            continue
        data, crc_rx = frame[:-2], frame[-2:]
        crc_val = crc_ccitt(data)
        crc_bytes = bytes([crc_val & 0xFF, (crc_val >> 8) & 0xFF])
        ok = crc_bytes == crc_rx
        ascii_ = "".join(chr(b) if 32 <= b < 127 else "." for b in data)
        status = "OK " if ok else "BAD"
        print(f"frame {idx}: {len(data)}B CRC {status}  "
              f"rx={crc_rx.hex()} calc={crc_bytes.hex()}  "
              f"{data.hex()}  |{ascii_}|")

    return 0


if __name__ == "__main__":
    sys.exit(main())
