os.loadAPI('constants.lua')
os.loadAPI('json.lua')

---------------- Generic ----------------

function argsToKnownTable(args)
    local channel, computerType = nil

    for index, value in ipairs(args) do
        if value == '-t' or value == '--type' then
            computerType = args[index + 1]
        elseif value == '-c' or value == '--channel' then
            channel = args[index + 1]
        end
    end

    return {
        channel = channel,
        computerType = computerType
    }
end

local function openModem()
    local modem = peripheral.wrap(constants.MODEM_SIDE)
    modem.open(constants.CHANNEL)
    return modem
end

function round(number, minimum)
    local result = math.floor(number + 0.5)
    if not minimum then return result end
    return result >= minimum and result or minimum
end

function getTimestamp()
    local table = os.date("*t", timestamp) or os.date("%format", timestamp)
    return string.format(
        '%02d:%02d - %d/%d/%d',
        table.hour,
        table.min,
        table.day,
        table.month,
        table.year
    )
end

function waitForEvent(eventName)
    openModem()
    local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent(eventName)

    return {
        event = event,
        message = message,
        modemSide = modemSide,
        replyChannel = replyChannel,
        senderChannel = senderChannel,
        senderDistance = senderDistance
    }
end

function sendMessage(destinationChannel, replyChannel, message)
    return openModem().transmit(destinationChannel, replyChannel, message)
end

function sendMessageAndWaitResponse(destinationChannel, replyChannel, message)
    sendMessage(destinationChannel, replyChannel, message)
    openModem()
    return waitForEvent('modem_message')
end

---------------- Farm related ----------------

local function cacheResponse(fileName, id, content)
    local cachePath = string.format('cache/%s/%s.lua', id, fileName)
    if (not fs.exists('cache')) then fs.makeDir('cache') end
    local file = fs.open(cachePath, 'w')
    file.write(content)
    file.close()
end

local function getFromCache(fileName, id)
    local cachePath = string.format('cache/%s/%s.lua', id, fileName)
    if not fs.exists(cachePath) then return nil end
    local file = fs.open(cachePath, 'r')
    local result = file.readAll()
    file.close()
    return json.decode(result)
end

function createFarmInfo(farmType, channel, state, fluidContent, solidContent)
    local info = {
        farmType = farmType,
        id = channel,
        state = state
    }

    if fluidContent or solidContent then
        local content = {}
        if fluidContent then content['fluid'] = fluidContent end
        if solidContent then content['solid'] = solidContent end
        info['content'] = content
    end

    return {
        method = 'INSERT',
        body = info
    }
end

function requestFarmInfo(id)
    local request = {
        method = 'FIND',
        body = {
            id = id
        }
    }

    print('\nRequesting farm info for id ' .. id .. '...')
    local response = sendMessageAndWaitResponse(constants.CHANNEL_STORAGE, constants.CHANNEL, json.encode(request))
    cacheResponse('farmInfo', id, response.message)
    print('Response: ' .. response.message)

    local result = json.decode(response.message)
    if result and result.error then print('Error: ' .. result.message) end
    return result or createFarmInfo('Placeholder', id, false, nil, nil)
end

function getFarmInfo(id)
    return getFromCache('farmInfo', id) or requestFarmInfo(id)
end

function toggleFarmState(id)
    local farmInfo = getFarmInfo(id)

    if farmInfo.error then
        print('Operation cancelled. ' .. farmInfo.message)
    else
        farmInfo.state = not farmInfo.state
        local content = {
            method = 'INSERT',
            body = farmInfo
        }
        local response = sendMessageAndWaitResponse(constants.CHANNEL_STORAGE, constants.CHANNEL, json.encode(content))
        cacheResponse('farmInfo', id, response.message)
    end
end
