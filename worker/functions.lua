os.loadAPI('constants.lua')

local modem = peripheral.wrap(constants.MODEM_SIDE)

function round(number, minimum)
    local result = math.floor(number + 0.5)
    if not minimum then return result end
    return result >= minimum and result or minimum
end

function openModem() modem.open(constants.CHANNEL) end

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
