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

function floor(number, minimum)
    local result = math.floor(number)
    if not minimum then return result end
    return result >= minimum and result or minimum
end

function round(number, minimum)
    return floor(number + 0.5)
end

---------------- File ----------------

function toFile(fileName, content)
    local file = fs.open(fileName, 'w')
    file.write(content)
    file.close()
end

function fromFile(fileName)
    local file = fs.open(fileName, 'r')
    local content = file.readAll()
    file.close()
    return content
end

---------------- Json ----------------

function fromJson(jsonString)
    return json.decode(jsonString)
end

function toJson(jsonString)
    return json.encode(jsonString)
end

---------------- Modem ----------------

local function openModem()
    local modem = peripheral.wrap(constants.MODEM_SIDE)
    modem.open(constants.CHANNEL)
    return modem
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

function sendMessage(message, destinationChannel, replyChannel)
    if not replyChannel then replyChannel = constants.CHANNEL end
    return openModem().transmit(destinationChannel, replyChannel, message)
end

function sendMessageAndWaitResponse(message, destinationChannel, replyChannel)
    sendMessage(message, destinationChannel, replyChannel)
    return waitForEvent('modem_message')
end

---------------- Farm related ----------------

local function cacheResponse(fileName, id, content)
    local cachePath = string.format('cache/%s/%s.lua', id, fileName)
    if not fs.exists('cache') then fs.makeDir('cache') end
    toFile(cachePath, content)
end

local function getFromCache(fileName, id)
    local cachePath = string.format('cache/%s/%s.lua', id, fileName)
    if not fs.exists(cachePath) then return nil end
    return json.decode(fromFile(cachePath))
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
    local response = sendMessageAndWaitResponse(json.encode(request), constants.CHANNEL_STORAGE)
    cacheResponse('farmInfo', id, response.message)
    print('Response: ' .. response.message)

    local result = json.decode(response.message)
    if result then
        if result.error then
            print('Error: ' .. result.message)
        else
            sendMessage(response.message, id)
        end
    end
    return result or createFarmInfo('Placeholder', id, false, nil, nil)
end

function getFarmInfo(id)
    return getFromCache('farmInfo', id) or requestFarmInfo(id)
end

function toggleFarmState(id)
    local farmInfo = getFarmInfo(id)

    if farmInfo.error then
        print('Operation cancelled. ' .. farmInfo.message)
        return nil
    else
        farmInfo.state = not farmInfo.state
        local content = {
            method = 'INSERT',
            body = farmInfo
        }
        local response = sendMessageAndWaitResponse(json.encode(content), constants.CHANNEL_STORAGE)
        cacheResponse('farmInfo', id, response.message)
        return response
    end
end
