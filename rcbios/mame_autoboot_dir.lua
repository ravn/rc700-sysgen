-- MAME autoboot script: type "DIR\r" one character at a time, dump screen, exit.
--
-- Usage:
--   ./regnecentralend rc702mini -bios 0 -window -skip_gameinfo -nothrottle \
--       -flop1 ~/Downloads/CPM_med_COMAL80.imd \
--       -autoboot_delay 20 -autoboot_script rcbios/mame_autoboot_dir.lua
--
-- The script waits for CP/M to boot (15 seconds), types "DIR" followed by CR
-- with 300ms between keystrokes, waits 4 seconds for the directory listing,
-- dumps the 80x25 screen buffer at 0xF800 to /tmp/screen.txt, then exits.
--
-- Screen buffer address 0xF800 = DSPSTR from BIOS DISPLAY.MAC (80x25 chars).

local chars = {0x44, 0x49, 0x52, 0x0D}  -- D, I, R, CR
local char_idx = 0
local frame = 0
local state = "typing"
local nk = manager.machine.natkeyboard

emu.register_frame_done(function()
    frame = frame + 1
    if state == "typing" then
        if frame % 15 == 0 then  -- every 300ms at 50Hz
            char_idx = char_idx + 1
            if char_idx <= #chars then
                nk:post_coded(string.char(chars[char_idx]))
            else
                state = "waiting"
                frame = 0
            end
        end
    elseif state == "waiting" and frame >= 200 then  -- 4 seconds
        -- Dump screen buffer as readable text
        local space = manager.machine.devices[":maincpu"].spaces["program"]
        local f = io.open("/tmp/screen.txt", "w")
        for row = 0, 23 do
            local line = ""
            for col = 0, 79 do
                local ch = space:read_u8(0xF800 + row * 80 + col)
                if ch >= 0x20 and ch < 0x7F then
                    line = line .. string.char(ch)
                else
                    line = line .. " "
                end
            end
            f:write(line .. "\n")
        end
        f:close()
        manager.machine:exit()
    end
end)
