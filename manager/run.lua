if pocket then return end

os.loadAPI('functions.lua')

local managerId = multishell.launch({}, 'manager.lua')
multishell.setTitle(managerId, 'Managing')

while true do
    local eventTable = functions.waitForEvent('modem_message')
    if eventTable.message == 'update' then break end
end

shell.run('update')
