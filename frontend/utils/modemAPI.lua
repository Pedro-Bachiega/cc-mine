local cacheAPI = require('cacheAPI')
local eventAPI = require('eventAPI')
local functionAPI = require('functionAPI')
local jsonAPI = require('jsonAPI')
local peripheralAPI = require('peripheralAPI')

local defaultMaxRetries = 30

local modemAPI = {}

local function findNetworkComputer()
    local cachePath = 'computer/networking-computer.json'
    local networkingComputer = cacheAPI.fromCache(cachePath)

    if networkingComputer then return networkingComputer.id end

    local networkingComputerId = nil
    while not networkingComputerId do
        print('Networking computer ID:')
        local content = read()
        if content and content ~= '' then networkingComputerId = tonumber(content) end
    end

    local computerAPI = require('computerAPI')
    networkingComputer = computerAPI.fetchNetworkingComputer(networkingComputerId)
    cacheAPI.saveToCache(cachePath, networkingComputer, 0, true)

    return networkingComputer.id
end

local function openModem()
    local modem = peripheralAPI.requirePeripheral('modem')
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

function modemAPI.broadcastMessage(content, replyChannel, networkingComputerId)
    if not networkingComputerId then
        networkingComputerId = findNetworkComputer()
        if not networkingComputerId then
            print('No networking computer registered')
            return
        end
    end

    modemAPI.sendMessage(content, networkingComputerId, replyChannel)
end

function modemAPI.broadcastMessageAndWaitResponse(content, replyChannel, timeout, maxRetries, networkingComputerId)
    local function execute()
        modemAPI.broadcastMessage(content, replyChannel, networkingComputerId)
        return modemAPI.waitForMessage(timeout)
    end

    return functionAPI.runWithRetries(maxRetries or defaultMaxRetries, execute)
end

return modemAPI
