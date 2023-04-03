if not fs.exists('channels.lua') then
    shell.run('importChannels.lua')
    return
end

os.loadAPI('channelAPI.lua')
os.loadAPI('functionAPI.lua')
os.loadAPI('logAPI.lua')

local content = functionAPI.fromFile('channels.lua')
local request = functionAPI.toJson({
    command = 'synchronizeChannels',
    body = content
})

logAPI.log('Synchronizing channels')
local machines = channelAPI.listChannels()
for k, value in pairs(machines) do
    print('Updating ' .. value.name)
    functionAPI.sendMessage(request, value.channel)
end
