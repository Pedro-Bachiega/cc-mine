os.loadAPI('functionAPI.lua')

channelTypes = {
    log = {
        name = 'log',
        priority = 0
    },
    manager = {
        name = 'manager',
        priority = 2
    },
    storage = {
        name = 'storage',
        priority = 1
    },
    worker = {
        name = 'worker',
        priority = 1000
    }
}

local function buildChannel(name, channelType, channel)
    return {
        name = name,
        type = channelType,
        channel = channel
    }
end

function createChannel(channel)
    local content = functionAPI.fromFile('channels.lua')
    if content then
        content = functionAPI.fromJson(content)
    else
        content = {}
    end

    if not content[channel.type.name] then content[channel.type.name] = {} end
    table.insert(content[channel.type.name], channel)

    functionAPI.toFile('channels.lua', functionAPI.toJson(content, true))
end

function listChannels(channelType)
    local content = functionAPI.fromFile('channels.lua')
    if not content then return {} end

    content = functionAPI.fromJson(content)

    local result = {}
    for key, value in pairs(content) do
        if not channelType or key == channelType then
            for i, channel in ipairs(value) do
                table.insert(result, channel)
            end
        end
    end
    return result
end

function findChannel(channelNumber)
    for key, value in pairs(listChannels()) do
        if value.channel == channelNumber then
            return value
        end
    end

    return nil
end

function listLogChannels()
    return listChannels(channelTypes.log.name)
end

function listManagerChannels()
    return listChannels(channelTypes.manager.name)
end

function listStorageChannels()
    return listChannels(channelTypes.storage.name)
end

function listWorkerChannels()
    return listChannels(channelTypes.worker.name)
end

function log(name, channel)
    return buildChannel(name, channelTypes.log, channel)
end

function manager(name, channel)
    return buildChannel(name, channelTypes.manager, channel)
end

function storage(name, channel)
    return buildChannel(name, channelTypes.storage, channel)
end

function worker(name, channel)
    return buildChannel(name, channelTypes.worker, channel)
end
