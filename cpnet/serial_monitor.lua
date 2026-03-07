------------------------------------------------------------------------
-- serial_monitor.lua
-- Serial port configuration for MAME RC702 with throughput monitoring.
--
-- Configures SIO Channel A for 38400 baud with RTS flow control.
-- Throughput data is logged by server.py to /tmp/serial_monitor.csv.
-- Use serial_graph.py to display a live graph.
--
-- Usage:
--   # Terminal 1: start server
--   python3 cpnet/server.py --wait --port 4321 --drive-dir B /path/to/files
--
--   # Terminal 2: start MAME
--   mame rc702 -flop disk.imd -rs232a null_modem -bitb socket.localhost:4321 \
--       -autoboot_script cpnet/serial_monitor.lua
--
--   # Terminal 3: live graph
--   python3 cpnet/serial_graph.py
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
                field.user_value = 0x01  -- RTS
            end
        end
    end
    print("[monitor] Serial: 38400 baud, RTS flow control")
    print("[monitor] Throughput logged by server.py → /tmp/serial_monitor.csv")
    print("[monitor] Run: python3 cpnet/serial_graph.py")
end

emu.register_periodic(function()
    configure_serial()
    -- Unregister after first call (one-shot)
    return false
end, "serial_monitor_init")
