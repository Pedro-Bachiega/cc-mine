os.loadAPI('constants.lua')
os.loadAPI('json.lua')

---------------- Generic ----------------

function waitForEvent(eventName)
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

function round(number, minimum)
    local result = math.floor(number + 0.5)
    if not minimum then return result end
    return result >= minimum and result or minimum
end

function openModem()
    local modem = peripheral.wrap(constants.MODEM_SIDE)
    modem.open(constants.CHANNEL)
    return modem
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

    print('\nRequesting farm info...')
    local modem = functions.openModem()
    modem.transmit(constants.CHANNEL_STORAGE, constants.CHANNEL, json.encode(request))

    local response = functions.waitForEvent('modem_message')
    print('Response: ' .. response.message)

    local result = json.decode(response.message)
    if result and result.error then print('Error: ' .. result.message) end
    return result or createFarmInfo('Placeholder', id, false, nil, nil)
end

function toggleFarmState(id)
    local farmInfo = requestFarmInfo(id)
    if farmInfo.error then
        print('Operation cancelled. ' .. result.message)
    else
        local newInfo = createFarmInfo(
            farmInfo.farmType,
            farmInfo.id,
            not farmInfo.state,
            farmInfo.content and farmInfo.content.fluid or nil,
            farmInfo.content and farmInfo.content.solid or nil
        )
        local modem = openModem()
        modem.transmit(constants.CHANNEL_STORAGE, constants.CHANNEL, json.encode(newInfo))
    end
end
