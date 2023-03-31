local args = {...}

os.loadAPI('commands.lua')
os.loadAPI('constants.lua')
os.loadAPI('functions.lua')
os.loadAPI('machine.lua')

local argsTable = machine.argsToKnownTable(args)
local command = ''

functions.openModem()

while true do
    local eventTable = functions.waitForEvent('modem_message')
    local command = eventTable.message

    if command == 'update' then break end

    if not commands.runCommandIfExists(command) then
        print('Bypassing command: ' .. command)
    end
end

shell.run('update', '-t', argsTable.computerType)
