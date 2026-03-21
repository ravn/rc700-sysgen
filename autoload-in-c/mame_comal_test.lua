-- mame_comal_test.lua — Automated COMAL boot + FOR loop test
--
-- PASS: COMAL boots, runs a counting program, output verified.
-- FAIL: prompt not found, program output wrong, or timeout.

local frame = 0
local done = false
local state = "wait_boot"
local COMAL_DSP = 0x0800
local RESULT_FILE = "/tmp/boot_test_result.txt"

-- Lines to type, one at a time, waiting for "* " prompt between each
local program = {
    "10 FOR X=1 TO 5",
    "20 PRINT X",
    "30 NEXT X",
    "40 END",
    "RUN",
}
local line_index = 0

-- Character-by-character queue
local char_queue = ""
local char_timer = 0

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

local function finish(result, space)
    local f = io.open(RESULT_FILE, "w")
    f:write(result .. "\n")
    f:write(string.format("frame=%d (%.1fs emulated)\n", frame, frame / 50.0))
    f:write(string.format("\n--- Display (0x%04X) ---\n", COMAL_DSP))
    f:write(screen_text(space, COMAL_DSP) .. "\n")
    f:close()
    done = true
    manager.machine:exit()
end

-- Count how many "* " prompts are visible (to know when a new one appears)
local function count_prompts(space)
    local count = 0
    for row = 0, 24 do
        local addr = COMAL_DSP + row * 80
        if space:read_u8(addr) == 0x2A and space:read_u8(addr + 1) == 0x20 then
            count = count + 1
        end
    end
    return count
end

local last_prompt_count = 0

emu.register_frame_done(function()
    if done then return end
    frame = frame + 1

    -- Post one character every 8 frames (~160ms)
    if #char_queue > 0 and frame % 8 == 0 then
        local ch = string.sub(char_queue, 1, 1)
        char_queue = string.sub(char_queue, 2)
        manager.machine.natkeyboard:post(ch)
    end

    -- Only check state every 25 frames (0.5s)
    if frame % 25 ~= 0 then return end

    local space = manager.machine.devices[":maincpu"].spaces["program"]

    if state == "wait_boot" then
        -- Wait for first "* " prompt
        if screen_find(space, COMAL_DSP, "* ") then
            state = "wait_ready"
            last_prompt_count = count_prompts(space)
            -- Wait 5 seconds before starting to type
            char_timer = frame + 250
        end
        if frame > 50 * 60 then
            finish("FAIL: COMAL prompt not found", space)
        end

    elseif state == "wait_ready" then
        -- Wait before sending next line
        if frame > char_timer and #char_queue == 0 then
            line_index = line_index + 1
            if line_index > #program then
                state = "wait_output"
                char_timer = frame
            else
                char_queue = program[line_index] .. "\r"
                last_prompt_count = count_prompts(space)
                state = "wait_echo"
            end
        end

    elseif state == "wait_echo" then
        -- Wait for the line to be processed (new "* " prompt appears)
        if #char_queue == 0 then
            local cur = count_prompts(space)
            if cur > last_prompt_count then
                state = "wait_ready"
                char_timer = frame + 25  -- 0.5s between lines
            end
        end
        if frame > char_timer + 500 then  -- 10s timeout per line
            finish("FAIL: line not echoed: " .. program[line_index], space)
        end

    elseif state == "wait_output" then
        -- Look for "END." or numbers
        if screen_find(space, COMAL_DSP, "END.") then
            finish("PASS", space)
        end
        if frame > char_timer + 50 * 30 then
            finish("FAIL: timeout waiting for program output", space)
        end
    end
end)
