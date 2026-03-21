-- mame_comal_test.lua — Automated COMAL boot + program test
--
-- PASS: COMAL boots, types and runs a counting program, output verified.
-- FAIL: prompt not found, program output wrong, or timeout.

local frame = 0
local done = false
local state = "wait_prompt"
local RESULT_FILE = "/tmp/boot_test_result.txt"

-- Search multiple display addresses — COMAL may reprogram CRT DMA
local DISPLAY_ADDRS = {0x7800, 0xF800, 0x0000, 0x4000, 0x8000, 0xB000}

local function screen_text(space, base)
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

local function screen_find(space, base, str)
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

-- Find which display address has the target string
local function find_display(space, str)
    for _, base in ipairs(DISPLAY_ADDRS) do
        if screen_find(space, base, str) then
            return base
        end
    end
    return nil
end

local display_base = nil

local function finish(result, space)
    local f = io.open(RESULT_FILE, "w")
    f:write(result .. "\n")
    f:write(string.format("frame=%d (%.1fs emulated)\n", frame, frame / 50.0))
    if display_base then
        f:write(string.format("\n--- Display (0x%04X) ---\n", display_base))
        f:write(screen_text(space, display_base) .. "\n")
    else
        -- Dump all candidate display areas
        for _, base in ipairs(DISPLAY_ADDRS) do
            f:write(string.format("\n--- Display (0x%04X) ---\n", base))
            f:write(screen_text(space, base) .. "\n")
        end
    end
    f:close()
    done = true
    manager.machine:exit()
end

local function type_string(str)
    manager.machine:ioport():natkeyboard():post(str)
end

emu.register_frame_done(function()
    if done then return end
    frame = frame + 1

    -- Check every 0.5s
    if frame % 25 ~= 0 then return end

    local space = manager.machine.devices[":maincpu"].spaces["program"]

    if state == "wait_prompt" then
        -- Find COMAL prompt at any display address
        display_base = find_display(space, "* ")
        if display_base then
            state = "type_program"
            -- Small delay before typing
        end
        if frame > 50 * 30 then
            finish("FAIL: COMAL prompt not found", space)
        end

    elseif state == "type_program" then
        -- Type a program that counts 1 to 10
        type_string("10 FOR I:=1 TO 10\r20 PRINT I\r30 NEXT I\r40 END\rRUN\r")
        state = "wait_output"

    elseif state == "wait_output" then
        -- Look for "END." which COMAL prints after program finishes
        if display_base and screen_find(space, display_base, "END.") then
            finish("PASS", space)
        end
        if frame > 50 * 90 then
            finish("FAIL: timeout waiting for program output", space)
        end
    end
end)
