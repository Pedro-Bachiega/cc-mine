os.loadAPI('commandsAPI.lua')
os.loadAPI('functionAPI.lua')

while true do
    local eventTable = functionAPI.waitForEvent('modem_message')
    local command = eventTable.message

    if command == 'update' then break end

    if not commandsAPI.runCommandIfExists(command, eventTable.replyChannel) then
        print('\nBypassing command: ' .. command)
    end
end

shell.run('update')
