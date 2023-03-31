os.loadAPI('commands.lua')
os.loadAPI('constants.lua')
os.loadAPI('functions.lua')

functions.openModem()

while true do
    local eventTable = functions.waitForEvent('modem_message')
    local command = eventTable.message
    
    if not commands.runCommandIfExists(command) then
        print('Bypassing command: ' .. command)
    end
end
