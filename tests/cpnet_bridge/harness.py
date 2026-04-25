#!/usr/bin/env python3
# license: BSD-3-Clause
"""CP/NET fast-link bring-up smoke test (MAME-side, end-to-end).

Verifies the host -> Z80 byte path of Option P
(see ../../docs/cpnet_fast_link.md):

    Python -> TCP localhost:4003
        -> rc702_pio_cpnet_bridge_device (MAME slot card on PIO-B)
            -> Z80 PIO-B Mode 1 input + ISR fires
                -> isr_pio_par stores byte at 0xEA39, bumps counter at 0xEA3A
                    -> tap.lua write-tap on the counter prints
                       "[tap] count=N byte=0xHH" to MAME stdout

The harness sends a known byte sequence over the bridge socket and
matches MAME's stdout against the expected count/byte progression.

Prerequisites:
- ravn/mame:cpnet-fast-link built as `regnecentralend` in /Users/ravn/z80/mame.
- cpnos-rom built (`make cpnos` in cpnos-rom/) so isr_pio_par is in the
  payload.
- A working CP/NET netboot path (z80pack MP/M master on :4002) so cpnos-rom
  actually loads in MAME — without it the Z80 sits in the autoload PROM
  and never executes init_hardware() to set up PIO-B.

Usage:
    python3 harness.py                    # run the smoke test
    python3 harness.py --keep-alive       # leave MAME running for poking

Exit codes:
    0  PASS
    1  FAIL (timeout, connection refused, byte mismatch, etc.)
"""

import argparse
import os
import socket
import subprocess
import sys
import time
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
MAME_DIR  = REPO_ROOT.parent / "mame"
MAME_BIN  = MAME_DIR / "regnecentralend"
ROMS_DIR  = Path(os.environ.get("MAME_ROMS", Path.home() / "git" / "mame" / "roms"))
TAP_LUA   = Path(__file__).parent / "tap.lua"

BRIDGE_HOST = "127.0.0.1"
BRIDGE_PORT = 4003

# Bytes to send through the bridge.  Chosen to be observable on the
# Z80 side (each value distinct, easy to scan in the tap output).
TEST_BYTES = bytes([0x55, 0xAA, 0x42, 0x00, 0xFF, 0x10])


def fail(msg):
	print(f"FAIL: {msg}", file=sys.stderr)
	sys.exit(1)


def wait_for_bridge(deadline_s: float) -> socket.socket:
	"""Connect to the MAME bridge socket; retry until deadline."""
	end = time.time() + deadline_s
	last_err = None
	while time.time() < end:
		try:
			s = socket.create_connection((BRIDGE_HOST, BRIDGE_PORT), timeout=1.0)
			return s
		except (ConnectionRefusedError, socket.timeout, OSError) as e:
			last_err = e
			time.sleep(0.2)
	fail(f"could not connect to {BRIDGE_HOST}:{BRIDGE_PORT} within "
	     f"{deadline_s}s ({last_err})")


def main():
	ap = argparse.ArgumentParser(description=__doc__,
		formatter_class=argparse.RawDescriptionHelpFormatter)
	ap.add_argument("--keep-alive", action="store_true",
		help="leave MAME running after the byte send (for manual poking)")
	ap.add_argument("--mame-bin", default=str(MAME_BIN),
		help=f"path to MAME binary (default: {MAME_BIN})")
	ap.add_argument("--roms", default=str(ROMS_DIR),
		help=f"MAME roms path (default: {ROMS_DIR})")
	ap.add_argument("--seconds", type=float, default=20.0,
		help="how long to run MAME before declaring timeout (default 20s)")
	args = ap.parse_args()

	mame = Path(args.mame_bin)
	if not mame.exists():
		fail(f"{mame} not found — build ravn/mame:cpnet-fast-link first "
		     f"(see docs/MAME_RC702.md for the make command)")
	if not TAP_LUA.exists():
		fail(f"{TAP_LUA} missing")

	cmd = [str(mame), "rc702",
		"-rompath", args.roms,
		"-piob", f"cpnet_bridge",
		"-window",
		"-skip_gameinfo",
		"-nothrottle",
		"-autoboot_script", str(TAP_LUA),
		"-seconds_to_run", str(int(args.seconds)),
	]
	print(f"[harness] launching MAME: {' '.join(cmd)}")
	proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
		text=True, bufsize=1)

	try:
		# Wait for the bridge to bind.  The cpnet_bridge_device's
		# device_start() runs early in MAME's machine_config processing,
		# so the socket is up well before the Z80 has booted.
		print(f"[harness] waiting for bridge on {BRIDGE_HOST}:{BRIDGE_PORT}")
		bridge = wait_for_bridge(deadline_s=args.seconds)
		print(f"[harness] connected; sending {len(TEST_BYTES)} bytes: "
		      f"{TEST_BYTES.hex()}")
		bridge.sendall(TEST_BYTES)

		# At this point the Z80 may or may not have booted into cpnos-rom.
		# In MAME-with-no-CP/NET-server, the autoload PROM will hang
		# waiting for the netboot path — isr_pio_par won't fire because
		# IM2 isn't enabled until cpnos-rom's resident_entry runs.
		# So this harness's "tap printed" assertion only succeeds in a
		# fully wired MAME + z80pack environment.

		print(f"[harness] reading MAME stdout for {args.seconds}s "
		      f"(looking for [tap] lines)")
		start = time.time()
		taps = []
		while time.time() - start < args.seconds:
			line = proc.stdout.readline()
			if not line:
				break
			line = line.rstrip("\n")
			print(f"[mame] {line}")
			if "[tap]" in line and "count=" in line:
				taps.append(line)
				if len(taps) >= len(TEST_BYTES):
					break

		expected_n = len(TEST_BYTES)
		if len(taps) < expected_n:
			fail(f"saw {len(taps)} tap line(s); expected {expected_n}")

		# Verify the last byte of each tap matches the corresponding sent byte.
		for i, line in enumerate(taps[:expected_n]):
			# format: "[tap] count=N byte=0xHH"
			parts = line.split()
			byte_field = next((p for p in parts if p.startswith("byte=")), None)
			if not byte_field:
				fail(f"tap line {i}: no byte= field in {line!r}")
			got = int(byte_field.split("=")[1], 16)
			want = TEST_BYTES[i]
			if got != want:
				fail(f"tap line {i}: byte=0x{got:02X}, expected 0x{want:02X}")

		print(f"PASS: {expected_n} bytes round-tripped through the MAME bridge")
		bridge.close()

	finally:
		if not args.keep_alive:
			proc.terminate()
			try:
				proc.wait(timeout=5)
			except subprocess.TimeoutExpired:
				proc.kill()


if __name__ == "__main__":
	main()
