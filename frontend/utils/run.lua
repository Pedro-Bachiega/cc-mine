if pocket then return end

local cacheAPI = require('cacheAPI')
local eventHandlerAPI = require('eventHandlerAPI')
local jsonAPI = require('jsonAPI')
local modemAPI = require('modemAPI')

local function handleRequest(request, replyChannel)
    if eventHandlerAPI.handlePre(request, replyChannel) then
        return true
    end

    if request.url == '/cache/clear' then
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
    print('[' .. message.method .. '] ' .. message.url)
    print('Args: ' .. jsonAPI.toJson(message.args, true))
    if not handleRequest(message, eventTable.replyChannel) then
        print('Message not handled')
    end
end
