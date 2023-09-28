local displayAPI = require('displayAPI')
local computerAPI = require('computerAPI')

-- Updates computer info and toggles its redstone output
local function handleUpdate()
    local computer = computerAPI.findComputer()
    if not computer then
        print('Computer not registered')
        return
    end

    displayAPI.writeFarmInfo(computer)

    redstone.setOutput(computer.redstoneSide, computer.data.state or false)
end

-- Handles any custom events that are not already handled by run.lua
local eventHandlerAPI = {}

-- Occurs before any default event handling
function eventHandlerAPI.handlePre(request, _)
    if request.url == '/computer/update' then
        handleUpdate()
        return true
    end

    return false
end

-- Occurs after any default event handling
function eventHandlerAPI.handlePost(_, _)
    return false
end

return eventHandlerAPI
