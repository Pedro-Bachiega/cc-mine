os.loadAPI('constants.lua')
os.loadAPI('display.lua')
os.loadAPI('json.lua')

function parseFarmInfo(infoJson)
    local infoTable = json.decode(infoJson)
    if constants.MONITOR_SIDE ~= 'none' then display.writeFarmInfo(infoTable) end
    return infoTable
end

function round(number, minimum)
    local result = math.floor(number + 0.5)
    if not minimum then return result end
    return result >= minimum and result or minimum
end

function openModem()
    local modem = peripheral.wrap(constants.MODEM_SIDE)
    modem.open(constants.CHANNEL)
end

function waitForEvent(eventName)
    local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent(eventName)

    local infoTable = parseFarmInfo(message)
    message = infoTable.state and 'turnOn' or 'turnOff'

    return {
        event = event,
        message = message,
        modemSide = modemSide,
        replyChannel = replyChannel,
        senderChannel = senderChannel,
        senderDistance = senderDistance
    }
end
