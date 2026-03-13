#!/usr/bin/env bash
# Build GFXSHOW.COM, inject onto disk image, boot in MAME, capture screens.
# Uses the rcbios-in-c infrastructure for disk patching and MAME launching.
set -eu
cd "$(dirname "$0")/.."

MAME_DIR=/Users/ravn/git/mame
MAME_BIN="$MAME_DIR/regnecentralen"
FLOPTOOL="$MAME_DIR/floptool"
PATCH="python3 rcbios/patch_bios.py"
CPMCP=/Users/ravn/.local/bin/cpmcp
ZMAC=zmac/bin/zmac
IMG_MAXI="$HOME/Downloads/SW1711-I8.imd"
WORK=/tmp/gfxshow_test

SYS=rc702
RESULT_FILE=/tmp/gfxshow_screens.txt

# Step 1: Generate test images and screen buffers
echo "=== Generating test images ==="
python3 tools/bitmap2rc700.py --test >/dev/null 2>&1

# Step 2: Generate and assemble the viewer program
echo "=== Assembling GFXSHOW.COM ==="
python3 << 'PYEOF'
import os, sys
SCREEN_SIZE = 1920
names = ["smiley", "ghost", "house", "star", "cat", "rc_logo"]
labels = ["SMILEY", "GHOST", "HOUSE", "STAR", "CAT", "RC LOGO"]
images = []
for name in names:
    with open(f"tools/test_images/{name}.bin", "rb") as f:
        images.append(f.read())

asm = """; gfxshow.asm - Display bitmap test images on RC702 screen
BDOS    EQU 0x0005
CONIN   EQU 1
DSPSTR  EQU 0xF800
SCRNSZ  EQU 1920

    .Z80
    ORG 0x0100

start:
"""
for i, (name, label) in enumerate(zip(names, labels)):
    asm += f"""
    ld hl,img_{name}
    ld de,DSPSTR
    ld bc,SCRNSZ
    ldir
    ld c,CONIN
    call BDOS
    cp 0x1B
    jp z,exit
"""
asm += """
    jp start
exit:
    ld c,9
    ld de,clrmsg
    call BDOS
    rst 0
clrmsg:
    db 0x1B, 'E', '$'
"""
for name, data in zip(names, images):
    asm += f"\nimg_{name}:\n"
    for offset in range(0, len(data), 32):
        chunk = data[offset:offset+32]
        asm += "    DB " + ", ".join(f"0x{b:02X}" for b in chunk) + "\n"

with open("tools/gfxshow.asm", "w") as f:
    f.write(asm)
PYEOF

(cd tools && ../$ZMAC -z --dri gfxshow.asm)
echo "  GFXSHOW.COM: $(wc -c < zout/gfxshow.cim | tr -d ' ') bytes"

# Step 3: Build BIOS and create disk image with GFXSHOW.COM
echo "=== Building disk image ==="
(cd rcbios-in-c && make bios)
cp "$IMG_MAXI" "${WORK}.imd"
$PATCH "${WORK}.imd" rcbios-in-c/bios.cim
$CPMCP -f rc702-8dd "${WORK}.imd" zout/gfxshow.cim 0:GFXSHOW.COM
rm -f "${WORK}.mfi"
"$FLOPTOOL" flopconvert auto mfi "${WORK}.imd" "${WORK}.mfi" >/dev/null 2>&1
rm -f "${WORK}.imd"
echo "  Disk image: ${WORK}.mfi"

# Step 4: Write Lua autotest script
# This waits for A> prompt, types GFXSHOW, then captures screen after each
# "keypress" (simulated by writing to keyboard buffer).
# It captures 6 screens total (one per image).
cat > /tmp/gfxshow_test.lua << 'LUA'
-- Autotest for GFXSHOW.COM: capture all 6 screens
local frame = 0
local done = false
local state = "boot"   -- boot, type_cmd, inject_cmd, wait_show, capture, next_img
local cmd = "GFXSHOW\r"
local cmd_pos = 1
local cmd_delay = 0
local img_count = 0
local total_images = 6
local capture_delay = 0
local screens = {}

-- Read keyboard buffer address from BIOS work area
-- For standard C-BIOS, kbbuf is at a fixed location — we'll find it from the map
-- But simpler: use emu.keypost() which goes through the BIOS input path
local function screen_dump(space)
    local lines = {}
    for row = 0, 23 do
        local line = ""
        for col = 0, 79 do
            local ch = space:read_u8(0xF800 + row * 80 + col)
            -- For semigraphics (>= 0x80), show hex
            if ch >= 0x20 and ch < 0x7F then
                line = line .. string.char(ch)
            elseif ch == 0x20 then
                line = line .. " "
            else
                line = line .. string.format("[%02X]", ch)
            end
        end
        lines[#lines + 1] = line:gsub("%s+$", "")
    end
    return table.concat(lines, "\n")
end

-- Check raw screen bytes for non-space content (image displayed)
local function screen_has_graphics(space)
    local count = 0
    for addr = 0xF800, 0xF800 + 1919 do
        local ch = space:read_u8(addr)
        if ch ~= 0x20 and ch ~= 0x00 then
            count = count + 1
        end
    end
    return count > 100  -- at least 100 non-space chars = image is showing
end

-- Check for A> prompt
local function at_prompt(space)
    for row = 0, 23 do
        local addr = 0xF800 + row * 80
        if space:read_u8(addr) == 0x41 and space:read_u8(addr + 1) == 0x3E then
            -- Check cursor is on this row (cursy at 0xFFD4)
            local cursy = space:read_u8(0xFFD4)
            if cursy == row then return true end
        end
    end
    return false
end

emu.register_frame_done(function()
    if done then return end
    frame = frame + 1
    local space = manager.machine.devices[":maincpu"].spaces["program"]

    if state == "boot" then
        if at_prompt(space) then
            state = "type_cmd"
            cmd_pos = 1
            cmd_delay = 10  -- small delay before typing
        elseif frame > 50 * 15 then
            screens[#screens + 1] = "=== TIMEOUT waiting for boot ==="
            done = true; os.exit(1)
        end

    elseif state == "type_cmd" then
        if cmd_delay > 0 then cmd_delay = cmd_delay - 1; return end
        if cmd_pos > #cmd then
            state = "wait_show"
            capture_delay = 50  -- wait 1 second for program to start
            return
        end
        emu.keypost(string.sub(cmd, cmd_pos, cmd_pos))
        cmd_pos = cmd_pos + 1
        cmd_delay = 5  -- 5 frames between keys

    elseif state == "wait_show" then
        if capture_delay > 0 then capture_delay = capture_delay - 1; return end
        if screen_has_graphics(space) then
            state = "capture"
        elseif frame > 50 * 30 then
            screens[#screens + 1] = "=== TIMEOUT waiting for first image ==="
            done = true; os.exit(1)
        end

    elseif state == "capture" then
        -- Capture current screen
        img_count = img_count + 1
        local names = {"smiley", "ghost", "house", "star", "cat", "rc_logo"}
        local name = names[img_count] or ("image" .. img_count)
        screens[#screens + 1] = "=== Screen " .. img_count .. ": " .. name .. " ==="
        screens[#screens + 1] = screen_dump(space)

        -- Also save raw binary for comparison
        local binpath = string.format("/tmp/gfxshow_cap_%d.bin", img_count)
        local f = io.open(binpath, "wb")
        for addr = 0xF800, 0xF800 + 1919 do
            f:write(string.char(space:read_u8(addr)))
        end
        f:close()

        if img_count >= total_images then
            -- All captured, write results and exit
            local f = io.open("/tmp/gfxshow_screens.txt", "w")
            for _, s in ipairs(screens) do f:write(s .. "\n\n") end
            f:close()
            print("All " .. total_images .. " screens captured to /tmp/gfxshow_screens.txt")
            done = true
            -- Send ESC to exit GFXSHOW
            emu.keypost("\27")
            -- Give it a moment then exit
            capture_delay = 20
            state = "exit_wait"
            return
        end

        -- Send keypress to advance to next image
        emu.keypost(" ")
        capture_delay = 30  -- wait for next image to render
        state = "next_img"

    elseif state == "next_img" then
        if capture_delay > 0 then capture_delay = capture_delay - 1; return end
        state = "capture"

    elseif state == "exit_wait" then
        if capture_delay > 0 then capture_delay = capture_delay - 1; return end
        os.exit(0)
    end

    -- Global timeout
    if frame > 50 * 120 then
        screens[#screens + 1] = "=== GLOBAL TIMEOUT ==="
        local f = io.open("/tmp/gfxshow_screens.txt", "w")
        for _, s in ipairs(screens) do f:write(s .. "\n\n") end
        f:close()
        done = true; os.exit(1)
    end
end)
LUA

# Step 5: Launch MAME with autotest
echo "=== Launching MAME ==="
ARGS=("$SYS" -rompath "$MAME_DIR/roms" -flop1 "${WORK}.mfi"
      -skip_gameinfo -window -resolution 1100x720
      -nothrottle -autoboot_script /tmp/gfxshow_test.lua)

rm -f "$RESULT_FILE" /tmp/gfxshow_cap_*.bin

"$MAME_BIN" "${ARGS[@]}" &
MAME_PID=$!
( i=0; while [ $i -lt 120 ]; do
    sleep 1
    kill -0 "$MAME_PID" 2>/dev/null || exit 0
    i=$((i + 1))
  done
  kill -9 "$MAME_PID" 2>/dev/null && echo "MAME killed after 120s timeout" >&2
) &
TIMER_PID=$!
wait "$MAME_PID" 2>/dev/null || true
kill "$TIMER_PID" 2>/dev/null; wait "$TIMER_PID" 2>/dev/null || true

# Step 6: Verify results
echo ""
if [ ! -f "$RESULT_FILE" ]; then
    echo "FAIL: No screen captures generated"
    exit 1
fi

echo "=== Screen Captures ==="
cat "$RESULT_FILE"

# Compare captured screens with expected
echo ""
echo "=== Verification ==="
ERRORS=0
for i in 1 2 3 4 5 6; do
    CAP="/tmp/gfxshow_cap_${i}.bin"
    NAMES=(smiley ghost house star cat rc_logo)
    NAME="${NAMES[$((i-1))]}"
    EXPECTED="tools/test_images/${NAME}.bin"
    if [ -f "$CAP" ]; then
        if cmp -s "$CAP" "$EXPECTED"; then
            echo "  OK: Screen $i ($NAME) matches expected"
        else
            DIFF_BYTES=$(cmp -l "$CAP" "$EXPECTED" 2>/dev/null | wc -l | tr -d ' ')
            echo "  DIFF: Screen $i ($NAME) differs in $DIFF_BYTES bytes"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo "  FAIL: Screen $i ($NAME) not captured"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""
if [ "$ERRORS" -eq 0 ]; then
    echo "=== ALL 6 SCREENS MATCH ==="
else
    echo "=== $ERRORS SCREEN(S) DIFFER ==="
fi
