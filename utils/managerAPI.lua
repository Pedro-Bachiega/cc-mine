os.loadAPI('channelAPI.lua')
os.loadAPI('functionAPI.lua')
os.loadAPI('logAPI.lua')

function clearCache()
    local content = functionAPI.toJson({command = 'clearCache'})
    local channels = channelAPI.listChannels()
    for k, c in pairs(channels) do
        functionAPI.sendMessage(content, c.channel)
    end
end
