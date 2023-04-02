if pocket then return end

os.loadAPI('functions.lua')

local function clearCache()
    if fs.exists('cache') then fs.delete('cache') end
end

local function update()
    shell.run('update')
end

local function updateChannels(content)
    print('\nSynchronizing channels')
    functions.toFile('channels.lua', content)
end

local function handleMessage(message)
    if message == 'update' then return true end

    local request = functions.fromJson(message)
    local command = request.command
    if command == 'synchronizeChannels' then
        updateChannels(request.body)
        return true
    end

    return false
end

clearCache()

local managerId = multishell.launch({}, 'manager.lua')
multishell.setTitle(managerId, 'Managing')

while true do
    local eventTable = functions.waitForEvent('modem_message')
    if handleMessage(eventTable.message) then break end
end

update()
