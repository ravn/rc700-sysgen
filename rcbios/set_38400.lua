-- Set null_modem to 38400 baud using user_value, then type PIP command once
local ports = manager.machine.ioport.ports
for tag, port in pairs(ports) do
    if tag:find("RS232_TXBAUD") or tag:find("RS232_RXBAUD") then
        for name, field in pairs(port.fields) do
            field.user_value = 0x0b  -- RS232_BAUD_38400
            print(tag .. " set to 38400")
        end
    end
end

-- Type PIP command exactly once after 10 seconds
local typed = false
emu.register_periodic(function()
    if not typed and manager.machine.time.seconds >= 10 then
        typed = true
        manager.machine.natkeyboard:post("pip con:=rdr:\r")
        return false  -- unregister callback
    end
end)
