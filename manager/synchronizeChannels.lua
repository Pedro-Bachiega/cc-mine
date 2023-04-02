if not fs.exists('channels.lua') then
    shell.run('importChannels.lua')
    return
end

os.loadAPI('channelAPI.lua')
os.loadAPI('functionAPI.lua')

local content = functionAPI.fromFile('channels.lua')
local request = functionAPI.toJson({
    command = 'synchronizeChannels',
    body = content
})

local managers = channelAPI.listChannels(channelAPI.channelTypes.manager.name)
for k, value in pairs(managers) do
    print('Updating ' .. value.name)
    functionAPI.sendMessage(request, value.channel)
end
