#!/bin/bash
# Launch CP/NET test: server.py + MAME with null_modem serial.
#
# Always starts from a clean reference disk, builds SNIOS.SPR + CHKSUM.COM,
# patches the BIOS, and injects all required files before launching MAME.
#
# The MAME window provides the CP/M console (CRT + keyboard).
# The serial port (null_modem TCP) carries CP/NET traffic.
# server.py handles CP/NET requests from the SNIOS.
#
# Usage:
#   bash cpnet/run_test.sh [--auto] [--headless] [--drive-dir LETTER DIR]
#
# Options:
#   --auto      Automated mode: Lua script types commands and reads results
#   --headless  Run MAME without display (for CI / automated testing)
#
# Prerequisites:
#   - MAME regnecentralen subtarget built
#   - ~/Downloads/SW1711-I8.imd (reference 8" MAXI disk image)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
MAME_DIR="${HOME}/git/mame"
SERIAL_PORT=4321
WORK_IMAGE="/tmp/cpnet_test.imd"
CPNET_DIR="/tmp/cpnet_files"
RESULT_FILE="/tmp/cpnet_test_results.txt"
SERVER_ERROR_FILE="/tmp/cpnet_server_errors.txt"
PRINTER_FILE="/tmp/cpnet_printer.out"
REFERENCE_IMAGE="${HOME}/Downloads/SW1711-I8.imd"

AUTO_MODE=false
HEADLESS=false
SETUP_MODE=false
SERIAL_TRANSFER=false
INJECT=false
FAST=false
GDB_MODE=false
CONSOLE_MODE=false
SERVER_ARGS=()

# ── Parse arguments ──
while [[ $# -gt 0 ]]; do
    case "$1" in
        --auto)
            AUTO_MODE=true
            shift
            ;;
        --headless)
            HEADLESS=true
            AUTO_MODE=true  # headless implies auto
            shift
            ;;
        --setup)
            SETUP_MODE=true
            shift
            ;;
        --serial-transfer)
            SERIAL_TRANSFER=true
            shift
            ;;
        --inject)
            INJECT=true
            shift
            ;;
        --fast)
            FAST=true
            shift
            ;;
        --gdb)
            GDB_MODE=true
            shift
            ;;
        --console)
            CONSOLE_MODE=true
            shift
            ;;
        *)
            SERVER_ARGS+=("$1")
            shift
            ;;
    esac
done

# Console mode requires inject (NDOS bypasses MAME keyboard after CPNETLDR)
if $CONSOLE_MODE; then
    INJECT=true
    if ! $AUTO_MODE; then SETUP_MODE=true; fi
fi

# Default: serial transfer if neither flag given
if ! $SERIAL_TRANSFER && ! $INJECT; then SERIAL_TRANSFER=true; fi

# Default drive mapping if none specified
if [[ ${#SERVER_ARGS[@]} -eq 0 ]]; then
    mkdir -p "$CPNET_DIR"
    echo "Hello from CP/NET server!" > "$CPNET_DIR/HELLO.TXT"
    echo "This is a test file." > "$CPNET_DIR/TEST.TXT"
    # Create a 200KB test file for large-file transfer testing
    if [ ! -f "$CPNET_DIR/BIGFILE.DAT" ]; then
        python3 -c "
import os, random
random.seed(42)
data = bytes(random.randrange(256) for _ in range(200 * 1024))
open('$CPNET_DIR/BIGFILE.DAT', 'wb').write(data)
print('Created BIGFILE.DAT (200KB)')
"
    fi
    # Provide CP/NET utility .COM files on the network drive
    CPNET_Z80_DIST="${HOME}/git/cpnet-z80/dist"
    for f in "$CPNET_Z80_DIST"/*.com; do
        UPPER=$(basename "$f" | tr '[:lower:]' '[:upper:]')
        cp "$f" "$CPNET_DIR/$UPPER"
    done
    SERVER_ARGS=(--drive-dir B "$CPNET_DIR")
fi

# ── Clean up stale output files from previous test runs ──
rm -f "$CPNET_DIR/HLCOPY2.TXT" "$CPNET_DIR/BIGCOPY2."'$01'

# ── Find MAME ──
if $GDB_MODE; then
    MAME="${MAME_DIR}/regnecentralend"
    if [ ! -x "$MAME" ]; then
        echo "ERROR: GDB mode requires debug MAME build (regnecentralend)"
        exit 1
    fi
else
    MAME="${MAME_DIR}/regnecentralend"
    if [ ! -x "$MAME" ]; then
        MAME="${MAME_DIR}/regnecentralen"
    fi
    if [ ! -x "$MAME" ]; then
        echo "ERROR: MAME binary not found"
        exit 1
    fi
fi

# ── Known file locations ──
SNIOS_SPR="${SCRIPT_DIR}/zout/SNIOS.SPR"
NDOS_SPR="${HOME}/git/cpnet-z80/dist/ndos.spr"
CPNETLDR_COM="${HOME}/git/cpnet-z80/dist/cpnetldr.com"
CCP_SPR="${HOME}/git/cpnet-z80/dist/ccp.spr"
NETWORK_COM="${HOME}/git/cpnet-z80/dist/network.com"
CHKSUM_CIM="${SCRIPT_DIR}/zout/chksum.cim"
ZMAC="${PROJECT_DIR}/zmac/bin/zmac"
BIOS_CIM="${PROJECT_DIR}/rcbios-in-c/bios.cim"

# ── Always start from a clean reference disk ──
if [ ! -f "$REFERENCE_IMAGE" ]; then
    echo "ERROR: Reference image ${REFERENCE_IMAGE} not found"
    echo "Get it from https://datamuseum.dk/wiki/Bits:RC/RC700 or similar"
    exit 1
fi
echo "Creating fresh disk image from reference..."
cp "$REFERENCE_IMAGE" "$WORK_IMAGE"

# ── Build SNIOS.SPR ──
echo "Building SNIOS.SPR..."
python3 "${SCRIPT_DIR}/build_snios.py"

# ── Build CHKSUM.COM ──
echo "Building CHKSUM.COM..."
"$ZMAC" -z "${SCRIPT_DIR}/chksum.asm" -o "$CHKSUM_CIM"

# ── Build BIOS and patch disk ──
echo "Building C-BIOS (MAXI, 38400 baud)..."
make -C "${PROJECT_DIR}/rcbios-in-c" bios --no-print-directory
echo "Patching C-BIOS onto disk image..."
python3 "${PROJECT_DIR}/rcbios/patch_bios.py" "$WORK_IMAGE" "$BIOS_CIM"

if $SERIAL_TRANSFER; then
    # ── Convert all CP/NET binaries to Intel HEX, stage in /tmp for Lua to read ──
    # The autotest Lua script types hex content into CP/M via PIP CON:, then
    # LOAD converts each .HEX to binary. No files are injected into the disk image.
    echo "Converting CP/NET files to Intel HEX..."
    HEX_STAGE="/tmp/cpnet_hex"
    mkdir -p "$HEX_STAGE"
    python3 "${SCRIPT_DIR}/bin2ihex.py" "$CCP_SPR"      -o "${HEX_STAGE}/CCP.HEX"
    python3 "${SCRIPT_DIR}/bin2ihex.py" "$SNIOS_SPR"    -o "${HEX_STAGE}/SNIOS.HEX"
    python3 "${SCRIPT_DIR}/bin2ihex.py" "$NDOS_SPR"     -o "${HEX_STAGE}/NDOS.HEX"
    python3 "${SCRIPT_DIR}/bin2ihex.py" "$CPNETLDR_COM" -o "${HEX_STAGE}/CPNETLDR.HEX"
    python3 "${SCRIPT_DIR}/bin2ihex.py" "$NETWORK_COM"  -o "${HEX_STAGE}/NETWORK.HEX"
    python3 "${SCRIPT_DIR}/bin2ihex.py" "$CHKSUM_CIM"   -o "${HEX_STAGE}/CHKSUM.HEX"
    echo "Hex files staged in ${HEX_STAGE}/"
fi

if $INJECT; then
    echo "Injecting CP/NET files into disk image..."
    FORMAT="rc702-8dd"
    cpmcp -f "$FORMAT" "$WORK_IMAGE" "$SNIOS_SPR"    "0:SNIOS.SPR"
    cpmcp -f "$FORMAT" "$WORK_IMAGE" "$NDOS_SPR"     "0:NDOS.SPR"
    cpmcp -f "$FORMAT" "$WORK_IMAGE" "$CCP_SPR"      "0:CCP.SPR"
    cpmcp -f "$FORMAT" "$WORK_IMAGE" "$CPNETLDR_COM" "0:CPNETLDR.COM"
    cpmcp -f "$FORMAT" "$WORK_IMAGE" "$NETWORK_COM"  "0:NETWORK.COM"
    cpmcp -f "$FORMAT" "$WORK_IMAGE" "$CHKSUM_CIM"   "0:CHKSUM.COM"
    # Generate $$$.SUB: CP/M auto-runs these commands on boot (reverse execution order)
    python3 -c "
def rec(cmd):
    b = cmd.encode('ascii')
    return bytes([len(b)]) + b + bytes(127 - len(b))
data = rec('DIR H:') + rec('NETWORK H:=B:') + rec('CPNETLDR')
open('/tmp/cpnet_sub.tmp', 'wb').write(data)
"
    cpmcp -f "$FORMAT" "$WORK_IMAGE" /tmp/cpnet_sub.tmp '0:$$$.SUB'
    echo 'Injection complete ($$$.SUB: CPNETLDR -> NETWORK H:=B: -> DIR H:).'
fi


# ── Inject-mode flag file (read by Lua scripts to skip serial bootstrap) ──
rm -f /tmp/cpnet_inject_mode
$INJECT && touch /tmp/cpnet_inject_mode

# ── Select Lua script ──
if $AUTO_MODE; then
    LUA_SCRIPT="${SCRIPT_DIR}/autotest.lua"
    rm -f "$RESULT_FILE"
    echo "=== AUTOMATED MODE ($($INJECT && echo inject || echo serial)) ==="
elif $SETUP_MODE; then
    LUA_SCRIPT="${SCRIPT_DIR}/setup.lua"
    echo "=== SETUP MODE ($($INJECT && echo inject || echo serial)) ==="
    echo "  Script will auto-run CPNETLDR + NETWORK H:=B:"
    echo "  then hand control to you."
    echo "==================="
else
    # Manual mode: just configure serial
    LUA_SCRIPT="/tmp/cpnet_38400.lua"
    cat > "$LUA_SCRIPT" << 'LUAEOF'
-- set null_modem TX/RX baud to 38400 and enable RTS flow control
local ports = manager.machine.ioport.ports
for tag, port in pairs(ports) do
    if tag:find("RS232_TXBAUD") or tag:find("RS232_RXBAUD") then
        for name, field in pairs(port.fields) do
            field.user_value = 0x0b  -- RS232_BAUD_38400
        end
    end
    if tag:find("FLOW_CONTROL") then
        for name, field in pairs(port.fields) do
            if name:find("Flow Control") then
                field.user_value = 0x00  -- Off (was RTS; debugging RX)
            end
        end
    end
end
LUAEOF
    echo "=== MANUAL MODE ==="
    echo "  Type: CPNETLDR"
    echo "  Then: NETWORK H:=B:"
    echo "  Then: DIR H:"
    echo "========================="
fi

# ── Build server arguments ──
SERVER_CMD=(
    python3 -u "${SCRIPT_DIR}/server.py"
    --wait --port "$SERIAL_PORT"
    ${HEX_STAGE:+--hex-dir "$HEX_STAGE"}
    --error-file "$SERVER_ERROR_FILE"
    --printer-file "$PRINTER_FILE"
    "${SERVER_ARGS[@]}"
)
$CONSOLE_MODE && SERVER_CMD+=(--console)

# ── Start server ──
echo "Starting CP/NET server on port ${SERIAL_PORT}..."
rm -f "$SERVER_ERROR_FILE" "$PRINTER_FILE"

# ── Build MAME arguments ──
MAME_ARGS=(
    rc702
    -rompath "${MAME_DIR}/roms"
    -flop1 "$WORK_IMAGE"
    -rs232a null_modem
    -bitb "socket.localhost:${SERIAL_PORT}"
    -skip_gameinfo -window -nomaximize -resolution0 1100x720
    -autoboot_script "$LUA_SCRIPT"
)

if $GDB_MODE; then
    MAME_ARGS+=(-debug -debugger gdbstub -debugger_port 23946 -nothrottle)
    echo "=== GDB MODE: connect with python3 /tmp/gdb_cpnet_probe.py ==="
fi

if $HEADLESS; then
    MAME_ARGS+=(-sound none -nothrottle)
    echo "Starting MAME (will exit when autotest completes)..."
else
    $FAST && MAME_ARGS+=(-nothrottle)
    echo "Starting MAME rc702 with null_modem on port ${SERIAL_PORT}..."
fi

# ── Start live throughput graph in a new terminal window ──
if ! $HEADLESS && ! $CONSOLE_MODE; then
    osascript -e "tell app \"Terminal\" to do script \"exec python3 '${SCRIPT_DIR}/serial_graph.py'\"" >/dev/null 2>&1 || true
fi

if $CONSOLE_MODE; then
    # Console mode: server runs in FOREGROUND for terminal raw I/O.
    # MAME launches in background after a delay (server must bind port first).
    # Server stdout = CP/M console, server stderr → log file.
    (sleep 1 && exec "$MAME" "${MAME_ARGS[@]}") &
    MAME_PID=$!
    trap 'kill $MAME_PID 2>/dev/null; wait $MAME_PID 2>/dev/null' EXIT
    echo "CP/M remote console — Ctrl-] to exit"
    echo "Server log: /tmp/cpnet_server.log"
    "${SERVER_CMD[@]}" 2>/tmp/cpnet_server.log
    echo ""
    echo "Server exited."
else
    "${SERVER_CMD[@]}" 2>&1 | tee /tmp/cpnet_server.log &
    SERVER_PID=$!
    sleep 1
    "$MAME" "${MAME_ARGS[@]}"

    # ── Cleanup ──
    echo "MAME exited. Stopping server..."
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
fi

# ── Analyse server log (setup mode) ──
if $SETUP_MODE && [ -s "$PRINTER_FILE" ]; then
    echo ""
    echo "=== PRINTER OUTPUT (LST:) ==="
    cat "$PRINTER_FILE"
fi

if $SETUP_MODE && [ -f /tmp/cpnet_server.log ]; then
    echo ""
    echo "=== SERVER LOG ANALYSIS ==="
    python3 - /tmp/cpnet_server.log "$SERVER_ERROR_FILE" << 'PYEOF'
import sys, re, os

log_path   = sys.argv[1]
error_path = sys.argv[2] if len(sys.argv) > 2 else None

lines = open(log_path).readlines()

# Counts
bdos_calls   = [l for l in lines if re.match(r'BDOS F\d+:', l)]
unhandled    = [l for l in lines if 'UNHANDLED' in l]
errors       = [l for l in lines if 'ERROR' in l and 'UNHANDLED' not in l]
failed       = [l for l in lines if re.search(r'\bfailed\b', l, re.I) and 'Open failed' not in l]
open_failed  = [l for l in lines if 'Open failed' in l]
conn_closed  = [l for l in lines if l.startswith('Connection closed')]
transfers    = [l for l in lines if l.startswith('[transfer]')]

print(f"  Transfers:       {len(transfers)} lines")
print(f"  BDOS calls:      {len(bdos_calls)}")
if open_failed:
    names = [re.search(r'Open failed: .+/(.+)', l).group(1) for l in open_failed
             if re.search(r'Open failed: .+/(.+)', l)]
    print(f"  File not found:  {', '.join(names)}  (normal)")
if conn_closed:
    print(f"  Connection:      {conn_closed[-1].strip()}")
else:
    print(f"  Connection:      no close event (server may still be up)")

issues = []
if unhandled:
    issues.append(("UNHANDLED BDOS calls", unhandled))
if errors:
    issues.append(("ERROR lines", errors))
if failed:
    issues.append(("Failures", failed))

# External error file — only report entries not already covered by UNHANDLED log scan
if error_path and os.path.exists(error_path) and os.path.getsize(error_path) > 0:
    ext = [l for l in open(error_path).readlines()
           if not any(l.strip() in u for u in unhandled)]
    if ext:
        issues.append(("Server error file (extra)", ext))

if not issues:
    print("  Result:          CLEAN — no problems found")
else:
    print(f"  Result:          {len(issues)} issue group(s) found")
    for title, group in issues:
        print(f"\n  -- {title} ({len(group)}) --")
        for l in group:
            print("    " + l.rstrip())
PYEOF
fi

# ── Verify PIP round-trip file transfer ──
PIP_RESULT="UNKNOWN"
if [ -f "$CPNET_DIR/HELLO.TXT" ] && [ -f "$CPNET_DIR/HLCOPY2.TXT" ]; then
    echo ""
    echo "=== PIP ROUND-TRIP VERIFICATION ==="

    # CP/M PIP pads the last 128-byte record with ^Z (0x1A).
    # Strip trailing ^Z from HLCOPY2.TXT before comparing.
    STRIPPED=$(mktemp)
    python3 -c "
data = open('$CPNET_DIR/HLCOPY2.TXT','rb').read()
end = data.find(b'\x1a')
open('$STRIPPED','wb').write(data if end<0 else data[:end])
"
    SIZE1=$(wc -c < "$CPNET_DIR/HELLO.TXT")
    SIZE2=$(wc -c < "$STRIPPED")
    echo "HELLO.TXT:       $SIZE1 bytes"
    echo "HLCOPY2.TXT:     $SIZE2 bytes (stripped)"

    if [ "$SIZE1" = "$SIZE2" ]; then
        echo "Size check: PASS"
        if cmp -s "$CPNET_DIR/HELLO.TXT" "$STRIPPED"; then
            echo "Content check: PASS — Files are identical"
            PIP_RESULT="PASS"
        else
            echo "Content check: FAIL — Files differ"
            PIP_RESULT="FAIL"
            diff_byte=$(cmp -l "$CPNET_DIR/HELLO.TXT" "$STRIPPED" | head -1)
            [ -n "$diff_byte" ] && echo "  First difference: $diff_byte"
        fi
    else
        echo "Size check: FAIL — Sizes don't match ($SIZE1 vs $SIZE2)"
        PIP_RESULT="FAIL"
    fi
    rm -f "$STRIPPED"

    if [ -f "$RESULT_FILE" ]; then
        { echo ""
          echo "=== PIP ROUND-TRIP VERIFICATION ==="
          echo "HELLO_BYTES=$SIZE1"
          echo "HLCOPY2_BYTES=$SIZE2"
          echo "PIP_RESULT=$PIP_RESULT"
        } >> "$RESULT_FILE"
    fi
elif [ -f "$CPNET_DIR/HELLO.TXT" ] && [ ! -f "$CPNET_DIR/HLCOPY2.TXT" ]; then
    echo ""
    echo "=== PIP ROUND-TRIP VERIFICATION ==="
    echo "HELLO.TXT exists but HLCOPY2.TXT not created"
    PIP_RESULT="INCOMPLETE"
fi

# ── Check for unhandled server calls ──
if [ -s "$SERVER_ERROR_FILE" ]; then
    echo ""
    echo "=== SERVER ERRORS (unhandled BDOS calls) ==="
    cat "$SERVER_ERROR_FILE"
    echo "RESULT: FAIL — unhandled BDOS functions"
fi

# ── Show results (auto mode) ──
if $AUTO_MODE && [ -f "$RESULT_FILE" ]; then
    echo ""
    echo "=== TEST RESULTS ==="
    cat "$RESULT_FILE"

    if grep -q "PROMPT_VISIBLE=YES" "$RESULT_FILE" && grep -q "after_network" "$RESULT_FILE"; then
        echo "RESULT: PASS — prompt visible after NETWORK"
        [ "$PIP_RESULT" = "PASS" ] && echo "RESULT: PASS — PIP round-trip transfer verified"
    elif grep -q "PROMPT_VISIBLE=NO" "$RESULT_FILE" && grep -q "after_network" "$RESULT_FILE"; then
        echo "RESULT: FAIL — invisible prompt bug reproduced"
        grep "CONOUT_TARGET" "$RESULT_FILE" | tail -1
    else
        echo "RESULT: INCONCLUSIVE"
    fi

    # ERA result
    ERA_RESULT=$(grep "^ERA_RESULT=" "$RESULT_FILE" | cut -d= -f2-)
    if [ "$ERA_RESULT" = "OK" ]; then
        echo "RESULT: PASS — ERA H:HLCOPY2.TXT succeeded"
    elif [ -n "$ERA_RESULT" ]; then
        echo "RESULT: FAIL — ERA: $ERA_RESULT"
    fi

    # HELP ERA EXAMPLES result
    HELP_RESULT=$(grep "^HELP_RESULT=" "$RESULT_FILE" | cut -d= -f2-)
    if echo "$HELP_RESULT" | grep -q "^OK"; then
        echo "RESULT: PASS — HELP ERA EXAMPLES succeeded"
    elif [ -n "$HELP_RESULT" ]; then
        echo "RESULT: FAIL — HELP: $HELP_RESULT"
    fi

    # Large file transfer: compare CHKSUM against server-side file
    BIGFILE_CHKSUM=$(grep "^BIGFILE_CHKSUM=" "$RESULT_FILE" | cut -d= -f2-)
    if [ -n "$BIGFILE_CHKSUM" ] && [ "$BIGFILE_CHKSUM" != "NOT_FOUND" ]; then
        EXPECTED_SUM=$(python3 -c "
data = open('${CPNET_DIR}/BIGFILE.DAT','rb').read()
pad = (-len(data)) % 128
data += b'\x1A' * pad
s = sum(data) & 0xFFFF
print('%04X' % s)
" 2>/dev/null)
        if [ "$BIGFILE_CHKSUM" = "$EXPECTED_SUM" ]; then
            echo "RESULT: PASS — BIGFILE.DAT transfer verified (sum $BIGFILE_CHKSUM)"
        else
            echo "RESULT: FAIL — BIGFILE.DAT sum mismatch: got $BIGFILE_CHKSUM expected $EXPECTED_SUM"
        fi
    elif [ -n "$BIGFILE_CHKSUM" ]; then
        echo "RESULT: FAIL — BIGFILE.DAT CHKSUM not found"
    fi
fi

echo "Done."
