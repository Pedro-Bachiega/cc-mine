os.loadAPI('commands.lua')
os.loadAPI('constants.lua')
os.loadAPI('functions.lua')

local command = ''

functions.openModem()

while true do
    local eventTable = functions.waitForEvent('modem_message')
    local command = eventTable.message

    if command == 'update' then break end

    if not commands.runCommandIfExists(command, eventTable.replyChannel) then
        print('\nBypassing command: ' .. command)
    end
end

shell.run('update', '-t', constants.COMPUTER_TYPE)
