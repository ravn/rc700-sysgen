#!/bin/bash
# Build C BIOS, patch onto disk image, launch MAME.
# Usage: run_mame.sh [-m mini|maxi] [-f] [-t] [-g] [-2 image.imd]
#   -m FORMAT  mini or maxi (default: maxi)
#   -f         Force re-copy of source disk image
#   -t         Autotest: type "DIR" then "TYPE DUMP.ASM", dump screen, exit
#   -g         GDB stub: enable remote debugger on port 23946
#   -2 FILE    Mount FILE as second floppy drive
set -euo pipefail
cd "$(dirname "$0")"

MAME_DIR=/Users/ravn/git/mame
MAME_BIN="$MAME_DIR/regnecentralen"
FLOPTOOL="$MAME_DIR/floptool"
PATCH="python3 ../rcbios/patch_bios.py"
IMG_MINI="$HOME/Downloads/CPM_med_COMAL80.imd"
IMG_MAXI="$HOME/Downloads/SW1711-I8.imd"

FORMAT=maxi FORCE=false AUTOTEST=false GDBSTUB=false FLOP2=""

while getopts "m:fgt2:h" opt; do
    case $opt in
        m) FORMAT="$OPTARG" ;;
        f) FORCE=true ;;
        g) GDBSTUB=true ;;
        t) AUTOTEST=true ;;
        2) FLOP2="$OPTARG" ;;
        *) sed -n '2,7p' "$0"; exit 1 ;;
    esac
done

case "$FORMAT" in
    mini) SRC_IMG="$IMG_MINI" WORK=/tmp/bios_c_mini SYS=rc702mini ;;
    maxi) SRC_IMG="$IMG_MAXI" WORK=/tmp/bios_c_maxi SYS=rc702 ;;
    *) echo "Unknown format: $FORMAT"; exit 1 ;;
esac

[ -x "$MAME_BIN" ] || { echo "MAME not found: $MAME_BIN"; exit 1; }
[ -f "$SRC_IMG" ]   || { echo "Disk image not found: $SRC_IMG"; exit 1; }

# Build
make bios

# Create/refresh MFI working image from source IMD
# MFI is MAME's native writable format; IMD is read-only in MAME.
# Patch is applied to an intermediate IMD copy, then converted to MFI.
if $FORCE || [ ! -f "$WORK.mfi" ]; then
    cp "$SRC_IMG" "$WORK.imd"
    $PATCH "$WORK.imd" bios.cim
    "$FLOPTOOL" flopconvert auto mfi "$WORK.imd" "$WORK.mfi" >/dev/null 2>&1
    rm -f "$WORK.imd"
    echo "Created writable MFI: $WORK.mfi"
else
    # Re-patch: convert MFI back to temp IMD, patch, convert back
    # Since we can't patch MFI directly, re-create from source
    cp "$SRC_IMG" "$WORK.imd"
    $PATCH "$WORK.imd" bios.cim
    "$FLOPTOOL" flopconvert auto mfi "$WORK.imd" "$WORK.mfi" >/dev/null 2>&1
    rm -f "$WORK.imd"
    echo "Re-patched MFI: $WORK.mfi"
fi

# MAME arguments — use MFI image (writable)
ARGS=("$SYS" -rompath "$MAME_DIR/roms" -flop1 "$WORK.mfi"
      -skip_gameinfo -window -resolution 1100x720)
[ -n "$FLOP2" ] && ARGS+=(-flop2 "$FLOP2")

if $GDBSTUB; then
    MAME_BIN="$MAME_DIR/regnecentralend"  # debug build needed for GDB stub
    [ -x "$MAME_BIN" ] || { echo "Debug MAME not found: $MAME_BIN"; exit 1; }
    ARGS+=(-debug -debugger gdbstub -debugger_port 23946 -nothrottle)
    echo "=== GDB stub enabled on port 23946 ==="
    echo "=== Run: python3 gdb_trace.py ==="
fi

if $AUTOTEST; then
    ARGS+=(-nothrottle -autoboot_script /tmp/bios_c_autotest.lua)
    # Extract keyboard buffer addresses from map file
    KBBUF_ADDR=$(grep '_kbbuf ' bios.map | sed 's/.*= \$\([0-9A-F]*\).*/0x\1/')
    KBHEAD_ADDR=$(grep '_kbhead ' bios.map | sed 's/.*= \$\([0-9A-F]*\).*/0x\1/')
    [ -n "$KBBUF_ADDR" ] || { echo "ERROR: kbbuf not found in bios.map"; exit 1; }
    [ -n "$KBHEAD_ADDR" ] || { echo "ERROR: kbhead not found in bios.map"; exit 1; }
    sed "s/KBBUF_ADDR/$KBBUF_ADDR/g; s/KBHEAD_ADDR/$KBHEAD_ADDR/g" > /tmp/bios_c_autotest.lua << 'LUA'
-- Autotest: boot CP/M, run ASM FILEX, then STAT and TYPE FILEX.PRN.
-- Captures screen after each command for verification.
-- Uses MFI disk image (writable) so ASM output persists.
--
-- Prompt detection: reads cursor position from BIOS WorkArea at 0xFFD1
-- (curx) and 0xFFD4 (cursy). CP/M is at the A> prompt when curx==2 and
-- the row at cursy starts with "A>".
local frame = 0
local done = false
local commands = {
    {200, "ASM FILEX\r"},
    {100, "STAT FILEX.PRN\r"},
    {100, "TYPE FILEX.PRN\r"},
}
local cmd_idx = 0
local cmd_timer = 0
local key_queue = ""
local key_pos = 0
local key_delay = 0
local screens = {}
local state = "boot"  -- boot, send, inject, wait

local KBBUF  = KBBUF_ADDR
local KBHEAD = KBHEAD_ADDR

local function screen_text(space)
    local lines = {}
    for row = 0, 24 do
        local line = ""
        for col = 0, 79 do
            local ch = space:read_u8(0xF800 + row * 80 + col)
            line = line .. (ch >= 0x20 and ch < 0x7F and string.char(ch) or " ")
        end
        lines[#lines + 1] = line:gsub("%s+$", "")
    end
    return table.concat(lines, "\n")
end

-- Check if CP/M is at the A> prompt using cursor position from WorkArea
local function at_prompt(space)
    local curx  = space:read_u8(0xFFD1)   -- cursor column
    local cursy = space:read_u8(0xFFD4)   -- cursor row number
    if curx ~= 2 then return false end
    local row_addr = 0xF800 + cursy * 80
    return space:read_u8(row_addr) == 0x41 and space:read_u8(row_addr + 1) == 0x3E
end

local function inject_key(space, ch)
    local head = space:read_u8(KBHEAD)
    space:write_u8(KBBUF + head, ch)
    space:write_u8(KBHEAD, (head + 1) % 16)
end

emu.register_frame_done(function()
    if done then return end
    frame = frame + 1
    local space = manager.machine.devices[":maincpu"].spaces["program"]

    if state == "boot" then
        -- Wait for initial A> prompt
        if at_prompt(space) then
            state = "send"
            cmd_idx = 0
        elseif frame > 50 * 60 then
            screens[#screens + 1] = "=== TIMEOUT waiting for boot ===\n" .. screen_text(space)
            done = true
        end

    elseif state == "send" then
        -- Send next command
        cmd_idx = cmd_idx + 1
        if cmd_idx > #commands then
            -- All done
            local f = io.open("/tmp/bios_c_autotest.txt", "w")
            for _, s in ipairs(screens) do f:write(s .. "\n\n") end
            f:close()
            print("All screens dumped to /tmp/bios_c_autotest.txt")
            done = true; manager.machine:exit()
            return
        end
        key_queue = commands[cmd_idx][2]
        key_pos = 1; key_delay = 0
        state = "inject"

    elseif state == "inject" then
        -- Inject keystrokes one at a time
        if key_pos > #key_queue then
            -- All keys sent, start waiting
            cmd_timer = commands[cmd_idx][1]
            state = "wait"
            return
        end
        if key_delay > 0 then key_delay = key_delay - 1; return end
        inject_key(space, string.byte(key_queue, key_pos))
        key_pos = key_pos + 1
        key_delay = 3

    elseif state == "wait" then
        -- Wait for command to complete
        if cmd_timer > 0 then cmd_timer = cmd_timer - 1; return end
        if at_prompt(space) then
            -- Command completed — capture screen
            screens[#screens + 1] = "=== After: " .. commands[cmd_idx][2]:gsub("\r","") .. " ===\n" .. screen_text(space)
            state = "send"
            return
        end
    end

    -- Global timeout: 5 minutes
    if frame > 50 * 300 then
        screens[#screens + 1] = "=== TIMEOUT frame " .. frame .. " ===\n" .. screen_text(space)
        local f = io.open("/tmp/bios_c_autotest.txt", "w")
        for _, s in ipairs(screens) do f:write(s .. "\n\n") end
        f:close()
        done = true; manager.machine:exit()
    end
end)
LUA
fi

echo "=== Launching MAME ($SYS) ==="
if $GDBSTUB; then
    "$MAME_BIN" "${ARGS[@]}" &
    MPID=$!
    echo $MPID > /tmp/mame_gdb.pid
    echo "MAME PID: $MPID (saved to /tmp/mame_gdb.pid)"
    echo "To kill: kill -9 $MPID"
    wait $MPID
elif $AUTOTEST; then
    "$MAME_BIN" "${ARGS[@]}"
    echo ""
    echo "=== Screen captures ==="
    cat /tmp/bios_c_autotest.txt
    echo ""

    ERRORS=0

    # Check ASM completed without errors (from screen capture)
    if grep -q "END OF ASSEMBLY" /tmp/bios_c_autotest.txt; then
        echo "  OK: ASM completed (END OF ASSEMBLY)"
    else
        echo "  FAIL: ASM did not complete"
        ERRORS=$((ERRORS + 1))
    fi

    # Extract use factor from screen
    USE_FACTOR=$(grep -oE '[0-9A-F]+H USE FACTOR' /tmp/bios_c_autotest.txt | head -1)
    if [ -n "$USE_FACTOR" ]; then
        echo "  OK: $USE_FACTOR"
    else
        echo "  WARN: Could not extract USE FACTOR"
    fi

    # Check STAT output shows FILEX.PRN exists with expected size
    STAT_LINE=$(grep "Recs" /tmp/bios_c_autotest.txt -A1 | grep "FILEX" | head -1)
    if [ -n "$STAT_LINE" ]; then
        echo "  OK: STAT: $STAT_LINE"
        # Extract record count for validation
        RECS=$(echo "$STAT_LINE" | awk '{print $1}')
        if [ "$RECS" -ge 200 ] 2>/dev/null; then
            echo "  OK: $RECS records (expected ~266)"
        else
            echo "  FAIL: Only $RECS records (expected ~266)"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo "  FAIL: STAT FILEX.PRN not found in output"
        ERRORS=$((ERRORS + 1))
    fi

    # Check TYPE output shows END directive (last screen of PRN listing)
    if grep -qi "END.*START" /tmp/bios_c_autotest.txt; then
        echo "  OK: END START found in TYPE output"
    else
        echo "  WARN: END START not visible (may have scrolled past)"
    fi

    # Save reference addresses from TYPE output (last screen of PRN listing)
    echo ""
    echo "=== Reference addresses ==="
    REF_FILE="$(dirname "$0")/filex_ref.txt"
    {
        echo "# FILEX.PRN reference — generated $(date +%Y-%m-%d)"
        echo "# Source: CP/M ASM.COM run in MAME on C BIOS"
        echo "# Assembly: $USE_FACTOR"
        echo "# STAT: ${STAT_LINE:-unknown}"
        echo "#"
        echo "# Addresses from TYPE output (last page of PRN listing):"
        # Extract address lines from screen capture (format: " XXXX HH...")
        grep -E '^ [0-9A-F]{4} ' /tmp/bios_c_autotest.txt | sed 's/[[:space:]]*$//'
        echo "#"
        echo "# Key addresses (from FILEX.ASM source):"
        echo "# BOOT    = 0000  (EQU)"
        echo "# BDOS    = 0005  (EQU)"
        echo "# START   = 0100  (ORG)"
        echo "# END     = 0932  (next free address)"
    } > "$REF_FILE"
    cat "$REF_FILE"

    echo ""
    if [ "$ERRORS" -eq 0 ]; then
        echo "=== ALL CHECKS PASSED ==="
    else
        echo "=== $ERRORS CHECK(S) FAILED ==="
        exit 1
    fi
else
    exec "$MAME_BIN" "${ARGS[@]}"
fi
