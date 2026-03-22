-- mame_comal_for_test.lua — Test COMAL FOR loop
-- Display at 0x0800

local frame = 0
local done = false
local RESULT_FILE = "/tmp/comal_for_test.txt"
local DSP = 0x0800

local commands = {
    "10 for i = 1 to 10\r",
    "20 print i\r",
    "30 next i\r",
    "run\r",
}
local cmd_idx = 0
local state = "wait_boot"
local wait_until = 0

local function screen_text(space)
    local lines = {}
    for row = 0, 24 do
        local line = ""
        for col = 0, 79 do
            local ch = space:read_u8(DSP + row * 80 + col)
            line = line .. (ch >= 0x20 and ch < 0x7F and string.char(ch) or " ")
        end
        lines[#lines + 1] = line:gsub("%s+$", "")
    end
    return table.concat(lines, "\n")
end

local function screen_find(space, str)
    local bytes = {string.byte(str, 1, #str)}
    for addr = DSP, DSP + 2000 - #str do
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
    f:write("\n--- Screen (0x0800) ---\n")
    f:write(screen_text(space) .. "\n")
    f:close()
    done = true
    manager.machine:exit()
end

-- Count how many "* " prompts are on screen (at start of lines)
local function count_prompts(space)
    local count = 0
    for row = 0, 24 do
        local c1 = space:read_u8(DSP + row * 80)
        local c2 = space:read_u8(DSP + row * 80 + 1)
        if c1 == 0x2A and c2 == 0x20 then  -- "* "
            count = count + 1
        end
    end
    return count
end

local last_prompt_count = 0

emu.register_frame_done(function()
    if done then return end
    frame = frame + 1
    if frame < wait_until then return end
    if frame % 10 ~= 0 then return end  -- check every 0.2s

    local space = manager.machine.devices[":maincpu"].spaces["program"]

    if state == "wait_boot" then
        local pc = count_prompts(space)
        if pc > 0 then
            last_prompt_count = pc
            state = "send_next"
            wait_until = frame + 200  -- 4s after boot prompt
        end
        if frame > 50 * 30 then finish("TIMEOUT_BOOT", space) end

    elseif state == "send_next" then
        cmd_idx = cmd_idx + 1
        if cmd_idx > #commands then
            finish("ALL_COMMANDS_SENT", space)
            return
        end
        emu.keypost(commands[cmd_idx])
        state = "wait_prompt"
        wait_until = frame + 150  -- wait 3s for response

    elseif state == "wait_prompt" then
        local pc = count_prompts(space)
        if pc > last_prompt_count then
            last_prompt_count = pc
            state = "send_next"
            wait_until = frame + 50  -- 1s between commands
        end
        if screen_find(space, "fejl") then
            finish("FAIL_FEJL", space)
            return
        end
        if frame > wait_until + 250 then  -- 5s extra timeout
            finish("TIMEOUT_PROMPT", space)
        end
    end

    if frame > 50 * 60 then finish("TIMEOUT_60S", space) end
end)
