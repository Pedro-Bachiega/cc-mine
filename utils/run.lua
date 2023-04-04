if pocket then return end

os.loadAPI('eventHandlerAPI.lua')
os.loadAPI('functionAPI.lua')

local function synchronizeChannels(content)
    print('\nSynchronizing channels')
    functionAPI.toFile('channels.lua', content)
    shell.run('reboot')
end

function update()
    shell.run('update')
end

function handleRequest(request, replyChannel)
    if request.command == 'update' then
        update()
        return true
    elseif request.command == 'synchronizeChannels' then
        synchronizeChannels(request.body)
        return true
    else
        return eventHandlerAPI.handle(request, replyChannel)
    end
end

while true do
    local eventTable = functionAPI.waitForEvent('modem_message')
    local request = functionAPI.fromJson(eventTable.message)
    if not handleRequest(request, eventTable.replyChannel) then
        print('\nIgnoring request: ' .. eventTable.message)
    end
end
