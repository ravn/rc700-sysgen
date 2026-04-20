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

    f:write("\n--- 0x0000 (reset vector / PROM0 shadow) ---\n")
    f:write(hex_dump(space, 0x0000, 48) .. "\n")
    f:write("\n--- 0xDB80 (netboot RET stub / FNC=4 execute target) ---\n")
    f:write(hex_dump(space, 0xDB80, 16) .. "\n")
    f:write("\n--- 0xD900 (CCP module entry, JP ccpstart / JP ccpclear) ---\n")
    f:write(hex_dump(space, 0xD900, 16) .. "\n")
    f:write("\n--- 0xE300 (NDOS module entry, JP NDOSE / JP COLDST) ---\n")
    f:write(hex_dump(space, 0xE300, 16) .. "\n")
    -- Module offset 0 is `c3 <lo> <hi>` with hi = base_page after reloc.
    -- Expected entry bytes: CCP 0xD900 = c3 e9 dc (JP 0xDCE9 ccpstart);
    -- NDOS 0xE300 = c3 71 e5 (JP 0xE571 NDOSE).
    local ccp0 = space:read_u8(0xD900)
    local ccp2 = space:read_u8(0xD902)
    local ndos0 = space:read_u8(0xE300)
    local ndos2 = space:read_u8(0xE302)
    f:write(string.format(
        "CCP[0xD900..2]=%02x ?? %02x (want c3 ?? dc), "
        .. "NDOS[0xE300..2]=%02x ?? %02x (want c3 ?? e5)\n",
        ccp0, ccp2, ndos0, ndos2))
    f:write("\n--- 0xEF00 (breadcrumbs — moved out of CCP range in session #26) ---\n")
    f:write(hex_dump(space, 0xEF00, 32) .. "\n")
    f:write("\n--- 0xE400 (cpnos_main breadcrumbs) ---\n")
    f:write(hex_dump(space, 0xE400, 16) .. "\n")
    f:write("\n--- CFGTBL (SLAVEID must be 0x70 at +1) ---\n")
    local cfg_addr = 0xF4C5                 -- _cfgtbl (check with `llvm-nm --numeric-sort cpnos.elf | grep _cfgtbl`)
    f:write(hex_dump(space, cfg_addr, 48) .. "\n")
    local slaveid = space:read_u8(cfg_addr + 1)
    f:write(string.format("SLAVEID = 0x%02x (want 0x70)\n", slaveid))
    local netst = space:read_u8(cfg_addr + 0)
    f:write(string.format("NETST   = 0x%02x (want 0x10 after NTWKIN)\n", netst))
    local sndres = space:read_u8(0xEF10)
    f:write(string.format("SNDMSG  = 0x%02x (want 0x00 after round-trip)\n", sndres))
    local rcvres = space:read_u8(0xEF11)
    f:write(string.format("RCVMSG  = 0x%02x (want 0x00 after round-trip)\n", rcvres))
    local rcvdat = space:read_u8(0xEF12)
    f:write(string.format("RCVDAT0 = 0x%02x (want 0x42 from server)\n", rcvdat))

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

    if match_at(space, DSPSTR, "CPNOS") then
        -- Before declaring PASS, confirm PROMs were actually disabled.
        -- resident_entry writes 0xA5/0x5A to 0x0000/0x0001 immediately
        -- after OUT (0x18). If PROM0 is still mapped, the writes are
        -- silently dropped and reads return reset-vector bytes instead.
        -- (Cannot rely on reading 0x00 — real HW power-on RAM is random.)
        local b0 = space:read_u8(0x0000)
        local b1 = space:read_u8(0x0001)
        if b0 ~= 0xA5 or b1 ~= 0x5A then
            finish(string.format(
                "FAIL: PROM disable sentinel missing at 0x0000 (got %02x %02x, want a5 5a)",
                b0, b1), space)
            return
        end
        -- CCP + NDOS SPR relocation + streaming check.  Module offset 0
        -- is `c3 <lo> <hi>` = JP entry; after page-reloc hi = base_page.
        local cpo = space:read_u8(0xD900)
        local cph = space:read_u8(0xD902)   -- hi byte, should be 0xDC
        local npo = space:read_u8(0xE300)
        local nph = space:read_u8(0xE302)   -- hi byte, should be 0xE5
        if cpo ~= 0xC3 or cph ~= 0xDC then
            finish(string.format(
                "FAIL: CCP entry reloc mismatch at 0xD900 (got %02x .. %02x, want c3 .. dc)",
                cpo, cph), space)
            return
        end
        if npo ~= 0xC3 or nph ~= 0xE5 then
            finish(string.format(
                "FAIL: NDOS entry reloc mismatch at 0xE300 (got %02x .. %02x, want c3 .. e5)",
                npo, nph), space)
            return
        end
        finish("PASS", space)
        return
    end

    -- 25s timeout (covers CCP+NDOS streaming + SNIOS round-trip +
    -- banner + fallback path).
    if frame > 50 * 25 then
        finish("FAIL: CPNOS banner not seen", space)
    end
end)
