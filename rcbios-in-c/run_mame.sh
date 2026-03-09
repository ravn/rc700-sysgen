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
    mini) SRC_IMG="$IMG_MINI" WORK=/tmp/bios_c_mini.imd SYS=rc702mini ;;
    maxi) SRC_IMG="$IMG_MAXI" WORK=/tmp/bios_c_maxi.imd SYS=rc702 ;;
    *) echo "Unknown format: $FORMAT"; exit 1 ;;
esac

[ -x "$MAME_BIN" ] || { echo "MAME not found: $MAME_BIN"; exit 1; }
[ -f "$SRC_IMG" ]   || { echo "Disk image not found: $SRC_IMG"; exit 1; }

# Build
make bios

# Copy source image if needed
if $FORCE || [ ! -f "$WORK" ]; then
    cp "$SRC_IMG" "$WORK"
fi

# Patch
$PATCH "$WORK" bios.cim

# MAME arguments
ARGS=("$SYS" -rompath "$MAME_DIR/roms" -flop1 "$WORK"
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
    cat > /tmp/bios_c_autotest.lua << 'LUA'
-- Autotest: wait for A>, type DIR, wait, type TYPE DUMP.ASM, dump screen.
local frame = 0
local done = false
local commands = {
    {100, "DIR *.ASM\r"},
    {200, "TYPE DUMP.ASM\r"},
}
local cmd_idx = 0
local cmd_timer = 0
local key_queue = ""
local key_pos = 0
local key_delay = 0

local KBBUF  = 0xDC23
local KBHEAD = 0xDC33

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

local function screen_find(space, str)
    local bytes = {string.byte(str, 1, #str)}
    for addr = 0xF800, 0xF800 + 2000 - #str do
        local match = true
        for i = 1, #bytes do
            if space:read_u8(addr + i - 1) ~= bytes[i] then match = false; break end
        end
        if match then return true end
    end
    return false
end

local function inject_key(space, ch)
    local head = space:read_u8(KBHEAD)
    space:write_u8(KBBUF + head, ch)
    space:write_u8(KBHEAD, (head + 1) % 16)
end

local booted = false

emu.register_frame_done(function()
    if done then return end
    frame = frame + 1
    local space = manager.machine.devices[":maincpu"].spaces["program"]

    -- Wait for A> prompt
    if not booted then
        if screen_find(space, "A>") then
            booted = true
            cmd_idx = 0
            cmd_timer = 0
        elseif frame > 50 * 60 then
            local f = io.open("/tmp/bios_c_autotest.txt", "w")
            f:write("TIMEOUT waiting for A>\n\n" .. screen_text(space) .. "\n")
            f:close()
            done = true; manager.machine:exit()
        end
        return
    end

    -- Inject keystrokes
    if key_pos > 0 and key_pos <= #key_queue then
        if key_delay > 0 then key_delay = key_delay - 1; return end
        inject_key(space, string.byte(key_queue, key_pos))
        key_pos = key_pos + 1
        key_delay = 3
        return
    end

    -- Command delay
    if cmd_timer > 0 then cmd_timer = cmd_timer - 1; return end

    -- Next command
    cmd_idx = cmd_idx + 1
    if cmd_idx <= #commands then
        cmd_timer = commands[cmd_idx][1]
        key_queue = commands[cmd_idx][2]
        key_pos = 1; key_delay = 0
        return
    end

    -- Wait for TYPE output, then dump and exit
    if cmd_idx == #commands + 1 then
        cmd_timer = 500  -- 10 seconds for TYPE output
        cmd_idx = cmd_idx + 1
        return
    end

    local f = io.open("/tmp/bios_c_autotest.txt", "w")
    f:write(screen_text(space) .. "\n")
    f:close()
    print("Screen dumped to /tmp/bios_c_autotest.txt")
    done = true; manager.machine:exit()
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
else
    exec "$MAME_BIN" "${ARGS[@]}"
fi
