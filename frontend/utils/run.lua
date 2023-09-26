if pocket then return end

local eventHandlerAPI = require('eventHandlerAPI.lua')
local jsonAPI = require('jsonAPI.lua')
local modemAPI = require('modemAPI.lua')

function handleRequest(request, replyChannel)
    if request.url == '/cache/clear' then
        cacheAPI.clear()
        return true
    elseif request.url == '/computer/update' then
        shell.run('update')
        return true
    else
        return eventHandlerAPI.handle(request, replyChannel)
    end
end

while true do
    -- TODO Get from socket
    local message = modemAPI.waitForMessage()
    if not message then
        print('Nil message')
        return
    end

    print('[' .. message.method .. '] ' .. message.url)
    if not handleRequest(message, eventTable.replyChannel) then
        print('Not handled')
    end
end
