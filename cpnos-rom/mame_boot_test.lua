-- cpnos-rom MAME boot test
--
-- PASS: "CPNOS" appears at top-left of display memory (0xF800+).
-- FAIL: timeout, or something garbled there.

local frame = 0
local done = false
local DSPSTR = 0xF800
local RESULT_FILE = "/tmp/cpnos_boot_result.txt"

local function screen_text(space, base)
    local out = {}
    for row = 0, 24 do
        local line = ""
        for col = 0, 79 do
            local ch = space:read_u8(base + row * 80 + col)
            line = line .. (ch >= 0x20 and ch < 0x7F and string.char(ch) or ".")
        end
        out[#out + 1] = line:gsub("%s+$", "")
    end
    return table.concat(out, "\n")
end

local function match_at(space, addr, str)
    for i = 1, #str do
        if space:read_u8(addr + i - 1) ~= string.byte(str, i) then return false end
    end
    return true
end

local function hex_dump(space, base, len)
    local lines = {}
    for i = 0, len - 1, 16 do
        local row = string.format("  %04X: ", base + i)
        local ascii = ""
        for j = 0, 15 do
            if i + j < len then
                local b = space:read_u8(base + i + j)
                row = row .. string.format("%02x ", b)
                ascii = ascii .. (b >= 0x20 and b < 0x7F and string.char(b) or ".")
            end
        end
        lines[#lines + 1] = row .. " " .. ascii
    end
    return table.concat(lines, "\n")
end

local function finish(result, space)
    local f = io.open(RESULT_FILE, "w")
    f:write(result .. "\n")
    f:write(string.format("frame=%d (%.1fs emulated)\n", frame, frame / 50.0))

    -- Program counter and CPU state
    local pc = manager.machine.devices[":maincpu"].state["PC"].value
    local sp = manager.machine.devices[":maincpu"].state["SP"].value
    f:write(string.format("PC=%04X  SP=%04X\n", pc, sp))

    f:write("\n--- 0x0000 (reset vector / PROM0 shadow) ---\n")
    f:write(hex_dump(space, 0x0000, 48) .. "\n")
    f:write("\n--- 0xE200 (breadcrumbs) ---\n")
    f:write(hex_dump(space, 0xE200, 16) .. "\n")
    f:write("\n--- 0xF580 (resident VMA) ---\n")
    f:write(hex_dump(space, 0xF580, 80) .. "\n")
    f:write("\n--- 0xF800 (display row 0) ---\n")
    f:write(hex_dump(space, 0xF800, 80) .. "\n")
    f:write("\n--- display textual ---\n")
    f:write(screen_text(space, DSPSTR) .. "\n")
    f:close()
    done = true
    manager.machine:exit()
end

emu.register_frame_done(function()
    if done then return end
    frame = frame + 1
    if frame % 25 ~= 0 then return end  -- every ~0.5s

    local space = manager.machine.devices[":maincpu"].spaces["program"]

    if match_at(space, DSPSTR, "CPNOS") then
        finish("PASS", space)
        return
    end

    -- 5s timeout: cpnos boot path is tiny, should hit CPNOS in <1s
    if frame > 50 * 5 then
        finish("FAIL: CPNOS banner not seen", space)
    end
end)
