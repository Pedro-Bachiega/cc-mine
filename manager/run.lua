if pocket then return end

os.loadAPI('functions.lua')

local function clearCache()
    if fs.exists('cache') then fs.delete('cache') end
end

local function update()
    shell.run('update')
end

local function exportChannels(content, replyChannel)
    print('\nExporting channels')
    local content = functions.fromFile('channels.lua')
    local response = {body = content}
    functions.sendMessage(functions.toJson(response), replyChannel)
end

local function updateChannels(content)
    print('\nSynchronizing channels')
    functions.toFile('channels.lua', content)
end

local function handleMessage(message, replyChannel)
    if message == 'update' then return true end

    local request = functions.fromJson(message)
    local command = request.command
    if command == 'synchronizeChannels' then
        updateChannels(request.body)
        return true
    elseif command == 'exportChannels' then
        exportChannels(request.body, replyChannel)
        return false
    end

    return false
end

clearCache()

local managerId = multishell.launch({}, 'manager.lua')
multishell.setTitle(managerId, 'Managing')

while true do
    local eventTable = functions.waitForEvent('modem_message')
    if handleMessage(eventTable.message, eventTable.replyChannel) then break end
end

update()
