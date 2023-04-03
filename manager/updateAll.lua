os.loadAPI('channelAPI.lua')
os.loadAPI('constants.lua')
os.loadAPI('functionAPI.lua')
os.loadAPI('logAPI.lua')

local function update(list)
    local request = functionAPI.toJson({command = 'update'})
    if not list then return end
    for k, value in pairs(list) do
        print('Updating ' .. value.name)
        functionAPI.sendMessage(request, value.channel)
        sleep(0.5)
    end
end

local channels = channelAPI.listChannels()
table.sort(channels, function(c1, c2) return c1.type.priority < c2.type.priority end)

logAPI.log('Updating all systems')
update(channels)
shell.run('update.lua')
