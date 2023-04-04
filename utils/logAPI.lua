os.loadAPI('functionAPI.lua')

---------------- Logs ----------------

local function send(content)
    local channels = channelAPI.listLogChannels()
    for k, channel in pairs(channels) do
        functionAPI.sendMessage(content, channel.channel)
    end
end

function log(message)
    local channel = channelAPI.findChannel(constants.CHANNEL)
    local formatted = string.format('Channel %s - %s', channel.name, message)
    local content = functionAPI.toJson({command = 'write', body = {message = formatted}})
    send(content)
end

function clearLogs()
    local content = functionAPI.toJson({command = 'clear'})
    send(content)
end
