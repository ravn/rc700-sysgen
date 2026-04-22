-- cpnos-rom MAME boot test
--
-- PASS: "CPNOS" appears at top-left of display memory (0xF800+).
-- FAIL: timeout, or something garbled there.

local frame = 0
local done = false
local DSPSTR = 0xF800
local RESULT_FILE = "/tmp/cpnos_boot_result.txt"

-- After the PASS/FAIL condition is first detected, keep the emulation
-- running for this many frames so SIO-B TX finishes draining (at 38400
-- baud a byte needs ~13 frames of 1/50 s to transmit; 15 frames covers
-- any short tail like "\r\nA>").
local DRAIN_FRAMES = 15
local pending_finish = nil
local pending_frame  = 0

-- Breadcrumb log: append a line each second with PC/SP and the trace
-- counters at 0xEC40..0xEC43 so we can see when CCP first reaches any
-- BIOS entry and in what sequence.  Open with "w" once per run so the
-- file is fresh.  Issue #38.
local TRACE_FILE = "/tmp/cpnos_boot_trace.txt"
local trace_f = io.open(TRACE_FILE, "w")
if trace_f then
    trace_f:write("# frame t(s)  PC   SP   CONOUT last CONST CONIN CRT_tick NB_step NB_rc\n")
    trace_f:flush()
end
local last_conout  = -1
local last_const   = -1
local last_conin   = -1
local last_last    = -1
local last_nb_step = -1
local last_nb_rc   = -1

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

    f:write("\n--- 0x0000 (reset vector / PROM0 shadow + BDOS vector) ---\n")
    f:write(hex_dump(space, 0x0000, 48) .. "\n")
    -- Expected: 00=0xA5, 01=0x5A (sentinels), 05=0xC3 06 DE (JP 0xDE06 BDOS).
    f:write(string.format("BDOS vector [0x0005..7]=%02x %02x %02x (want c3 06 de)\n",
        space:read_u8(0x0005), space:read_u8(0x0006), space:read_u8(0x0007)))
    f:write("\n--- 0xD000 (BOOT = cpnos stub: JP BIOS) ---\n")
    f:write(hex_dump(space, 0xD000, 16) .. "\n")
    f:write("\n--- 0xD003 (NDOS = JP NDOSE, JP COLDST) ---\n")
    f:write(hex_dump(space, 0xD003, 16) .. "\n")
    f:write("\n--- 0xDC10 (BIOS jump table) ---\n")
    f:write(hex_dump(space, 0xDC10, 51) .. "\n")
    -- NDOS COLDST walks TOP+1 (our BIOS JT at 0xED00) and writes a
    -- patched copy at NDOSRL+0x300 = 0xCC00+0x300 = 0xCF00 with
    -- intercepts for CONOUT/LIST/etc.  CCP calls BIOS through this
    -- patched table, not our JT directly.  If CONOUT isn't reaching
    -- our _impl_conout, this is where to look.  Issue #38.
    f:write("\n--- 0xCF00 (NDOS-patched BIOS JT = NDOSRL+0x300) ---\n")
    f:write(hex_dump(space, 0xCF00, 51) .. "\n")
    -- Our BIOS JT at 0xED00 should be c3 xx xx c3 xx xx ... after
    -- the cpnos_main memcpy.  The patched copy at 0xCF00 should have
    -- the same layout but with CONOUT/LIST/etc. rewritten to NDOS's
    -- intercept wrappers.  If 0xCF00 is full of 0x00 or 0xFF, NDOS's
    -- walk never ran.  If offsets 0xCF0C..0xCF0E (CONOUT slot) don't
    -- contain c3 + an address, that's why CONOUT is broken.
    f:write("\n--- 0xED00 (our BIOS JT VMA) ---\n")
    f:write(hex_dump(space, 0xED00, 51) .. "\n")
    -- Image signature: BOOT at 0xD000 is `JP 0xDC10` (BIOS) = c3 10 dc.
    local boot0 = space:read_u8(0xD000)
    local boot2 = space:read_u8(0xD002)
    f:write(string.format(
        "BOOT[0xD000..2]=%02x ?? %02x (want c3 10 dc)\n",
        boot0, boot2))
    f:write("\n--- 0xEC00 (breadcrumbs; 0xEC20 = CRT ISR tick counter) ---\n")
    -- Dump through 0xEC5F so the impl_conout/const/conin breadcrumb
    -- counters at 0xEC40..0xEC43 (resident.c) are visible.  Keep until
    -- issue #38 (boot path flaky) is reliably green.
    f:write(hex_dump(space, 0xEC00, 96) .. "\n")
    f:write(string.format("CRT ISR ticks = %d (expect > 0 if VRTC wired)\n",
        space:read_u8(0xEC20)))
    f:write("\n--- 0xE400 (cpnos_main breadcrumbs) ---\n")
    f:write(hex_dump(space, 0xE400, 16) .. "\n")
    f:write("\n--- CFGTBL (SLAVEID must be 0x70 at +1) ---\n")
    local cfg_addr = 0xF4D4                 -- _cfgtbl (check with `llvm-nm --numeric-sort cpnos.elf | grep _cfgtbl`)
    f:write(hex_dump(space, cfg_addr, 48) .. "\n")
    local slaveid = space:read_u8(cfg_addr + 1)
    f:write(string.format("SLAVEID = 0x%02x (want 0x70)\n", slaveid))
    local netst = space:read_u8(cfg_addr + 0)
    f:write(string.format("NETST   = 0x%02x (want 0x10 after NTWKIN)\n", netst))
    -- SNIOS SNDMSG/RCVMSG smoke probes removed: NDOS now drives SNIOS.

    f:write("\n--- 0xF200 (resident VMA) ---\n")
    f:write(hex_dump(space, 0xF200, 128) .. "\n")
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

    local space = manager.machine.devices[":maincpu"].spaces["program"]

    -- If a result is pending, hold the frame loop open for DRAIN_FRAMES
    -- before calling finish() so SIO-B TX has time to flush.
    if pending_finish ~= nil then
        if frame - pending_frame >= DRAIN_FRAMES then
            finish(pending_finish, space)
        end
        return
    end

    -- Log breadcrumbs every 50 frames (~1 s) OR whenever any counter
    -- changes since the last log line, so we see the first CONOUT/CONIN
    -- event down to ~20ms resolution without spamming the file.
    if trace_f ~= nil then
        local conout = space:read_u8(0xEC40)
        local last   = space:read_u8(0xEC41)
        local const  = space:read_u8(0xEC42)
        local conin  = space:read_u8(0xEC43)
        local nb_step = space:read_u8(0xEC44)
        local nb_rc   = space:read_u8(0xEC45)
        if conout ~= last_conout or const ~= last_const
           or conin ~= last_conin or last ~= last_last
           or nb_step ~= last_nb_step or nb_rc ~= last_nb_rc
           or frame % 50 == 0 then
            local pc = manager.machine.devices[":maincpu"].state["PC"].value
            local sp = manager.machine.devices[":maincpu"].state["SP"].value
            local crt_tick = space:read_u8(0xEC20)
            trace_f:write(string.format(
                "%5d %6.2f %04X %04X  %3d %02x  %3d  %3d   %3d    %02x    %02x\n",
                frame, frame / 50.0, pc, sp,
                conout, last, const, conin, crt_tick, nb_step, nb_rc))
            trace_f:flush()
            last_conout  = conout
            last_const   = const
            last_conin   = conin
            last_last    = last
            last_nb_step = nb_step
            last_nb_rc   = nb_rc
        end
    end

    if frame % 25 ~= 0 then return end  -- every ~0.5s

    -- Session #29 gate: real CP/M zero-page vectors written + SPR
    -- modules streamed + PC inside loaded region.  Zero page:
    --   0x0000..0x0002 = JP _bios_wboot  (c3 03 f2)
    --   0x0005..0x0007 = JP NDOS+6       (c3 06 de) — BDOS vector
    -- With TOP+1 = 0xF203, NDOS's TLBIOS-walk patches BIOS JT at
    -- 0xF200+ and doesn't touch the BDOS vector.  Previous null-trap
    -- (c3 00 00) caused the walk to scribble low memory instead.
    -- Real success criterion: CCP prints its prompt on the 8275 display.
    -- CP/M CCP emits "\r\nA>" once loaded and running.  We scan the
    -- display buffer for "A>" anywhere — covers both the first prompt
    -- and any position after scrolling.  Weaker intermediate gates
    -- (PC in loaded region, C3 at zero page) were misleading: they
    -- fired at ~2.5s while NDOS was still streaming CCP.SPR.
    for row = 0, 24 do
        for col = 0, 78 do
            if space:read_u8(DSPSTR + row * 80 + col) == string.byte('A')
               and space:read_u8(DSPSTR + row * 80 + col + 1) == string.byte('>') then
                pending_finish = string.format("PASS (A> at row %d col %d)", row, col)
                pending_frame = frame
                return
            end
        end
    end

    -- 60s timeout — full CCP.SPR load is 20 SNIOS round-trips, each
    -- with polled SIO I/O; be generous so slow CI machines don't flake.
    if frame > 50 * 60 then
        local b0 = space:read_u8(0x0000)
        local v5 = space:read_u8(0x0005)
        pending_finish = string.format(
            "FAIL: no A> prompt (B0=%02x V5=%02x PC=%04X)",
            b0, v5,
            manager.machine.devices[":maincpu"].state["PC"].value)
        pending_frame = frame
    end
end)
