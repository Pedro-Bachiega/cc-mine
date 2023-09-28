local cacheAPI = require('cacheAPI')
local computerAPI = require('computerAPI')
local functionAPI = require('functionAPI')
local jsonAPI = require('jsonAPI')
local eventAPI = require('eventAPI')

local defaultMaxRetries = 30

local modemAPI = {}

local function openModem(computerInfo)
    local modem = peripheral.wrap(computerInfo.modemSide)
    modem.open(computerInfo.id)
    return modem
end

function modemAPI.waitForMessage(timeout)
    local cachePath = 'modem/messageResult.lua'

    local function execute()
        openModem(computerAPI.findComputer())
        local eventTable = eventAPI.waitForEvent('modem_message')

        local result = {
            event = eventTable.event,
            message = eventTable.param1 and jsonAPI.fromJson(eventTable.param1) or nil,
            modemSide = eventTable.param2,
            replyChannel = eventTable.param3,
            senderChannel = eventTable.param4,
            senderDistance = eventTable.param5
        }
        cacheAPI.saveToCache(cachePath, result, true, true)
    end

    if timeout then
        functionAPI.runWithTimeout(timeout, execute)
    else
        execute()
    end

    return cacheAPI.fromCache(cachePath, true, true)
end

function modemAPI.sendMessage(content, destinationChannel, replyChannel)
    local computerInfo = computerAPI.findComputer()
    if not computerInfo then
        print('Computer not registered in the network')
        return
    end

    if not replyChannel then replyChannel = computerInfo.id end
    openModem(computerInfo).transmit(destinationChannel, replyChannel, jsonAPI.toJson(content))
end

function modemAPI.sendMessageAndWaitResponse(content, destinationChannel, replyChannel, timeout, maxRetries)
    local function execute()
        modemAPI.sendMessage(content, destinationChannel, replyChannel)
        modemAPI.waitForMessage(timeout)
    end

    return functionAPI.runWithRetries(maxRetries or defaultMaxRetries, execute)
end

function modemAPI.broadcastMessage(content, replyChannel)
    local computerList = computerAPI.listComputers({ computerAPI.computerTypes.NETWORK })
    local networkingComputer = computerList and computerList[0] or nil

    if not networkingComputer then
        print('No networking computer registered')
        return
    end

    modemAPI.sendMessage(content, networkingComputer.id, replyChannel)
end

function modemAPI.broadcastMessageAndWaitResponse(content, replyChannel, timeout, maxRetries)
    local function execute()
        modemAPI.broadcastMessage(content, replyChannel)
        modemAPI.waitForMessage(timeout)
    end

    return functionAPI.runWithRetries(maxRetries or defaultMaxRetries, execute)
end

return modemAPI
