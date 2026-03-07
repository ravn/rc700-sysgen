#!/usr/bin/env python3
"""Live serial throughput graph for RC702 MAME serial monitor.

Reads /tmp/serial_monitor.csv (written by server.py) and displays
a live-updating terminal graph of TX/RX byte rates.

Usage:
    python3 cpnet/serial_graph.py
"""

import os
import sys
import time

LOG_FILE = "/tmp/serial_monitor.csv"
BAR_WIDTH = 24    # characters per bar
HISTORY = 24      # scrollback lines

BLOCKS = " ▏▎▍▌▋▊▉█"   # 9 levels for sub-character precision


def make_bar(value, max_val, width):
    """Render a horizontal bar using Unicode block characters."""
    if max_val <= 0 or value <= 0:
        return "░" * width
    ratio = min(value / max_val, 1.0)
    filled = ratio * width
    n_full = int(filled)
    frac = filled - n_full
    sub = int(frac * 8)
    s = "█" * n_full
    if n_full < width:
        s += BLOCKS[sub] if sub > 0 else "░"
        s += "░" * (width - n_full - 1)
    return s


def fmt_size(b):
    if b < 1024:
        return f"{b}B"
    elif b < 1048576:
        return f"{b / 1024:.1f}KB"
    else:
        return f"{b / 1048576:.1f}MB"


def main():
    last_line = 0
    total_tx = 0
    total_rx = 0
    peak_tx = 0
    peak_rx = 0
    history = []

    print(f"Waiting for {LOG_FILE} ...")
    while not os.path.exists(LOG_FILE):
        time.sleep(0.5)

    # Wait for at least a header line
    time.sleep(0.5)

    while True:
        try:
            with open(LOG_FILE, "r") as f:
                lines = f.readlines()

            # Parse new data (skip header at index 0)
            start = max(1, last_line)
            for line in lines[start:]:
                line = line.strip()
                if not line or line.startswith("second"):
                    continue
                parts = line.split(",")
                if len(parts) >= 3:
                    sec = int(parts[0])
                    tx = int(parts[1])
                    rx = int(parts[2])
                    total_tx += tx
                    total_rx += rx
                    if tx > peak_tx:
                        peak_tx = tx
                    if rx > peak_rx:
                        peak_rx = rx
                    history.append((sec, tx, rx))

            last_line = len(lines)

            # Trim history
            if len(history) > HISTORY:
                history = history[-HISTORY:]

            # Auto-scale: use peak value, minimum 100 B/s
            max_rate = max(peak_tx, peak_rx, 100)

            # Render
            sys.stdout.write("\033[H\033[J")  # clear + home

            print(
                f"\033[1mRC702 Serial Monitor\033[0m │ "
                f"TX {fmt_size(total_tx)}  RX {fmt_size(total_rx)} │ "
                f"Peak: TX {fmt_size(peak_tx)}/s  RX {fmt_size(peak_rx)}/s"
            )
            print()

            # Column headers
            w = BAR_WIDTH
            print(f"  sec  {'TX B/s':^{w + 5}}   {'RX B/s':^{w + 5}}")

            # Scale reference — use auto-scaled max
            half = max_rate // 2
            lbl0 = "0"
            lblm = str(half)
            lblx = str(max_rate)
            pad1 = w // 2 - len(lbl0) - len(lblm) // 2
            pad2 = w - w // 2 - len(lblm) // 2 - len(lblm) % 2 - len(lblx)
            scale = f"{lbl0}{'─' * max(pad1, 1)}{lblm}{'─' * max(pad2, 1)}{lblx}"
            print(f"       {scale}       {scale}")

            # Data rows
            for sec, tx, rx in history:
                tx_bar = make_bar(tx, max_rate, w)
                rx_bar = make_bar(rx, max_rate, w)
                tx_lbl = f"{tx:>5}" if tx > 0 else "    0"
                rx_lbl = f"{rx:>5}" if rx > 0 else "    0"
                print(f"  {sec:>3}  {tx_bar}{tx_lbl}   {rx_bar}{rx_lbl}")

            # Pad empty rows
            for _ in range(HISTORY - len(history)):
                empty = "░" * w
                print(f"       {empty}    0   {empty}    0")

            print()
            sys.stdout.flush()

        except (IOError, ValueError):
            pass

        time.sleep(1.0)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\033[?25h")  # restore cursor if hidden
