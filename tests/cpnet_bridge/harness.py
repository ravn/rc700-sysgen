#!/usr/bin/env python3
# license: BSD-3-Clause
"""CP/NET fast-link bring-up smoke test (MAME-side, end-to-end).

Verifies the host -> Z80 byte path of Option P
(see ../../docs/cpnet_fast_link.md):

    Python harness -> TCP localhost:4003
        -> rc702_pio_cpnet_bridge_device  (MAME slot card on PIO-B)
            -> Z80 PIO-B Mode 1 input + ISR fires
                -> isr_pio_par stores byte at 0xEA39, bumps counter at 0xEA3A
                    -> tap.lua write-tap appends to /tmp/cpnos_bridge_tap.log
                       -> harness reads the log, asserts byte sequence

Self-contained orchestration:
    1. Build cpnos-rom (incremental `make cpnos`).
    2. Build z80pack cpmsim if the binary is missing.
    3. Kill any stale process holding the MP/M TCP port.
    4. Launch z80pack-as-MP/M-master (z80pack/cpmsim/mpm-net2).
    5. Launch MAME with `-piob cpnet_bridge` + the standard CP/NET
       null_modem wiring to MP/M.
    6. Wait for tap.lua to detect the CPNOS banner.
    7. Connect to bridge :4003, send bytes, verify against tap log.
    8. Tear down both child process groups cleanly.

Usage:
    python3 harness.py                  # run the smoke test
    python3 harness.py --keep-alive     # leave processes running

Exit codes:
    0  PASS
    1  FAIL
"""

import argparse
import os
import signal
import socket
import subprocess
import sys
import time
from pathlib import Path


REPO_ROOT  = Path(__file__).resolve().parents[2]
CPNOS_DIR  = REPO_ROOT / "cpnos-rom"
Z80PACK    = REPO_ROOT / "z80pack" / "cpmsim"
MAME_DIR   = REPO_ROOT.parent / "mame"
MAME_BIN   = MAME_DIR / "regnecentralend"
LLVM_NM    = REPO_ROOT.parent / "llvm-z80" / "build-macos" / "bin" / "llvm-nm"
ROMS_DIR   = Path(os.environ.get("MAME_ROMS", Path.home() / "git" / "mame" / "roms"))
TAP_LUA    = Path(__file__).parent / "tap.lua"
PAYLOAD_ELF = CPNOS_DIR / "clang" / "payload.elf"

MPM_PORT     = 4002
BRIDGE_PORT  = 4003

READY_FILE      = Path("/tmp/cpnos_bridge_ready.txt")
TAP_LOG         = Path("/tmp/cpnos_bridge_tap.log")
ADDRS_LUA       = Path("/tmp/cpnos_bridge_addrs.lua")
MPM_LOG         = Path("/tmp/cpnos_bridge_mpm.log")
MAME_LOG        = Path("/tmp/cpnos_bridge_mame.log")
LOOPBACK_RESULT = Path("/tmp/cpnos_loopback_result.txt")

TEST_BYTES = bytes([0x55, 0xAA, 0x42, 0x00, 0xFF, 0x10])


# ---------------------------------------------------------------------------
# helpers

class Cleanup:
	"""LIFO stack of teardown callbacks."""
	def __init__(self):
		self.stack = []
	def push(self, fn):
		self.stack.append(fn)
	def run(self):
		while self.stack:
			try: self.stack.pop()()
			except Exception as e:
				print(f"[harness] cleanup error: {e}", file=sys.stderr)


def fail(msg, cleanup=None):
	print(f"FAIL: {msg}", file=sys.stderr)
	if cleanup is not None:
		cleanup.run()
	sys.exit(1)


def reset_state():
	for p in (READY_FILE, TAP_LOG, MPM_LOG, MAME_LOG, LOOPBACK_RESULT):
		try: p.unlink()
		except FileNotFoundError: pass


def port_listener_pids(port: int) -> list[int]:
	"""Return PIDs of processes currently LISTENing on `port`."""
	try:
		out = subprocess.check_output(
			["lsof", "-nP", "-iTCP", f"-iTCP:{port}", "-sTCP:LISTEN", "-Fp"],
			stderr=subprocess.DEVNULL).decode()
	except subprocess.CalledProcessError:
		return []
	pids = []
	for line in out.splitlines():
		if line.startswith("p"):
			try: pids.append(int(line[1:]))
			except ValueError: pass
	return pids


def kill_stale(port: int):
	"""Kill any process holding `port` so a fresh server can bind."""
	pids = port_listener_pids(port)
	for pid in pids:
		print(f"[harness] killing stale listener PID {pid} on :{port}")
		try: os.kill(pid, signal.SIGTERM)
		except ProcessLookupError: continue
	if pids:
		# Give them a moment to release.
		end = time.time() + 3.0
		while time.time() < end:
			if not port_listener_pids(port): return
			time.sleep(0.2)
		# SIGKILL stragglers.
		for pid in port_listener_pids(port):
			try: os.kill(pid, signal.SIGKILL)
			except ProcessLookupError: pass


def wait_for_listen(port: int, deadline_s: float):
	end = time.time() + deadline_s
	while time.time() < end:
		if port_listener_pids(port):
			return
		time.sleep(0.1)
	raise TimeoutError(f"nothing listening on :{port} after {deadline_s}s")


def run(cmd, cwd=None, check=True) -> subprocess.CompletedProcess:
	print(f"[harness] $ {' '.join(str(c) for c in cmd)}"
	      f"{' (in ' + str(cwd) + ')' if cwd else ''}")
	return subprocess.run(cmd, cwd=cwd, check=check)


def spawn_group(cmd, cwd=None, log_path=None):
	"""Spawn a child in its own process group so we can SIGTERM the
	whole tree on cleanup (kills shell wrappers + their children)."""
	stdout = open(log_path, "w") if log_path else subprocess.DEVNULL
	print(f"[harness] $ {' '.join(str(c) for c in cmd)}"
	      f"{' (in ' + str(cwd) + ')' if cwd else ''}"
	      f"{' -> ' + str(log_path) if log_path else ''}")
	return subprocess.Popen(cmd, cwd=cwd, stdout=stdout,
		stderr=subprocess.STDOUT, start_new_session=True)


def kill_group(p: subprocess.Popen):
	if p.poll() is not None:
		return
	try: os.killpg(p.pid, signal.SIGTERM)
	except ProcessLookupError: return
	try: p.wait(timeout=3.0)
	except subprocess.TimeoutExpired:
		try: os.killpg(p.pid, signal.SIGKILL)
		except ProcessLookupError: pass


# ---------------------------------------------------------------------------
# build steps

def ensure_cpnos_built():
	"""Run `make cpnos-install` so the freshly built PROMs land in MAME's
	rom directory and cpnos.com lands on the MP/M test disks.  Just `make
	cpnos` only builds artefacts in clang/; MAME would then boot stale
	PROM bytes from a previous install."""
	run(["make", "-s", "cpnos-install"], cwd=str(CPNOS_DIR))


def ensure_cpmsim_built():
	cpmsim_bin = Z80PACK / "cpmsim"
	if cpmsim_bin.exists() and os.access(cpmsim_bin, os.X_OK):
		return
	srcsim = Z80PACK / "srcsim"
	if not srcsim.exists():
		fail(f"{srcsim} missing — z80pack submodule not initialised")
	# z80pack/cpmsim/srcsim/Makefile knows how to produce ../cpmsim.
	run(["make"], cwd=str(srcsim))


def emit_addrs_lua():
	"""Extract BSS addresses from the freshly built payload.elf and write
	them as a Lua table tap.lua dofile()s.  Avoids the silent-drift trap
	that hardcoded addresses caused before.

	Required symbols: _pio_par_byte, _pio_par_count (host-send mode).
	Optional symbols: _pio_test_done, _pio_test_recv (loopback mode —
	only present when cpnos was built with PIO_LOOPBACK_TEST=1).
	"""
	out = subprocess.check_output(
		[str(LLVM_NM), str(PAYLOAD_ELF)]).decode()
	required = {"_pio_par_byte", "_pio_par_count"}
	optional = {"_pio_test_done", "_pio_test_recv"}
	found = {}
	for line in out.splitlines():
		parts = line.split()
		if len(parts) >= 3 and parts[2] in required | optional:
			found[parts[2]] = int(parts[0], 16)
	missing = required - found.keys()
	if missing:
		fail(f"symbols not found in {PAYLOAD_ELF}: {sorted(missing)}")
	lines = [
		"return {",
		f"  pio_par_byte  = 0x{found['_pio_par_byte']:04X},",
		f"  pio_par_count = 0x{found['_pio_par_count']:04X},",
	]
	if "_pio_test_done" in found and "_pio_test_recv" in found:
		lines.append(f"  pio_test_done = 0x{found['_pio_test_done']:04X},")
		lines.append(f"  pio_test_recv = 0x{found['_pio_test_recv']:04X},")
	lines.append("}")
	ADDRS_LUA.write_text("\n".join(lines) + "\n")
	print(f"[harness] addrs: " +
	      ", ".join(f"{k}=0x{v:04X}" for k, v in sorted(found.items())))
	return found


def free_bridge_port_in_mpm_conf():
	"""z80pack's cpmsim/conf/net_server.conf binds consoles 1..4 to TCP
	ports 4000..4003 — console 4 collides with MAME's cpnet_bridge
	(default :4003).  Rewrite the conf to drop console 4 for the test
	run; restore on cleanup so the submodule isn't left modified.
	Returns the restore callback."""
	conf = Z80PACK / "conf" / "net_server.conf"
	original = conf.read_text()
	pruned = "\n".join(
		line for line in original.splitlines()
		if not line.lstrip().startswith("4\t"))
	if pruned != original:
		conf.write_text(pruned + "\n")
		print(f"[harness] dropped console 4 from {conf} for the test run")
	return lambda: conf.write_text(original)


def warn_ndos_freshness():
	"""NDOS lives inside z80pack/cpmsim/disks/library/mpm-net2-1.dsk.
	If cpnos-rom build artefacts are newer than the .dsk file, the
	NDOS on the disk may be out of date for the slave's expectations.
	Print a warning; don't auto-rebuild — that's a separate workflow
	the user manages."""
	dsk = Z80PACK / "disks" / "library" / "mpm-net2-1.dsk"
	cpnos = CPNOS_DIR / "clang" / "cpnos.bin"
	if not dsk.exists() or not cpnos.exists():
		return
	if cpnos.stat().st_mtime > dsk.stat().st_mtime + 5:
		print(f"[harness] WARNING: {dsk} is older than fresh cpnos.bin; "
		      f"NDOS on the MP/M disk may be stale.  Rebuild that disk "
		      f"if the test fails with a NDOS-side error.")


# ---------------------------------------------------------------------------
# test bodies

def parse_taps(text):
	"""Parse tap.lua's count/byte log lines into (count, byte) tuples."""
	out = []
	for line in text.splitlines():
		try:
			parts = dict(p.split("=") for p in line.split())
			out.append((int(parts["count"]), int(parts["byte"], 16)))
		except (ValueError, KeyError):
			pass
	return out


def run_hostsend_test(cleanup):
	"""Original test: harness sends 6 bytes -> Z80 ISR -> verify count + last."""
	pre_taps = parse_taps(TAP_LOG.read_text() if TAP_LOG.exists() else "")
	print(f"[harness] {len(pre_taps)} pre-existing tap entries; "
	      f"will look for new entries after byte send")

	print("[harness] step 8: connect to bridge, send bytes")
	try:
		bridge = socket.create_connection(("127.0.0.1", BRIDGE_PORT),
			timeout=2.0)
	except OSError as e:
		fail(f"bridge :{BRIDGE_PORT} connect failed: {e}", cleanup)

	print(f"[harness] sending {len(TEST_BYTES)} bytes: {TEST_BYTES.hex()}")
	bridge.sendall(TEST_BYTES)
	bridge.close()

	# Verify: net count advanced by len(TEST_BYTES), last observed
	# byte == TEST_BYTES[-1].  Intermediate bytes 1..N-1 are lost
	# to the Lua tap's ~50 Hz polling rate (all ISR fires happen
	# within a single video frame at -nothrottle), so we cannot
	# observe per-byte ordering here.  Ordering is implicit from
	# the bridge's std::deque FIFO discipline (cpnet_bridge.cpp).
	print("[harness] step 9: verify tap log (net count + last byte)")
	expected_delta = len(TEST_BYTES)
	expected_last  = TEST_BYTES[-1]
	end = time.time() + 10.0
	new_taps = []
	while time.time() < end:
		all_taps = parse_taps(
			TAP_LOG.read_text() if TAP_LOG.exists() else "")
		new_taps = all_taps[len(pre_taps):]
		if new_taps:
			latest_count = new_taps[-1][0]
			pre_count = pre_taps[-1][0] if pre_taps else 0
			if (latest_count - pre_count) % 256 >= expected_delta:
				break
		time.sleep(0.1)

	if not new_taps:
		fail(f"no new tap lines (pre-send had {len(pre_taps)})", cleanup)

	latest_count, latest_byte = new_taps[-1]
	pre_count = pre_taps[-1][0] if pre_taps else 0
	actual_delta = (latest_count - pre_count) % 256
	if actual_delta < expected_delta:
		fail(f"counter advanced by {actual_delta}, expected "
		     f"{expected_delta} (pre={pre_count}, latest={latest_count})",
		     cleanup)
	if latest_byte != expected_last:
		fail(f"latest byte=0x{latest_byte:02X}, want 0x{expected_last:02X}",
		     cleanup)

	print(f"PASS: {expected_delta} bytes reached Z80 isr_pio_par "
	      f"(count {pre_count}->{latest_count}, last byte "
	      f"0x{latest_byte:02X})")


def run_loopback_test(cleanup):
	"""Loopback test: Z80 sends 6 bytes via PIO-B Mode 0, harness reads
	them off :4003 and writes them back, Z80 reads from its ring buffer
	via PIO-B Mode 1.  Verify pio_test_recv[6] (logged by tap.lua to
	LOOPBACK_RESULT) equals the bytes the harness received."""
	print("[harness] step 8a: connect to bridge, expect 6 bytes from Z80")
	try:
		bridge = socket.create_connection(("127.0.0.1", BRIDGE_PORT),
			timeout=2.0)
	except OSError as e:
		fail(f"bridge :{BRIDGE_PORT} connect failed: {e}", cleanup)

	# Z80 fires pio_loopback_test() after netboot completes (~5s
	# emulated, well under 1 wall-second at 1400% speed).  Step 7
	# already slept 5s before this, so the bytes should be queued
	# in the bridge's z80_to_host FIFO already.
	bridge.settimeout(10.0)
	received = bytearray()
	try:
		while len(received) < 6:
			chunk = bridge.recv(6 - len(received))
			if not chunk:
				break
			received.extend(chunk)
	except socket.timeout:
		fail(f"timed out waiting for Z80 bytes "
		     f"(got {len(received)}/6: {bytes(received).hex()})", cleanup)
	if len(received) != 6:
		fail(f"received {len(received)} bytes from Z80, expected 6: "
		     f"{bytes(received).hex()}", cleanup)
	print(f"[harness] received from Z80: {bytes(received).hex()}")

	print("[harness] step 8b: echo bytes back to Z80")
	bridge.sendall(bytes(received))
	bridge.close()

	print("[harness] step 9: wait for Z80 loopback to complete")
	end = time.time() + 10.0
	while time.time() < end:
		if LOOPBACK_RESULT.exists():
			break
		time.sleep(0.1)
	if not LOOPBACK_RESULT.exists():
		fail(f"{LOOPBACK_RESULT} never appeared — Z80 loopback test "
		     f"didn't complete (check {MAME_LOG} for boot trace)", cleanup)

	got_hex = LOOPBACK_RESULT.read_text().strip()
	expected_hex = bytes(received).hex().upper()
	if got_hex != expected_hex:
		fail(f"pio_test_recv = {got_hex}, expected {expected_hex} "
		     f"(bytes Z80 received != bytes Z80 sent)", cleanup)

	print(f"PASS: Z80 loopback round-trip (sent {expected_hex}, "
	      f"echoed back, received {got_hex})")


# ---------------------------------------------------------------------------
# main

def main():
	ap = argparse.ArgumentParser(description=__doc__,
		formatter_class=argparse.RawDescriptionHelpFormatter)
	ap.add_argument("--keep-alive", action="store_true",
		help="leave processes running for manual poking")
	ap.add_argument("--mame-bin", default=str(MAME_BIN))
	ap.add_argument("--roms", default=str(ROMS_DIR))
	ap.add_argument("--boot-timeout", type=float, default=60.0,
		help="how long to wait for CPNOS banner (default 60s)")
	ap.add_argument("--mame-seconds", type=int, default=120,
		help="MAME -seconds_to_run (default 120)")
	ap.add_argument("--mode", choices=("hostsend", "loopback"),
		default="hostsend",
		help="hostsend: harness sends 6 bytes -> Z80 ISR; "
		     "loopback: Z80 sends 6 bytes -> harness echoes -> Z80 reads")
	args = ap.parse_args()

	mame = Path(args.mame_bin)
	if not mame.exists():
		fail(f"{mame} not found — build ravn/mame:cpnet-fast-link first")
	if not TAP_LUA.exists():
		fail(f"{TAP_LUA} missing")
	netboot_py = CPNOS_DIR / "netboot_server.py"
	if not netboot_py.exists():
		fail(f"{netboot_py} missing — cpnos-rom layout changed?")

	cleanup = Cleanup()

	try:
		print("[harness] step 1: ensure cpnos-rom built")
		ensure_cpnos_built()

		print("[harness] step 1b: extract live BSS addrs into addrs.lua")
		addrs = emit_addrs_lua()
		if args.mode == "loopback":
			missing = {"_pio_test_done", "_pio_test_recv"} - addrs.keys()
			if missing:
				fail(f"loopback mode requires PIO_LOOPBACK_TEST=1 build "
				     f"(missing symbols: {sorted(missing)})")

		print(f"[harness] step 4: kill stale listener on :{MPM_PORT}")
		kill_stale(MPM_PORT)
		# Bridge port is bound by MAME's rc702_state directly (osd_file
		# socket, no slot card) — but kill any straggler just in case.
		kill_stale(BRIDGE_PORT)

		reset_state()

		# netboot_server.py is the synthetic CP/NET responder that
		# cpnos-netboot uses; mpm-net2 is the real-but-slow MP/M which
		# does not currently boot cpnos-rom in MAME within the test
		# window (verified 2026-04-26 — black screen against mpm-net2,
		# clean banner against netboot_server.py).
		print(f"[harness] step 5: launch netboot_server.py (-> :{MPM_PORT})")
		mpm = spawn_group(["python3", "-u", str(netboot_py), str(MPM_PORT)],
		                  cwd=str(CPNOS_DIR), log_path=MPM_LOG)
		cleanup.push(lambda: kill_group(mpm) if not args.keep_alive else None)

		try:
			wait_for_listen(MPM_PORT, deadline_s=10.0)
		except TimeoutError as e:
			fail(f"MP/M did not start: {e}; see {MPM_LOG}", cleanup)

		# SIO-B sink: mirror cpnos-netboot Makefile target which spawns
		# sio_b_driver.py.  Without it, MAME's rs232b null_modem has no
		# host connection and cpnos-rom hangs early in boot (verified
		# 2026-04-26: -rs232a only -> "client closed waiting for ENQ").
		SIOB_PORT = 9001
		print(f"[harness] step 5b: launch sio_b_driver.py (-> :{SIOB_PORT})")
		kill_stale(SIOB_PORT)
		siob_py = CPNOS_DIR / "sio_b_driver.py"
		siob = spawn_group(["python3", "-u", str(siob_py), str(SIOB_PORT)],
		                   cwd=str(CPNOS_DIR), log_path=Path("/tmp/cpnos_bridge_siob.log"))
		cleanup.push(lambda: kill_group(siob) if not args.keep_alive else None)
		wait_for_listen(SIOB_PORT, deadline_s=5.0)

		print("[harness] step 6: launch MAME with -piob cpnet_bridge")
		mame_p = spawn_group([
			str(mame), "rc702",
			"-rompath", args.roms,
			"-nothrottle",
			"-window",
			"-skip_gameinfo",
			"-log",
			"-seconds_to_run", str(args.mame_seconds),
			"-rs232a", "null_modem",
			"-bitb1", f"socket.127.0.0.1:{MPM_PORT}",
			"-rs232b", "null_modem",
			"-bitb2", f"socket.127.0.0.1:{SIOB_PORT}",
			"-piob", "cpnet_bridge",
			"-autoboot_script", str(TAP_LUA),
		], log_path=MAME_LOG, cwd=str(MAME_DIR))
		cleanup.push(lambda: kill_group(mame_p) if not args.keep_alive else None)

		# Step 7: wait until rc702_state's machine_start opens the
		# osd_file listening socket on :4003.  That happens during MAME
		# init, well before cpnos-rom enables interrupts.  We don't need
		# cpnos-rom to be "ready" — any pre-EI byte will sit in the rx
		# queue and get strobed in the moment cpnos_main calls
		# enable_interrupts() and BRDY rises.
		print(f"[harness] step 7: wait for bridge listener on :{BRIDGE_PORT}")
		try:
			wait_for_listen(BRIDGE_PORT, deadline_s=15.0)
		except TimeoutError as e:
			fail(f"cpnet_bridge did not bind :{BRIDGE_PORT}: {e} "
			     f"(see {MAME_LOG} for socket errors)", cleanup)

		if args.mode == "hostsend":
			# Give cpnos-rom a chance to actually call enable_interrupts.
			# This requires netboot to complete: ~1-3 emulated seconds
			# at ~1400% speed = <1 wall second.  Pad to 5s for safety.
			time.sleep(5.0)
			run_hostsend_test(cleanup)
		else:
			# Loopback: connect immediately and let recv block.  Z80
			# sends 6 bytes a few hundred ms wall-clock after MAME
			# launch.  At ~1400% speed Z80's per-byte recv timeout
			# (~60 ms emulated = ~4 ms wall) is too short to wait for
			# the harness, so we must echo before Z80 enters its
			# recv loop — connecting straight away maximises the
			# wall-clock budget on the host side.
			run_loopback_test(cleanup)

	finally:
		if not args.keep_alive:
			cleanup.run()


if __name__ == "__main__":
	main()
