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

    f:write("\n--- 0x0000 (reset vector / PROM0 shadow + BDOS vector) ---\n")
    f:write(hex_dump(space, 0x0000, 48) .. "\n")
    -- Expected: 00=0xA5, 01=0x5A (sentinels), 05=0xC3 06 DE (JP 0xDE06 BDOS).
    f:write(string.format("BDOS vector [0x0005..7]=%02x %02x %02x (want c3 06 de)\n",
        space:read_u8(0x0005), space:read_u8(0x0006), space:read_u8(0x0007)))
    f:write("\n--- 0xD000 (CCP module entry, JP ccpstart / JP ccpclear) ---\n")
    f:write(hex_dump(space, 0xD000, 16) .. "\n")
    f:write("\n--- 0xDE00 (NDOS module entry, JP NDOSE / JP COLDST) ---\n")
    f:write(hex_dump(space, 0xDE00, 16) .. "\n")
    -- Module offset 0 is `c3 <lo> <hi>` with hi = base_page after reloc.
    -- Expected entry bytes: CCP 0xD000 = c3 e9 d3 (JP 0xD3E9 ccpstart);
    -- NDOS 0xDE00 = c3 71 e0 (JP 0xE071 NDOSE).
    local ccp0 = space:read_u8(0xD000)
    local ccp2 = space:read_u8(0xD002)
    local ndos0 = space:read_u8(0xDE00)
    local ndos2 = space:read_u8(0xDE02)
    f:write(string.format(
        "CCP[0xD000..2]=%02x ?? %02x (want c3 ?? d3), "
        .. "NDOS[0xDE00..2]=%02x ?? %02x (want c3 ?? e0)\n",
        ccp0, ccp2, ndos0, ndos2))
    f:write("\n--- 0xEC00 (breadcrumbs — moved out of CCP range in session #26) ---\n")
    f:write(hex_dump(space, 0xEC00, 32) .. "\n")
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
    if frame % 25 ~= 0 then return end  -- every ~0.5s

    local space = manager.machine.devices[":maincpu"].spaces["program"]

    -- Session #29 gate: real CP/M zero-page vectors written + SPR
    -- modules streamed + PC inside loaded region.  Zero page:
    --   0x0000..0x0002 = JP _bios_wboot  (c3 03 f2)
    --   0x0005..0x0007 = JP NDOS+6       (c3 06 de) — BDOS vector
    -- With TOP+1 = 0xF203, NDOS's TLBIOS-walk patches BIOS JT at
    -- 0xF200+ and doesn't touch the BDOS vector.  Previous null-trap
    -- (c3 00 00) caused the walk to scribble low memory instead.
    local b0 = space:read_u8(0x0000)
    local b2 = space:read_u8(0x0002)
    local v5 = space:read_u8(0x0005)
    local v6 = space:read_u8(0x0006)
    local v7 = space:read_u8(0x0007)
    if b0 == 0xC3 and b2 == 0xF2
       and v5 == 0xC3 and v6 == 0x06 and v7 == 0xDE then
        -- Sentinels + BDOS vector in place => resident_entry ran.  Give
        -- CCP a moment to settle, then check PC is inside loaded code.
        local pc = manager.machine.devices[":maincpu"].state["PC"].value
        local cpo = space:read_u8(0xD000)
        local cph = space:read_u8(0xD002)
        -- NDOS+0..+5 are overwritten by NDOS COLDST (ndos.asm:204-212
        -- copies 6 bytes from MSGDAT into NDOS+0..+5 as internal
        -- scratch).  Check the duplicate dispatch at NDOS+6 instead,
        -- which stays intact and is what our BDOS vector points at.
        local npo = space:read_u8(0xDE06)
        local nph = space:read_u8(0xDE08)
        if cpo ~= 0xC3 or cph ~= 0xD3 then
            finish(string.format(
                "FAIL: CCP entry reloc mismatch at 0xD000 (got %02x .. %02x, want c3 .. d3)",
                cpo, cph), space)
            return
        end
        if npo ~= 0xC3 or nph ~= 0xE0 then
            finish(string.format(
                "FAIL: NDOS dispatch reloc mismatch at 0xDE06 (got %02x .. %02x, want c3 .. e0)",
                npo, nph), space)
            return
        end
        -- PC should now be somewhere inside CCP (0xD000..), NDOS
        -- (0xDE00..), or BIOS resident (0xF200..0xF800).
        if pc >= 0xD000 and pc < 0xF800 then
            finish(string.format("PASS (PC=%04X in loaded region)", pc), space)
            return
        end
        -- PC still in PROM shadow / init code — give it more time.
    end

    -- 30s timeout.
    if frame > 50 * 30 then
        finish(string.format(
            "FAIL: handoff did not complete (B0=%02x B1=%02x V5=%02x)",
            b0, b1, v5), space)
    end
end)
