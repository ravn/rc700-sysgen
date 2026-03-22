-- mame_comal_debug.lua — Debug COMAL boot: dump memory after boot
-- Dumps memory at 20s regardless of what's on screen

local frame = 0
local done = false
local RESULT_FILE = "/tmp/comal_debug.txt"
local PROM_DSP = 0x7800

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

local function hex_dump(space, start, len)
    local lines = {}
    for addr = start, start + len - 1, 16 do
        local hex = string.format("%04X:", addr)
        local ascii = ""
        for i = 0, 15 do
            if addr + i < start + len then
                local b = space:read_u8(addr + i)
                hex = hex .. string.format(" %02X", b)
                ascii = ascii .. (b >= 0x20 and b < 0x7F and string.char(b) or ".")
            end
        end
        lines[#lines + 1] = hex .. "  " .. ascii
    end
    return table.concat(lines, "\n")
end

local function region_summary(space, start, len)
    local zeros = 0
    local ffs = 0
    local nonzero_first = -1
    local nonzero_last = -1
    for addr = start, start + len - 1 do
        local b = space:read_u8(addr)
        if b == 0 then zeros = zeros + 1
        elseif b == 0xFF then ffs = ffs + 1
        else
            if nonzero_first == -1 then nonzero_first = addr end
            nonzero_last = addr
        end
    end
    return string.format("%d bytes, %d zeros, %d FFs, data 0x%04X-0x%04X",
        len, zeros, ffs,
        nonzero_first == -1 and 0 or nonzero_first,
        nonzero_last == -1 and 0 or nonzero_last)
end

local function finish(label, space)
    local f = io.open(RESULT_FILE, "w")
    f:write(label .. "\n")
    f:write(string.format("frame=%d (%.1fs emulated)\n", frame, frame / 50.0))

    f:write("\n--- Screen (0x7800) ---\n")
    f:write(screen_text_at(space, PROM_DSP) .. "\n")

    f:write("\n--- Memory region summary ---\n")
    for _, r in ipairs({
        {0x0000, 0x1000}, {0x1000, 0x1000}, {0x2000, 0x1000},
        {0x3000, 0x1000}, {0x4000, 0x1000}, {0x5000, 0x1000},
        {0x6000, 0x1000}, {0x7000, 0x0800},
    }) do
        f:write(string.format("  0x%04X-0x%04X: %s\n", r[1], r[1]+r[2]-1,
            region_summary(space, r[1], r[2])))
    end

    f:write("\n--- Memory at 0x0000 (128 bytes) ---\n")
    f:write(hex_dump(space, 0x0000, 128) .. "\n")

    f:write("\n--- Memory at 0x1000 (128 bytes) ---\n")
    f:write(hex_dump(space, 0x1000, 128) .. "\n")

    f:write("\n--- Memory at 0x6E00-0x7100 (768 bytes) ---\n")
    f:write(hex_dump(space, 0x6E00, 768) .. "\n")

    f:close()
    done = true
    manager.machine:exit()
end

emu.register_frame_done(function()
    if done then return end
    frame = frame + 1

    -- Dump at 15 seconds regardless
    if frame >= 50 * 15 then
        local space = manager.machine.devices[":maincpu"].spaces["program"]

        -- Scan all memory for "comal" or "RC700 c" text
        local f2 = io.open(RESULT_FILE .. ".scan", "w")
        for base = 0x0000, 0xF800, 0x0080 do
            local has_text = false
            for addr = base, base + 0x07FF do
                local b = space:read_u8(addr)
                if b >= 0x20 and b < 0x7F then has_text = true; break end
            end
            if has_text then
                -- Check if this looks like a display buffer (lots of spaces + some text)
                local spaces = 0
                local printable = 0
                for addr = base, base + 0x07CF do  -- 80*25=2000
                    local b = space:read_u8(addr)
                    if b == 0x20 then spaces = spaces + 1 end
                    if b >= 0x20 and b < 0x7F then printable = printable + 1 end
                end
                if spaces > 1000 and printable > 1500 then
                    f2:write(string.format("\n=== Possible display at 0x%04X (spaces=%d, printable=%d) ===\n", base, spaces, printable))
                    -- Show as text
                    for row = 0, 24 do
                        local line = ""
                        for col = 0, 79 do
                            local ch = space:read_u8(base + row * 80 + col)
                            line = line .. (ch >= 0x20 and ch < 0x7F and string.char(ch) or " ")
                        end
                        f2:write(line:gsub("%s+$", "") .. "\n")
                    end
                end
            end
        end
        f2:close()

        finish("DUMP_AT_15S", space)
    end
end)
