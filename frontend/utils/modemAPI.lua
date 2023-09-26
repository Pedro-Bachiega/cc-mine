local jsonAPI = require('jsonAPI.lua')

local function openModem(computerInfo)
    local modem = peripheral.wrap(computerInfo.modemSide)
    modem.open(computerInfo.id)
    return modem
end

function waitForEvent(eventName)
    local computerInfo = computerAPI.findComputer()

    openModem(computerInfo)
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

function waitForMessage()
    local message = waitForEvent('modem_message')
    if message then return jsonAPI.fromJson(message) end

    return nil
end

function sendMessage(content, destinationChannel, replyChannel)
    local computerInfo = computerAPI.findComputer()

    if not replyChannel then replyChannel = computerInfo.id end
    return openModem(computerInfo).transmit(destinationChannel, replyChannel, jsonAPI.toJson(content))
end

function sendMessageAndWaitResponse(message, destinationChannel, replyChannel)
    sendMessage(message, destinationChannel, replyChannel)
    return waitForMessage()
end

function broadcastMessage(content, replyChannel)
    local computerList = computerAPI.listComputers({computerAPI.computerTypes.NETWORK}, true)
    local networkingComputer = computerList and computerList[0] or nil

    if not networkingComputer then
        print('No networking computer registered')
        return
    end

    sendMessage(content, networkingComputer.id, replyChannel)
end
