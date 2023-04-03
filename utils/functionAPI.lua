os.loadAPI('constants.lua')
os.loadAPI('jsonAPI.lua')

---------------- Generic ----------------

local function getTimestampTable()
    return os.date("*t", timestamp) or os.date("%format", timestamp)
end

function getDateTime()
    local table = getTimestampTable()
    return string.format(
        '%02d:%02d - %d/%d/%d',
        table.hour,
        table.min,
        table.day,
        table.month,
        table.year
    )
end

function getDate(pretty)
    local table = getTimestampTable()
    if pretty then
        return string.format(
            '%d/%d/%d',
            table.day,
            table.month,
            table.year
        )
    else
        return string.format(
            '%d-%d-%d',
            table.year,
            table.month,
            table.day
        )
    end
end

function getTime()
    local table = getTimestampTable()
    return string.format(
        '%02d:%02d',
        table.hour,
        table.min
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

function appendToFile(fileName, content)
    local mode = 'a'
    if not fs.exists(fileName) then mode = 'w' end

    local file = fs.open(fileName, mode)
    file.write(mode == a and ('\n' .. content) or content)
    file.close()
end

function toFile(fileName, content)
    local file = fs.open(fileName, 'w')
    file.write(content)
    file.close()
end

function fromFile(fileName)
    if not fs.exists(fileName) then return nil end

    local file = fs.open(fileName, 'r')
    local content = file.readAll()
    file.close()
    return content
end

---------------- Json ----------------

function fromJson(jsonString)
    return jsonAPI.decode(jsonString)
end

function toJson(jsonString, pretty)
    if pretty then return jsonAPI.encodePretty(jsonString) end
    return jsonAPI.encode(jsonString)
end

---------------- Cache ----------------

local function cacheResponse(fileName, id, content)
    local cachePath = string.format('cache/%s/%s.lua', id, fileName)
    if not fs.exists('cache') then fs.makeDir('cache') end
    toFile(cachePath, content)
end

local function getFromCache(fileName, id)
    local cachePath = string.format('cache/%s/%s.lua', id, fileName)
    if not fs.exists(cachePath) then return nil end
    return fromJson(fromFile(cachePath))
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
        command = 'insert',
        body = info
    }
end

function requestFarmInfo(id)
    local request = {
        command = 'find',
        body = {
            id = id
        }
    }

    print('\nRequesting farm info for id ' .. id .. '...')
    local response = sendMessageAndWaitResponse(toJson(request), constants.CHANNEL_STORAGE)
    cacheResponse('farmInfo', id, response.message)
    print('Response: ' .. response.message)

    local result = fromJson(response.message)
    if result then
        if result.error then
            print('Error: ' .. result.message)
        else
            sendMessage(response.message, id)
        end
    end
    return result or createFarmInfo('Placeholder', id, false, nil, nil)
end

function getFarmInfo(id, skipCache)
    local info = nil
    if not skipCache then info = getFromCache('farmInfo', id) end
    if not info then info = requestFarmInfo(id) end
    return info
end

function toggleFarmState(id)
    local farmInfo = getFarmInfo(id)

    if farmInfo.error then
        print('Operation cancelled. ' .. farmInfo.message)
        return nil
    else
        farmInfo.state = not farmInfo.state
        local content = {
            command = 'insert',
            body = farmInfo
        }
        print(toJson(content))
        local response = sendMessageAndWaitResponse(toJson(content), constants.CHANNEL_STORAGE)
        cacheResponse('farmInfo', id, response.message)
        return response
    end
end
