if pocket then return end

local cacheAPI = require('api.repository.cacheAPI')
local jsonAPI = require('api.util.jsonAPI')
local modemAPI = require('api.util.modemAPI')

local computerType = require('api.computer.computerAPI').findComputerType()
local eventHandlerAPI = require('controller.' .. computerType .. '.eventHandlerAPI')

local function handleRequest(request, replyChannel)
    if eventHandlerAPI.handlePre(request, replyChannel) then
        return true
    end

    if request.url == '/cache' and request.method == 'DELETE' then
        cacheAPI.clear()
        return true
    elseif request.url == '/systems/update' then
        shell.run('update')
        return true
    end

    return eventHandlerAPI.handlePost(request, replyChannel)
end

while true do
    local eventTable = modemAPI.waitForMessage()
    if not eventTable or not eventTable.message then
        print('Nil message')
        return
    end

    local message = eventTable.message
    print('\nURL: ' .. message.url)
    if message.params then
        print('Body: ' .. jsonAPI.toJson(message.params))
    end

    if not handleRequest(message, eventTable.replyChannel) then
        print('Message not handled')
    end
end
