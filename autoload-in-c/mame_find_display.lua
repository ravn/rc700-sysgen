-- mame_find_display.lua — Find COMAL display buffer by scanning memory
-- Searches for "RC700 comal" string in all of RAM after boot

local frame = 0
local done = false
local RESULT_FILE = "/tmp/boot_test_result.txt"

emu.register_frame_done(function()
    if done then return end
    frame = frame + 1
    if frame < 50 * 10 then return end  -- wait 10s for COMAL to boot
    done = true

    local space = manager.machine.devices[":maincpu"].spaces["program"]
    local target = "RC700 comal"
    local bytes = {string.byte(target, 1, #target)}

    local f = io.open(RESULT_FILE, "w")
    f:write("Scanning memory for '" .. target .. "'...\n")

    for addr = 0x0000, 0xFFFF - #target do
        local match = true
        for i = 1, #bytes do
            if space:read_u8(addr + i - 1) ~= bytes[i] then
                match = false
                break
            end
        end
        if match then
            f:write(string.format("FOUND at 0x%04X\n", addr))
            -- Dump 80 chars before and 160 chars after to see context
            local line = ""
            for i = 0, 79 do
                local ch = space:read_u8(addr + i)
                line = line .. (ch >= 0x20 and ch < 0x7F and string.char(ch) or ".")
            end
            f:write("  Line: " .. line .. "\n")
        end
    end

    -- Also dump what's at common display addresses
    for _, base in ipairs({0x7800, 0xF800, 0x7000, 0xB000, 0xC000}) do
        local line = ""
        for i = 0, 79 do
            local ch = space:read_u8(base + i)
            line = line .. (ch >= 0x20 and ch < 0x7F and string.char(ch) or ".")
        end
        f:write(string.format("0x%04X: %s\n", base, line))
    end

    f:close()
    manager.machine:exit()
end)
