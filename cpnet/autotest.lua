-- cpnet_autotest.lua — Automated CP/NET test driver for MAME RC702
--
-- Strategy: Use fixed timeouts instead of fragile prompt detection.
-- Post commands, wait generous fixed periods, then scan screen for results.
--
-- File transfer approach:
--   Binary CP/NET files are pre-converted to Intel HEX on the host.
--   The Lua script types each hex file's content into CP/M via PIP CON:,
--   then LOAD converts each .HEX to a .COM, and REN renames .COM → .SPR
--   for the modules that CPNETLDR expects with a .SPR extension.
--   No files are injected into the disk image.
--
-- State machine:
--   0.  Configure serial (38400 baud, RTS flow control)
--   1.  Wait for A> prompt (CP/M boot complete)
--   2.  PIP current hex file from CON: (types content as keystrokes)
--   2.5 Wait for PIP to finish, advance to next file or go to state 3
--   3.  LOAD all hex files + REN .COM → .SPR, wait for completion
--   4.  CPNETLDR, wait, collect diagnostics
--   5+  NETWORK, DIR, TYPE, PIP round-trip, final results
--
-- Usage: pass as MAME autoboot_script
--   mame rc702 ... -autoboot_script cpnet/autotest.lua

local RESULT_FILE = "/tmp/cpnet_test_results.txt"
local FPS = 50  -- RC702 PAL display refresh rate

-- Timeouts (in frames)
local BOOT_TIMEOUT     = 30 * FPS   -- 30s for CP/M boot
local PIP_RDR_TIMEOUT  = 60 * FPS   -- 60s per file via RDR: (38400 baud, prompt fires first)
local SUBMIT_TIMEOUT   = 120 * FPS  -- 120s for SUBMIT (all LOADs + RENs + CPNETLDR)
local NETWORK_TIMEOUT  = 15 * FPS   -- 15s for NETWORK command
local DIR_TIMEOUT      = 15 * FPS   -- 15s for DIR command
local TYPE_TIMEOUT     = 15 * FPS   -- 15s for TYPE command
local SETTLE_DELAY     =  2 * FPS   -- 2s for display settle
local PIP_TIMEOUT      = 30 * FPS   -- 30s for network PIP copy

-- Display geometry
local DISP_ROWS = 25   -- 25 text rows (rows 0-24)
local DISP_COLS = 80

-- Z80 memory addresses
local DSPSTR    = 0xF800  -- Display buffer start
local BIOS_BASE = 0xDA00  -- 56K BIOS base
local CONOUT_JP = 0xDA0C  -- BIOS CONOUT JP instruction

-- True when files were injected directly into disk ($$$.SUB auto-runs CPNETLDR etc.)
local INJECT_MODE = (function()
    local f = io.open("/tmp/cpnet_inject_mode", "r")
    if f then f:close() return true end
    return false
end)()

-- State machine
local state = 0
local frame = 0
local wait_until = 0
local last_prompt_row = -1
local results = {}
local keyboard_method = nil

-- BDOS vector watchdog
local last_bdos_byte6 = nil
local last_bdos_byte7 = nil
local bdos_changes = {}  -- {frame, old6, old7, new6, new7}

local bigfile_result = nil     -- CRC of locally-copied file

local ORIG_BDOS = 0xCC06  -- BDOS vector before CPNETLDR (JP BDOS)

------------------------------------------------------------------------
-- Memory helpers
------------------------------------------------------------------------

local function mem_read(addr)
    return manager.machine.devices[":maincpu"].spaces["program"]:read_u8(addr)
end

local function mem_read16(addr)
    return mem_read(addr) + mem_read(addr + 1) * 256
end

local function mem_hex(addr, len)
    local s = ""
    for i = 0, len - 1 do
        s = s .. string.format("%02X", mem_read(addr + i))
    end
    return s
end

local function mem_ascii(addr, len)
    local s = ""
    for i = 0, len - 1 do
        local b = mem_read(addr + i)
        if b >= 0x20 and b < 0x7F then
            s = s .. string.char(b)
        else
            s = s .. "."
        end
    end
    return s
end

------------------------------------------------------------------------
-- BDOS vector watchdog — check every frame for changes to 0x0006-0x0007
------------------------------------------------------------------------

local function check_bdos_vector()
    local b6 = mem_read(0x0006)
    local b7 = mem_read(0x0007)
    if last_bdos_byte6 == nil then
        -- First check: just record
        last_bdos_byte6 = b6
        last_bdos_byte7 = b7
        return
    end
    if b6 ~= last_bdos_byte6 or b7 ~= last_bdos_byte7 then
        local entry = {
            frame = frame,
            state = state,
            old6 = last_bdos_byte6, old7 = last_bdos_byte7,
            new6 = b6, new7 = b7
        }
        table.insert(bdos_changes, entry)
        print(string.format(
            "[BDOS WATCH] frame=%d state=%s: [0006-0007] %02X %02X -> %02X %02X (JP %04X -> %04X)",
            frame, tostring(state),
            last_bdos_byte6, last_bdos_byte7,
            b6, b7,
            last_bdos_byte6 + last_bdos_byte7 * 256,
            b6 + b7 * 256))
        last_bdos_byte6 = b6
        last_bdos_byte7 = b7
    end
end

------------------------------------------------------------------------
-- Memory write tap on page zero (0x0000-0x0007) — catch writes to BDOS vector
-- Uses MAME address space write tap API if available
------------------------------------------------------------------------

local write_tap_active = false
local write_tap_log = {}

local function install_bdos_write_tap()
    local ok, err = pcall(function()
        local space = manager.machine.devices[":maincpu"].spaces["program"]
        -- install_write_tap(start, end, name, callback)
        space:install_write_tap(0x0000, 0x000F, "bdos_watch",
            function(offset, data, mask)
                if offset >= 0x0005 and offset <= 0x0007 then
                    -- Get current PC from CPU state
                    local pc = manager.machine.devices[":maincpu"].state["PC"].value
                    local sp = manager.machine.devices[":maincpu"].state["SP"].value
                    local entry = {
                        frame = frame,
                        offset = offset,
                        data = data,
                        mask = mask,
                        pc = pc,
                        sp = sp
                    }
                    table.insert(write_tap_log, entry)
                    print(string.format(
                        "[WRITE TAP] frame=%d PC=%04X SP=%04X: write %02X to %04X (mask=%02X)",
                        frame, pc, sp, data, offset, mask))
                end
                return data  -- pass through unchanged
            end)
        write_tap_active = true
        print("[autotest] Memory write tap installed on 0x0000-0x000F")
    end)
    if not ok then
        print("[autotest] Write tap not available: " .. tostring(err))
    end
end

------------------------------------------------------------------------
-- Memory dump helper — dump a region as hex+ascii
------------------------------------------------------------------------

local function mem_dump(label, addr, len)
    print(string.format("\n[MEMDUMP] %s  addr=%04X len=%d", label, addr, len))
    for offset = 0, len - 1, 16 do
        local hex = ""
        local asc = ""
        for i = 0, 15 do
            if offset + i < len then
                local b = mem_read(addr + offset + i)
                hex = hex .. string.format("%02X ", b)
                if b >= 0x20 and b < 0x7F then
                    asc = asc .. string.char(b)
                else
                    asc = asc .. "."
                end
            end
        end
        print(string.format("  %04X: %-48s %s", addr + offset, hex, asc))
    end
end

------------------------------------------------------------------------
-- Display helpers
------------------------------------------------------------------------

local function display_char(row, col)
    if row < 0 or row >= DISP_ROWS or col < 0 or col >= DISP_COLS then
        return 0
    end
    return mem_read(DSPSTR + row * DISP_COLS + col)
end

-- Read full display row as trimmed string
local function display_row(row)
    local s = mem_ascii(DSPSTR + row * DISP_COLS, DISP_COLS)
    return s:match("^(.-)%s*$")  -- right-trim spaces
end

local function clear_display()
    local space = manager.machine.devices[":maincpu"].spaces["program"]
    for i = 0, DISP_ROWS * DISP_COLS - 1 do
        space:write_u8(DSPSTR + i, 0x20)
    end
end

-- Dump entire screen to console
local function dump_screen(label)
    print(string.format("--- screen dump [%s] frame=%d ---", label, frame))
    for row = 0, DISP_ROWS - 1 do
        local line = display_row(row)
        if #line > 0 then
            print(string.format("  %2d: [%s]", row, line))
        end
    end
    print("---")
end

-- Scan all visible rows for a substring; return row number or nil
local function screen_find(substr)
    for row = 0, DISP_ROWS - 2 do
        if display_row(row):find(substr, 1, true) then
            return row
        end
    end
    return nil
end

-- Check if bare "A> " appears at the start of a line.
-- Requires col 2 == space to distinguish "A>" from "A>COMMAND".
local function is_prompt_at(row)
    return display_char(row, 0) == 0x41   -- 'A'
        and display_char(row, 1) == 0x3E  -- '>'
        and display_char(row, 2) == 0x20  -- space (bare prompt only)
end

-- Find the lowest (latest) A> prompt on screen (rows 0-23)
local function find_prompt()
    for row = 23, 0, -1 do
        if is_prompt_at(row) then
            return row
        end
    end
    return nil
end

-- Detect a NEW A> prompt (different row than last seen)
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
        if nk and nk.post then
            keyboard_method = "natkeyboard"
        end
    end)
    if keyboard_method then return end

    ok = pcall(function()
        if manager.machine.keypost then
            keyboard_method = "keypost"
        end
    end)
    if keyboard_method then return end

    print("[autotest] WARNING: no keyboard input method detected")
end

local function type_text(text)
    if keyboard_method == "natkeyboard" then
        manager.machine.natkeyboard:post(text)
    elseif keyboard_method == "keypost" then
        manager.machine:keypost(text)
    else
        print("[autotest] CANNOT TYPE: " .. text)
    end
end

------------------------------------------------------------------------
-- Serial port configuration (38400 baud, RTS flow control)
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
                    field.user_value = 0x01  -- RTS
                end
            end
        end
    end
end


------------------------------------------------------------------------
-- Diagnostics collection
------------------------------------------------------------------------

local function collect_diagnostics(label)
    local d = {}
    d.label = label
    d.frame = frame

    -- BIOS CONOUT JP instruction (3 bytes at DA0Ch)
    d.conout_opcode = mem_read(CONOUT_JP)
    d.conout_target = mem_read16(CONOUT_JP + 1)

    -- BIOS WBOOT JP target (DA03h)
    d.wboot_target = mem_read16(BIOS_BASE + 4)

    -- BDOS vector at 0005h-0006h
    d.bdos_vector = mem_read16(0x0006)

    -- Prompt visible?
    d.prompt_visible = (find_prompt() ~= nil)

    -- ALL display rows (full screen)
    d.rows = {}
    for row = 0, DISP_ROWS - 1 do
        d.rows[row] = display_row(row)
    end

    table.insert(results, d)

    -- Console output
    print(string.format("\n[%s] frame=%d", label, frame))
    print(string.format("  CONOUT JP: %02X -> %04X", d.conout_opcode, d.conout_target))
    print(string.format("  WBOOT JP -> %04X, BDOS -> %04X", d.wboot_target, d.bdos_vector))
    print(string.format("  Prompt visible: %s", d.prompt_visible and "YES" or "NO"))
    for row = 0, DISP_ROWS - 1 do
        if #d.rows[row] > 0 then
            print(string.format("  %2d: [%s]", row, d.rows[row]))
        end
    end
end

------------------------------------------------------------------------
-- Results output
------------------------------------------------------------------------

local function write_results()
    local f = io.open(RESULT_FILE, "w")
    if not f then
        print("[autotest] ERROR: cannot write " .. RESULT_FILE)
        return
    end

    -- Big file CRC result
    if bigfile_result then
        f:write("=== BIGFILE TRANSFER ===\n")
        f:write("BIGFILE_RESULT=" .. bigfile_result .. "\n\n")
    end

    -- BDOS vector change log
    if #bdos_changes > 0 then
        f:write("=== BDOS VECTOR CHANGES ===\n")
        for _, entry in ipairs(bdos_changes) do
            f:write(string.format(
                "frame=%d state=%s: [0006-0007] %02X %02X -> %02X %02X (JP %04X -> %04X)\n",
                entry.frame, tostring(entry.state),
                entry.old6, entry.old7, entry.new6, entry.new7,
                entry.old6 + entry.old7 * 256,
                entry.new6 + entry.new7 * 256))
        end
        f:write("\n")
    end

    -- Diagnostic snapshots
    for _, d in ipairs(results) do
        f:write(string.format("=== %s (frame %d) ===\n", d.label, d.frame))
        f:write(string.format("CONOUT_OPCODE=%02X\n", d.conout_opcode))
        f:write(string.format("CONOUT_TARGET=%04X\n", d.conout_target))
        f:write(string.format("WBOOT_TARGET=%04X\n", d.wboot_target))
        f:write(string.format("BDOS_VECTOR=%04X\n", d.bdos_vector))
        f:write(string.format("PROMPT_VISIBLE=%s\n", d.prompt_visible and "YES" or "NO"))
        for row = 0, DISP_ROWS - 1 do
            local line = d.rows[row]
            if #line > 0 then
                f:write(string.format("ROW%02d=%s\n", row, line))
            end
        end
        f:write("\n")
    end

    f:close()
    print("\n[autotest] Results written to " .. RESULT_FILE)
end

------------------------------------------------------------------------
-- State machine — fixed timeouts, no fragile prompt detection
------------------------------------------------------------------------

local function advance_state()
    if state == 0 then
        -- Configure serial and detect keyboard
        configure_serial()
        detect_keyboard()
        print("[autotest] Serial: 38400/RTS, keyboard: " .. (keyboard_method or "NONE"))
        state = 1
        wait_until = frame + BOOT_TIMEOUT

    elseif state == 1 then
        -- Wait for first A> prompt (CP/M boot) — only state using prompt detection
        if new_prompt() then
            print(string.format("[autotest] CP/M booted (frame %d)", frame))
            collect_diagnostics("boot")
            state = INJECT_MODE and 3 or 2
            wait_until = frame + 1
        elseif frame > wait_until then
            print("[autotest] TIMEOUT: boot")
            dump_screen("boot_timeout")
            collect_diagnostics("boot_timeout")
            write_results()
            state = 99
            manager.machine:exit()
        end

    elseif state == 2 then
        -- Get GO.SUB from the serial port.  server.py sends GO.SUB first,
        -- then the hex files in the order the PIP commands inside GO.SUB request.
        if frame >= wait_until then
            print("[autotest] PIP GO.SUB=RDR:")
            type_text("PIP GO.SUB=RDR:\r")
            state = 2.5
            wait_until = frame + PIP_RDR_TIMEOUT
        end

    elseif state == 2.5 then
        -- Wait for GO.SUB to be written (A> prompt after PIP finishes).
        if new_prompt() or frame >= wait_until then
            if frame >= wait_until then
                print("[autotest] WARNING: PIP GO.SUB=RDR: timeout")
            end
            dump_screen("after_pip_gosub")
            state = 3
            wait_until = frame + 1
        end

    elseif state == 3 then
        -- Serial mode: LOAD all hex files + REN .COM→.SPR + CPNETLDR via SUBMIT GO.
        -- Inject mode: $$$.SUB runs CPNETLDR + NETWORK H:=B: + DIR H: automatically.
        if frame >= wait_until then
            if INJECT_MODE then
                print("[autotest] Inject mode: $$$.SUB will run CPNETLDR + NETWORK + DIR automatically")
            else
                print("[autotest] Running: SUBMIT GO (LOADs + RENs + CPNETLDR)")
                type_text("SUBMIT GO\r")
            end
            state = 3.5
            wait_until = frame + SUBMIT_TIMEOUT
        end

    elseif state == 3.5 then
        -- SUBMIT/inject is running: detect CPNETLDR by watching for BDOS vector change.
        -- Serial mode: give CCP 3s to restart before typing NETWORK.
        -- Inject mode: wait 20s after BDOS change — $$$.SUB still runs NETWORK + DIR.
        local bdos_now = mem_read16(0x0006)
        if bdos_now ~= ORIG_BDOS then
            local settle = INJECT_MODE and (20 * FPS) or (3 * FPS)
            local deadline = frame + settle
            if wait_until > deadline then
                print(string.format(
                    "[autotest] CPNETLDR detected (BDOS now %04X, frame %d)",
                    bdos_now, frame))
                wait_until = deadline
            end
        end
        if frame >= wait_until then
            if mem_read16(0x0006) == ORIG_BDOS then
                print("[autotest] WARNING: SUBMIT timeout — CPNETLDR may not have run")
            end
            clear_display()
            dump_screen("after_submit")
            collect_diagnostics("after_cpnetldr")
            -- Inject: NETWORK + DIR already ran from $$$.SUB; skip to state 7
            state = INJECT_MODE and 7 or 6
            wait_until = frame + 1
        end

    elseif state == 6 then
        -- Post NETWORK H:=B:
        if frame >= wait_until then
            print("[autotest] Typing: NETWORK H:=B:")
            type_text("NETWORK H:=B:\r")
            state = 7
            wait_until = frame + NETWORK_TIMEOUT
        end

    elseif state == 7 then
        -- Wait for NETWORK to complete; fail fast if CP/NET not loaded.
        -- Poll each frame so we catch the error message as soon as it appears.
        local not_loaded_row = screen_find("CP/Net is not loaded.")
        if not_loaded_row then
            print("[autotest] FATAL: CP/Net is not loaded.")
            dump_screen("cpnet_not_loaded")
            collect_diagnostics("cpnet_not_loaded")
            table.insert(results, { label="FATAL", frame=frame,
                conout_opcode=mem_read(CONOUT_JP),
                conout_target=mem_read16(CONOUT_JP+1),
                wboot_target=mem_read16(BIOS_BASE+4),
                bdos_vector=mem_read16(0x0006),
                prompt_visible=false,
                rows={ [0]="FATAL: CP/Net is not loaded." } })
            write_results()
            state = 99
            manager.machine:exit()
            return
        end
        if frame >= wait_until then
            local prompt_row = find_prompt()
            if prompt_row then
                print("[autotest] NETWORK complete (prompt VISIBLE)")
            else
                print("[autotest] NETWORK: NO visible prompt")
            end
            dump_screen("after_network")
            collect_diagnostics("after_network")
            -- Inject: DIR already ran from $$$.SUB; skip Lua-driven DIR (states 8+9)
            state = INJECT_MODE and 10 or 8
            wait_until = frame + 1
        end

    elseif state == 8 then
        -- Post DIR H:
        if frame >= wait_until then
            print("[autotest] Typing: DIR H:")
            type_text("DIR H:\r")
            state = 9
            wait_until = frame + DIR_TIMEOUT
        end

    elseif state == 9 then
        -- Wait for DIR to complete
        if frame >= wait_until then
            dump_screen("after_dir")
            collect_diagnostics("after_dir")
            state = 10
            wait_until = frame + 1
        end

    elseif state == 10 then
        -- Post TYPE H:HELLO.TXT
        if frame >= wait_until then
            print("[autotest] Typing: TYPE H:HELLO.TXT")
            type_text("TYPE H:HELLO.TXT\r")
            state = 11
            wait_until = frame + TYPE_TIMEOUT
        end

    elseif state == 11 then
        -- Wait for TYPE to complete
        if frame >= wait_until then
            dump_screen("after_type")
            collect_diagnostics("after_type")
            state = 12
            wait_until = frame + SETTLE_DELAY
        end

    elseif state == 12 then
        -- PIP leg 1: copy HELLO.TXT from network drive to local A:
        if frame >= wait_until then
            print("[autotest] PIP leg 1: A:HELLCOPY.TXT=H:HELLO.TXT")
            type_text("PIP A:HELLCOPY.TXT=H:HELLO.TXT\r")
            state = 13
            wait_until = frame + PIP_TIMEOUT
        end

    elseif state == 13 then
        -- Wait for PIP leg 1 to complete
        if frame >= wait_until then
            dump_screen("after_pip_leg1")
            -- PIP leg 2: copy local file back to network drive under new name
            print("[autotest] PIP leg 2: H:HLCOPY2.TXT=A:HELLCOPY.TXT")
            type_text("PIP H:HLCOPY2.TXT=A:HELLCOPY.TXT\r")
            state = 14
            wait_until = frame + 5 * FPS  -- short wait to see PIP output
        end

    elseif state == 14 then
        -- Short wait — capture PIP leg 2 screen before it scrolls
        if frame >= wait_until then
            collect_diagnostics("pip_leg2_early")
            -- Wait the rest of PIP_TIMEOUT
            state = 15
            wait_until = frame + PIP_TIMEOUT
        end

    elseif state == 15 then
        -- Wait for PIP leg 2 to complete
        if frame >= wait_until then
            dump_screen("after_pip_leg2_end")
            -- Also CHKSUM the local copy to verify the network read
            print("[autotest] Checking CHKSUM of local A:HELLCOPY.TXT")
            type_text("CHKSUM A:HELLCOPY.TXT\r")
            state = 16
            wait_until = frame + 10 * FPS
        end

    elseif state == 16 then
        -- Wait for CHKSUM of local copy
        if frame >= wait_until then
            dump_screen("after_local_chksum")
            -- Scan screen for the CHKSUM result
            for row = 0, 22 do
                local line = display_row(row)
                if line:find("CHKSUM A:HELLCOPY.TXT", 1, true) then
                    local result_line = display_row(row + 1)
                    local actual = result_line:match("^(%x%x%x%x)$")
                        or result_line:match("^(%x%x%x%x)%s")
                    if actual then
                        bigfile_result = string.format("LOCAL_HELLCOPY_CRC=%s", actual:upper())
                        print("[autotest] HELLCOPY.TXT local CRC: " .. actual:upper())
                    else
                        bigfile_result = "LOCAL_HELLCOPY_CRC=NOT_FOUND"
                    end
                    break
                end
            end
            if not bigfile_result then
                bigfile_result = "PIP_ROUNDTRIP_ATTEMPTED"
            end
            collect_diagnostics("after_pip")
            state = 17
            wait_until = frame + SETTLE_DELAY
        end

    elseif state == 17 then
        -- Final diagnostics and results
        if frame >= wait_until then
            collect_diagnostics("final")
            write_results()
            print("\n[autotest] === TEST COMPLETE ===")
            state = 99
            manager.machine:exit()
        end
    end
end

------------------------------------------------------------------------
-- Register frame callback
------------------------------------------------------------------------

emu.register_periodic(function()
    frame = frame + 1
    -- Monitor BDOS vector for unexpected changes (starting from state 3+)
    if state >= 3 then
        check_bdos_vector()
    end
    if state < 99 then
        advance_state()
    end
end, "cpnet_autotest")

print("[autotest] CP/NET autotest loaded (waiting for boot...)")
