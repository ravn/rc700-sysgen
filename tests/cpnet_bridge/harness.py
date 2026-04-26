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

READY_FILE = Path("/tmp/cpnos_bridge_ready.txt")
TAP_LOG    = Path("/tmp/cpnos_bridge_tap.log")
ADDRS_LUA  = Path("/tmp/cpnos_bridge_addrs.lua")
MPM_LOG    = Path("/tmp/cpnos_bridge_mpm.log")
MAME_LOG   = Path("/tmp/cpnos_bridge_mame.log")

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
	for p in (READY_FILE, TAP_LOG, MPM_LOG, MAME_LOG):
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
	"""Extract pio_par_byte / pio_par_count BSS addresses from the freshly
	built payload.elf and write them as a Lua table tap.lua dofile()s.
	Avoids the silent-drift trap that hardcoded addresses caused before."""
	out = subprocess.check_output(
		[str(LLVM_NM), str(PAYLOAD_ELF)]).decode()
	wanted = {"_pio_par_byte": None, "_pio_par_count": None}
	for line in out.splitlines():
		parts = line.split()
		if len(parts) >= 3 and parts[2] in wanted:
			wanted[parts[2]] = int(parts[0], 16)
	missing = [k for k, v in wanted.items() if v is None]
	if missing:
		fail(f"symbols not found in {PAYLOAD_ELF}: {missing}")
	ADDRS_LUA.write_text(
		"return {{ pio_par_byte = 0x{:04X}, pio_par_count = 0x{:04X} }}\n"
		.format(wanted["_pio_par_byte"], wanted["_pio_par_count"]))
	print(f"[harness] addrs: pio_par_byte=0x{wanted['_pio_par_byte']:04X}  "
	      f"pio_par_count=0x{wanted['_pio_par_count']:04X}  "
	      f"-> {ADDRS_LUA}")


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
	args = ap.parse_args()

	mame = Path(args.mame_bin)
	if not mame.exists():
		fail(f"{mame} not found — build ravn/mame:cpnet-fast-link first")
	if not TAP_LUA.exists():
		fail(f"{TAP_LUA} missing")
	if not (Z80PACK / "mpm-net2").exists():
		fail(f"{Z80PACK / 'mpm-net2'} missing — z80pack submodule incomplete")

	cleanup = Cleanup()

	try:
		print("[harness] step 1: ensure cpnos-rom built")
		ensure_cpnos_built()

		print("[harness] step 1b: extract live BSS addrs into addrs.lua")
		emit_addrs_lua()

		print("[harness] step 2: ensure cpmsim built")
		ensure_cpmsim_built()

		print("[harness] step 3: warn on NDOS freshness")
		warn_ndos_freshness()

		print(f"[harness] step 4: kill stale listener on :{MPM_PORT}")
		kill_stale(MPM_PORT)
		# Bridge port is bound by MAME's cpnet_bridge device, not by a
		# leftover process — but kill any straggler just in case.
		kill_stale(BRIDGE_PORT)

		reset_state()

		print(f"[harness] step 5: launch z80pack MP/M (-> :{MPM_PORT})")
		restore_conf = free_bridge_port_in_mpm_conf()
		cleanup.push(restore_conf)
		mpm = spawn_group(["./mpm-net2"], cwd=str(Z80PACK), log_path=MPM_LOG)
		cleanup.push(lambda: kill_group(mpm) if not args.keep_alive else None)

		try:
			wait_for_listen(MPM_PORT, deadline_s=10.0)
		except TimeoutError as e:
			fail(f"MP/M did not start: {e}; see {MPM_LOG}", cleanup)

		print("[harness] step 6: launch MAME with -piob cpnet_bridge")
		mame_p = spawn_group([
			str(mame), "rc702",
			"-rompath", args.roms,
			"-nothrottle",
			"-window",
			"-skip_gameinfo",
			"-seconds_to_run", str(args.mame_seconds),
			"-rs232a", "null_modem",
			"-bitb1", f"socket.127.0.0.1:{MPM_PORT}",
			"-piob", "cpnet_bridge",
			"-autoboot_script", str(TAP_LUA),
		], log_path=MAME_LOG)
		cleanup.push(lambda: kill_group(mame_p) if not args.keep_alive else None)

		# Step 7: wait until the cpnet_bridge MAME slot card binds :4003.
		# That happens during MAME machine_start, well before cpnos-rom
		# enables interrupts.  We don't need cpnos-rom to be "ready" —
		# any pre-EI byte will sit in PIO-B's input latch and fire the
		# ISR the moment cpnos_main calls enable_interrupts().
		print(f"[harness] step 7: wait for bridge listener on :{BRIDGE_PORT}")
		try:
			wait_for_listen(BRIDGE_PORT, deadline_s=15.0)
		except TimeoutError as e:
			fail(f"cpnet_bridge did not bind :{BRIDGE_PORT}: {e} "
			     f"(see {MAME_LOG} for socket errors)", cleanup)

		# Give cpnos-rom a chance to actually call enable_interrupts.
		# This requires netboot to complete: ~1-3 emulated seconds at
		# 1400% speed = <1 wall second.  Pad to 5s for safety.
		time.sleep(5.0)

		# Snapshot the tap log before sending so we can isolate just the
		# new tap entries that result from our bytes.  Bring-up may
		# produce spurious fires (PIO-B startup state, MAME slot pulse
		# behaviour); the truth-test is "the bytes I just sent appeared
		# in order".
		def parse_taps(text):
			out = []
			for line in text.splitlines():
				try:
					parts = dict(p.split("=") for p in line.split())
					out.append((int(parts["count"]), int(parts["byte"], 16)))
				except (ValueError, KeyError):
					pass
			return out

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

		print("[harness] step 9: verify tap log")
		expected = len(TEST_BYTES)
		end = time.time() + 10.0
		new_taps = []
		while time.time() < end:
			all_taps = parse_taps(
				TAP_LOG.read_text() if TAP_LOG.exists() else "")
			new_taps = all_taps[len(pre_taps):]
			if len(new_taps) >= expected:
				break
			time.sleep(0.1)

		if len(new_taps) < expected:
			fail(f"saw {len(new_taps)} new tap line(s); expected {expected} "
			     f"(pre-send had {len(pre_taps)})", cleanup)

		for i, (count, got) in enumerate(new_taps[:expected]):
			want = TEST_BYTES[i]
			if got != want:
				fail(f"new tap {i}: byte=0x{got:02X}, want 0x{want:02X}", cleanup)

		print(f"PASS: {expected} bytes round-tripped through bridge "
		      f"-> Z80 isr_pio_par")

	finally:
		if not args.keep_alive:
			cleanup.run()


if __name__ == "__main__":
	main()
