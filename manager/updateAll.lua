os.loadAPI('channelAPI.lua')
os.loadAPI('constants.lua')
os.loadAPI('functionAPI.lua')

local function update(list)
    if not list then return end
    for k, value in pairs(list) do
        print('Updating ' .. value.name)
        functionAPI.sendMessage('update', value.channel)
        sleep(0.5)
    end
end

local channels = channelAPI.listChannels()
table.sort(channels, function(c1, c2) return c1.type.priority < c2.type.priority end)
update(channels)

shell.run('update.lua')
