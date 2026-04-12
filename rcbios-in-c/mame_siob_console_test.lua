-- mame_siob_console_test.lua
--
-- Autoboot Lua for SIO-B serial console integration test.
-- The Python server sends commands via the bitb2 socket and captures
-- serial output. This Lua script waits for completion, then captures
-- the CRT display and compares.
--
-- Flow:
--   1. Boot to A> with "Console also on serial port B" banner
--   2. Server sends DIR, ASM FILEX, TYPE FILEX.PRN via serial
--   3. Lua waits for server "done" signal
--   4. Capture CRT display, write to file
--   5. Compare serial output vs CRT content

local FPS = 50
local frame = 0
local done = false
local state = "boot"
local wait_frames = 0

local function log(msg) print("[con-test] " .. msg) end

local function mem_read(addr)
    return manager.machine.devices[":maincpu"].spaces["program"]:read_u8(addr)
end

local function screen_text()
    local rows = {}
    for row = 0, 24 do
        local line = ""
        for col = 0, 79 do
            local ch = mem_read(0xF800 + row * 80 + col)
            line = line .. (ch >= 0x20 and ch < 0x7F and string.char(ch) or " ")
        end
        rows[#rows + 1] = line:gsub("%s+$", "")
    end
    return table.concat(rows, "\n")
end

local function screen_contains(needle)
    for row = 0, 24 do
        local line = ""
        for col = 0, 79 do
            local ch = mem_read(0xF800 + row * 80 + col)
            line = line .. (ch >= 0x20 and ch < 0x7F and string.char(ch) or " ")
        end
        if line:find(needle, 1, true) then return true end
    end
    return false
end

local function file_exists(path)
    local f = io.open(path, "r")
    if f then f:close(); return true end
    return false
end

local function write_result(pass, reason)
    local f = io.open("/tmp/siob_console_result", "w")
    f:write(pass and "PASS\n" or "FAIL\n")
    f:write(reason .. "\n")
    f:write("--- CRT ---\n")
    f:write(screen_text() .. "\n")
    f:close()
end

local function finish(pass, reason)
    log(reason)
    log(pass and "=== PASS ===" or "=== FAIL ===")
    write_result(pass, reason)
    done = true
    manager.machine:exit()
end

-- Force rs232b baud to 38400 (MAME may have stale overrides)
emu.register_frame_done(function()
    if done then return end
    frame = frame + 1

    if frame == 1 then
        local ports = manager.machine.ioport.ports
        for tag, port in pairs(ports) do
            if tag:find("rs232b") and (tag:find("RS232_TXBAUD") or tag:find("RS232_RXBAUD")) then
                for _, field in pairs(port.fields) do
                    field.user_value = 0x0b  -- RS232_BAUD_38400
                end
            end
        end
        log("rs232b baud forced to 38400")
    end

    if frame > FPS * 300 then finish(false, "GLOBAL TIMEOUT"); return end

    if state == "boot" then
        -- Wait for banner with serial port announcement
        if frame > FPS * 5 and screen_contains("Console also on serial port B") then
            log("Banner detected — serial console active")
            state = "wait_server"
            wait_frames = 0
        elseif frame > FPS * 30 then
            if screen_contains("A>") then
                -- Booted but no serial banner — DCD not detected
                finish(false, "No serial console banner — DCD not asserted")
            else
                finish(false, "TIMEOUT waiting for boot")
            end
        end

    elseif state == "wait_server" then
        -- Server sends commands and captures output via serial.
        -- Wait for /tmp/siob_console_done signal file.
        wait_frames = wait_frames + 1
        -- Periodic debug: check SIO-B ring buffer and IOBYTE
        if wait_frames % (FPS * 5) == 0 then
            local iob = mem_read(0x0003)
            -- wb struct address from nm: adjust if BIOS changes
            local wb_addr = 0xED4C  -- from llvm-nm _wb
            local rxhead_b = mem_read(wb_addr + 5)
            local rxtail_b = mem_read(wb_addr + 6)
            log(string.format("  waiting: IOBYTE=%02X rxhead_b=%02X rxtail_b=%02X frame=%d",
                iob, rxhead_b, rxtail_b, wait_frames))
        end
        if file_exists("/tmp/siob_console_done") then
            log("Server done, capturing CRT")
            state = "verify"
        elseif wait_frames > FPS * 90 then
            finish(false, "TIMEOUT waiting for server to finish")
        end

    elseif state == "verify" then
        -- Read server's serial capture and compare with CRT
        local serial_f = io.open("/tmp/siob_console_serial.txt", "r")
        if not serial_f then
            finish(false, "Cannot read serial capture file")
            return
        end
        local serial_text = serial_f:read("*a")
        serial_f:close()

        local crt = screen_text()

        -- Check that key content appears on BOTH outputs
        local checks = {
            {"DIR listing", "FILEX"},
            {"ASM output", "ASM"},
            {"A> prompt", "A>"},
        }

        local all_pass = true
        for _, check in ipairs(checks) do
            local label, needle = check[1], check[2]
            local on_serial = serial_text:find(needle, 1, true) ~= nil
            local on_crt = crt:find(needle, 1, true) ~= nil
            log(string.format("  %s: serial=%s CRT=%s",
                label,
                on_serial and "YES" or "NO",
                on_crt and "YES" or "NO"))
            if not on_serial then
                log("  FAIL: '" .. needle .. "' missing from serial output")
                all_pass = false
            end
            if not on_crt then
                log("  FAIL: '" .. needle .. "' missing from CRT display")
                all_pass = false
            end
        end

        -- Write CRT dump for manual inspection
        local crt_f = io.open("/tmp/siob_console_crt.txt", "w")
        crt_f:write(crt)
        crt_f:close()

        if all_pass then
            finish(true, "All content verified on both serial and CRT")
        else
            finish(false, "Content mismatch between serial and CRT")
        end
    end
end)
