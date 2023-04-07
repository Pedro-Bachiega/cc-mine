os.loadAPI('functionAPI.lua')
os.loadAPI('logAPI.lua')

channelTypes = {
    farm = {
        name = 'farm',
        priority = 1000
    },
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

function importChannels()
    local basePanelChannel = 999
    local request = functionAPI.toJson({command = 'exportChannels'})
    local response = functionAPI.sendMessageAndWaitResponse(request, basePanelChannel)
    local decodedResponse = functionAPI.fromJson(response.message)

    functionAPI.toFile('channels.lua', decodedResponse.body)
    print('Channels imported')
end

function importChannelsIfNeeded()
    local needed = not fs.exists('channels.lua')
    if needed then importChannels() end
end

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
    importChannelsIfNeeded()

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

function listFarmChannels()
    return listChannels(channelTypes.farm.name)
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

function farm(name, channel)
    return buildChannel(name, channelTypes.farm, channel)
end

function channelFromType(channelType, name, channelValue)
    if channelType == 'log' then
        return log(name, channelValue)
    elseif channelType == 'manager' then
        return manager(name, channelValue)
    elseif channelType == 'storage' then
        return storage(name, channelValue)
    elseif channelType == 'farm' then
        return farm(name, channelValue)
    end
end

function synchronizeChannels()
    importChannelsIfNeeded()

    local content = functionAPI.fromFile('channels.lua')
    local request = functionAPI.toJson({
        command = 'synchronizeChannels',
        body = content
    })

    logAPI.log('Synchronizing channels')
    local machines = listChannels()
    for k, value in pairs(machines) do
        print('Updating ' .. value.name)
        functionAPI.sendMessage(request, value.channel)
    end
end

function registerChannel(channel)
    importChannelsIfNeeded()
    if not findChannel(channel.channel) then
        createChannel(channel)
        synchronizeChannels()
    end
end
