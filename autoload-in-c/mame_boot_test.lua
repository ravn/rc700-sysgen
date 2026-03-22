-- mame_boot_test.lua — Automated boot test for autoload PROM
--
-- PASS: CP/M boots and "A>" appears on screen.
-- FAIL: error message appears or timeout.

local frame = 0
local done = false
local DSPSTR = 0xF800
local RESULT_FILE = "/tmp/boot_test_result.txt"

local function screen_text(space)
    local lines = {}
    for row = 0, 24 do
        local line = ""
        for col = 0, 79 do
            local ch = space:read_u8(DSPSTR + row * 80 + col)
            line = line .. (ch >= 0x20 and ch < 0x7F and string.char(ch) or " ")
        end
        lines[#lines + 1] = line:gsub("%s+$", "")
    end
    return table.concat(lines, "\n")
end

local function screen_find(space, str)
    local bytes = {string.byte(str, 1, #str)}
    for addr = DSPSTR, DSPSTR + 2000 - #str do
        local match = true
        for i = 1, #bytes do
            if space:read_u8(addr + i - 1) ~= bytes[i] then match = false; break end
        end
        if match then return true end
    end
    return false
end

local function finish(result, space)
    local f = io.open(RESULT_FILE, "w")
    f:write(result .. "\n")
    f:write(string.format("frame=%d (%.1fs emulated)\n\n", frame, frame / 50.0))
    f:write(screen_text(space) .. "\n")
    f:close()
    done = true
    manager.machine:exit()
end

-- PROM uses DSPSTR=0x7800 for display; CP/M BIOS uses 0xF800.
-- Check both areas.
local PROM_DSP = 0x7A00

local function screen_find_at(space, base, str)
    local bytes = {string.byte(str, 1, #str)}
    for addr = base, base + 2000 - #str do
        local match = true
        for i = 1, #bytes do
            if space:read_u8(addr + i - 1) ~= bytes[i] then match = false; break end
        end
        if match then return true end
    end
    return false
end

local function screen_text_at(space, base)
    local lines = {}
    for row = 0, 24 do
        local line = ""
        for col = 0, 79 do
            local ch = space:read_u8(base + row * 80 + col)
            line = line .. (ch >= 0x20 and ch < 0x7F and string.char(ch) or " ")
        end
        lines[#lines + 1] = line:gsub("%s+$", "")
    end
    return table.concat(lines, "\n")
end

local function finish_both(result, space)
    local f = io.open(RESULT_FILE, "w")
    f:write(result .. "\n")
    f:write(string.format("frame=%d (%.1fs emulated)\n", frame, frame / 50.0))
    f:write("\n--- PROM display (0x7A00) ---\n")
    f:write(screen_text_at(space, PROM_DSP) .. "\n")
    f:write("\n--- BIOS display (0xF800) ---\n")
    f:write(screen_text_at(space, DSPSTR) .. "\n")
    f:close()
    done = true
    manager.machine:exit()
end

emu.register_frame_done(function()
    if done then return end
    frame = frame + 1
    if frame % 25 ~= 0 then return end  -- check every 0.5s

    local space = manager.machine.devices[":maincpu"].spaces["program"]

    -- Check for successful boot (CP/M prompt at either display)
    if screen_find_at(space, DSPSTR, "A>") or screen_find_at(space, PROM_DSP, "A>") then
        finish_both("PASS", space)
        return
    end

    -- Check for any non-space text at PROM display after 10s (error message)
    if frame > 50 * 10 then
        for addr = PROM_DSP, PROM_DSP + 2000 - 1 do
            local ch = space:read_u8(addr)
            if ch > 0x20 and ch < 0x7F then
                -- Something visible on PROM display — likely an error
                finish_both("FAIL: PROM error (see display)", space)
                return
            end
        end
    end

    -- Timeout after 30 emulated seconds
    if frame > 50 * 30 then
        finish_both("FAIL: timeout (blank screen)", space)
    end
end)
