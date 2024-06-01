local cacheAPI = require('api.repository.cacheAPI')
local computerAPI = require('api.computer.computerAPI')
local eventAPI = require('api.util.eventAPI')
local functionAPI = require('api.util.functionAPI')
local jsonAPI = require('api.util.jsonAPI')
local peripheralAPI = require('api.util.peripheralAPI')

local defaultMaxRetries = 30

local modemAPI = {}

local function openModem()
    local modem = peripheralAPI.requirePeripheral('modem')
    ---@diagnostic disable-next-line: undefined-field
    modem.open(os.getComputerID())
    return modem
end

function modemAPI.waitForMessage(timeout)
    local cachePath = 'modem/messageResult.lua'

    local function execute()
        openModem()
        local eventTable = eventAPI.waitForEvent('modem_message')

        local result = {
            event = eventTable.event,
            side = eventTable.param1,
            senderChannel = eventTable.param2,
            replyChannel = eventTable.param3,
            message = eventTable.param4,
            senderDistance = eventTable.param5
        }

        if result.message then
            result.message = jsonAPI.fromJson(result.message)
        end
        print('Received: ' .. jsonAPI.toJson(result))

        cacheAPI.saveToCache(cachePath, result, 1, true)
    end

    if timeout then
        functionAPI.runWithTimeout(timeout, execute)
    else
        execute()
    end

    return cacheAPI.fromCache(cachePath, true)
end

function modemAPI.sendMessage(content, destinationChannel, replyChannel)
    ---@diagnostic disable-next-line: undefined-field
    if not replyChannel then replyChannel = os.getComputerID() end
    openModem().transmit(destinationChannel, replyChannel, jsonAPI.toJson(content))
end

function modemAPI.sendMessageAndWaitResponse(content, destinationChannel, replyChannel, timeout, maxRetries)
    local function execute()
        modemAPI.sendMessage(content, destinationChannel, replyChannel)
        return modemAPI.waitForMessage(timeout)
    end

    return functionAPI.runWithRetries(maxRetries or defaultMaxRetries, execute)
end

function modemAPI.broadcastMessage(content, replyChannel)
    local computersInNetwork = computerAPI.listComputers()
    ---@diagnostic disable-next-line: param-type-mismatch
    for _, computer in pairs(computersInNetwork) do
        ---@diagnostic disable-next-line: undefined-field
        if computer ~= os.getComputerID() then
            modemAPI.sendMessage(content, computer, replyChannel)
        end
    end
end

function modemAPI.broadcastMessageAndWaitResponse(content, replyChannel, timeout, maxRetries)
    local function execute()
        modemAPI.broadcastMessage(content, replyChannel)
        return modemAPI.waitForMessage(timeout)
    end

    return functionAPI.runWithRetries(maxRetries or defaultMaxRetries, execute)
end

return modemAPI
