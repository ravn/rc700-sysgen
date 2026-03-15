-- setup.lua — CP/NET setup driver for interactive MAME sessions
--
-- Performs the full bootstrap sequence automatically:
--   1. Configure serial (38400 baud, RTS flow control)
--   2. Wait for CP/M A> prompt
--   3. PIP GO.SUB=RDR:  (server sends GO.SUB + hex files)
--   4. SUBMIT GO        (LOADs, RENs, CPNETLDR)
--   5. NETWORK H:=B:
--
-- After that it goes idle — MAME keeps running and you can use
-- the emulator interactively.  Close the MAME window when done.

local FPS = 50

local BOOT_TIMEOUT    = 30 * FPS
local PIP_RDR_TIMEOUT = 60 * FPS
local SUBMIT_TIMEOUT  = 120 * FPS
local NETWORK_TIMEOUT = 15 * FPS

local DISP_ROWS = 25
local DISP_COLS = 80
local DSPSTR    = 0xF800
local BIOS_BASE = 0xDA00

local ORIG_BDOS = 0xCC06

-- True when files were injected directly into disk ($$$.SUB auto-runs CPNETLDR etc.)
local INJECT_MODE = (function()
    local f = io.open("/tmp/cpnet_inject_mode", "r")
    if f then f:close() return true end
    return false
end)()

local state = 0
local frame = 0
local wait_until = 0
local last_prompt_row = -1
local keyboard_method = nil

------------------------------------------------------------------------
-- Memory helpers
------------------------------------------------------------------------

local function mem_read(addr)
    return manager.machine.devices[":maincpu"].spaces["program"]:read_u8(addr)
end

local function mem_read16(addr)
    return mem_read(addr) + mem_read(addr + 1) * 256
end

local function mem_ascii(addr, len)
    local s = ""
    for i = 0, len - 1 do
        local b = mem_read(addr + i)
        if b >= 0x20 and b < 0x7F then s = s .. string.char(b)
        else s = s .. "." end
    end
    return s
end

------------------------------------------------------------------------
-- Display helpers
------------------------------------------------------------------------

local function display_char(row, col)
    if row < 0 or row >= DISP_ROWS or col < 0 or col >= DISP_COLS then return 0 end
    return mem_read(DSPSTR + row * DISP_COLS + col)
end

local function display_row(row)
    local s = mem_ascii(DSPSTR + row * DISP_COLS, DISP_COLS)
    return s:match("^(.-)%s*$")
end

local function clear_display()
    local space = manager.machine.devices[":maincpu"].spaces["program"]
    for i = 0, DISP_ROWS * DISP_COLS - 1 do
        space:write_u8(DSPSTR + i, 0x20)
    end
end

local function dump_screen(label)
    print(string.format("--- screen [%s] frame=%d ---", label, frame))
    for row = 0, DISP_ROWS - 1 do
        local line = display_row(row)
        if #line > 0 then print(string.format("  %2d: [%s]", row, line)) end
    end
    print("---")
end

local function screen_find(substr)
    for row = 0, DISP_ROWS - 2 do
        if display_row(row):find(substr, 1, true) then return row end
    end
    return nil
end

local function is_prompt_at(row)
    return display_char(row, 0) == 0x41
       and display_char(row, 1) == 0x3E
       and display_char(row, 2) == 0x20
end

local function find_prompt()
    for row = 23, 0, -1 do
        if is_prompt_at(row) then return row end
    end
    return nil
end

local function new_prompt()
    local row = find_prompt()
    if row and row ~= last_prompt_row then
        last_prompt_row = row
        return true
    end
    return false
end

------------------------------------------------------------------------
-- Keyboard input
------------------------------------------------------------------------

local function detect_keyboard()
    local ok = pcall(function()
        local nk = manager.machine.natkeyboard
        if nk and nk.post then keyboard_method = "natkeyboard" end
    end)
    if keyboard_method then return end
    ok = pcall(function()
        if manager.machine.keypost then keyboard_method = "keypost" end
    end)
    if not keyboard_method then
        print("[setup] WARNING: no keyboard input method detected")
    end
end

local function type_text(text)
    if keyboard_method == "natkeyboard" then
        manager.machine.natkeyboard:post(text)
    elseif keyboard_method == "keypost" then
        manager.machine:keypost(text)
    else
        print("[setup] CANNOT TYPE: " .. text)
    end
end

------------------------------------------------------------------------
-- Serial configuration
------------------------------------------------------------------------

local function configure_serial()
    local ports = manager.machine.ioport.ports
    for tag, port in pairs(ports) do
        if tag:find("RS232_TXBAUD") or tag:find("RS232_RXBAUD") then
            for _, field in pairs(port.fields) do
                field.user_value = 0x0b  -- RS232_BAUD_38400
            end
        end
        if tag:find("FLOW_CONTROL") then
            for _, field in pairs(port.fields) do
                if field.name:find("Flow Control") then
                    field.user_value = 0x00  -- Off (was RTS; debugging RX)
                end
            end
        end
    end
end

------------------------------------------------------------------------
-- State machine
------------------------------------------------------------------------

local function advance_state()
    if state == 0 then
        configure_serial()
        detect_keyboard()
        manager.machine.video.throttled = false  -- run fast during bootstrap
        print("[setup] Serial: 38400/RTS, keyboard: " .. (keyboard_method or "NONE"))
        state = 1
        wait_until = frame + BOOT_TIMEOUT

    elseif state == 1 then
        if new_prompt() then
            print(string.format("[setup] CP/M booted (frame %d)", frame))
            state = INJECT_MODE and 3 or 2
            wait_until = frame + 1
        elseif frame > wait_until then
            print("[setup] TIMEOUT: waiting for CP/M boot")
            dump_screen("boot_timeout")
            state = 99
        end

    elseif state == 2 then
        if frame >= wait_until then
            print("[setup] PIP GO.SUB=RDR:")
            type_text("PIP GO.SUB=RDR:\r")
            state = 2.5
            wait_until = frame + PIP_RDR_TIMEOUT
        end

    elseif state == 2.5 then
        if new_prompt() or frame >= wait_until then
            if frame >= wait_until then
                print("[setup] WARNING: PIP GO.SUB=RDR: timeout")
            end
            state = 3
            wait_until = frame + 1
        end

    elseif state == 3 then
        if frame >= wait_until then
            if INJECT_MODE then
                print("[setup] Inject mode: $$$.SUB will run CPNETLDR + NETWORK + DIR automatically")
            else
                print("[setup] Running: SUBMIT GO")
                type_text("SUBMIT GO\r")
            end
            state = 3.5
            wait_until = frame + SUBMIT_TIMEOUT
        end

    elseif state == 3.5 then
        local bdos_now = mem_read16(0x0006)
        if bdos_now ~= ORIG_BDOS then
            -- In inject mode wait longer: NETWORK H:=B: + DIR H: still run from $$$.SUB
            local settle = INJECT_MODE and (20 * FPS) or (3 * FPS)
            local deadline = frame + settle
            if wait_until > deadline then
                print(string.format("[setup] CPNETLDR detected (BDOS now %04X, frame %d)",
                    bdos_now, frame))
                wait_until = deadline
            end
        end
        if frame >= wait_until then
            if mem_read16(0x0006) == ORIG_BDOS then
                print("[setup] WARNING: SUBMIT timeout — CPNETLDR may not have run")
            end
            -- Inject: NETWORK + DIR already ran from $$$.SUB; skip to state 5
            state = INJECT_MODE and 5 or 4
            wait_until = frame + 1
        end

    elseif state == 4 then
        if frame >= wait_until then
            print("[setup] Typing: NETWORK H:=B:")
            type_text("NETWORK H:=B:\r")
            state = 5
            wait_until = frame + NETWORK_TIMEOUT
        end

    elseif state == 5 then
        local not_loaded = screen_find("CP/Net is not loaded.")
        if not_loaded then
            print("[setup] FATAL: CP/Net is not loaded.")
            dump_screen("cpnet_not_loaded")
            state = 99
            return
        end
        if frame >= wait_until then
            manager.machine.video.throttled = true  -- restore normal speed for interactive use
            dump_screen("ready")
            local bdos = mem_read16(0x0006)
            print(string.format(
                "\n[setup] === READY === H: is mounted on B:  (BDOS=%04X)\n" ..
                "[setup] MAME window is now under your control.\n",
                bdos))
            state = 99  -- idle — do NOT exit MAME
        end
    end
end

------------------------------------------------------------------------
-- Frame callback
------------------------------------------------------------------------

emu.register_periodic(function()
    frame = frame + 1
    if state < 99 then
        advance_state()
    end
end, "cpnet_setup")

print("[setup] CP/NET setup loaded (waiting for boot...)")
