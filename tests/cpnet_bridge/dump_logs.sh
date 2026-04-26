#!/bin/bash
# Quick hex-dump of the CP/NET PIO-B bridge log files written by MAME's
# rc702 driver during a test run.  See docs/cpnet_pio_direct_design.md.
set -eu

for f in /tmp/cpnet_pio_rx.bin /tmp/cpnet_pio_tx.bin; do
	echo "--- $f ($(wc -c < "$f" 2>/dev/null || echo 0) bytes) ---"
	if [ -s "$f" ]; then
		hexdump -C "$f" | head -60
	else
		echo "(empty or missing)"
	fi
done
