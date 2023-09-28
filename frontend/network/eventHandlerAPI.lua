local computerAPI        = require('computerAPI')
local computerRepository = require('computerRepository')
local modemAPI           = require('modemAPI')
local repositoryAPI      = require('repositoryAPI')
local jsonAPI            = require('jsonAPI')

-- Only fire requests from this computer so we can cache stuff and prevent from spamming firebase with requests
local eventHandlerAPI    = {}

-- Deletes computer on cache and system
local function handleComputerDelete(request)
    return computerRepository.deleteComputer(request.params.id)
end

-- Searches for computer on cache or system (only on system if 'force' == true)
local function handleComputerFind(request)
    return computerRepository.findComputer(request.params.id, request.params.force)
end

-- Lists computers on cache or system (only on system if 'force' == true).
-- Can be filtered by computerType by passing an array of 'computerAPI.computerTypes'
local function handleComputerList(request)
    return computerRepository.listComputers(request.params.computerTypes, request.params.force)
end

-- Registers computer on system
local function handleComputerRegister(request)
    return computerRepository.registerComputer(request.params)
end

-- Updates computer on system
local function handleComputerUpdate(request)
    return computerRepository.updateComputer(request.params)
end

-- Makes every computer in the network update itself
local function handleSystemsUpdate(_)
    local computers = computerAPI.listComputers()
    ---@diagnostic disable-next-line: param-type-mismatch
    for _, computer in ipairs(computers) do
        ---@diagnostic disable-next-line: undefined-field
        if computer.id ~= os.getComputerID() then
            local message = repositoryAPI.buildRequest('/systems/update')
            modemAPI.sendMessage(message, computer.id)
            print('Updating computer: ' .. computer.id)
        end
    end

    shell.run('update.lua')
end

-- Occurs before any default event handling
function eventHandlerAPI.handlePre(request, replyChannel)
    local urlTable = {
        ['/computer/delete'] = handleComputerDelete,
        ['/computer/find'] = handleComputerFind,
        ['/computer/list'] = handleComputerList,
        ['/computer/register'] = handleComputerRegister,
        ['/computer/update'] = handleComputerUpdate,
        ['/systems/update'] = handleSystemsUpdate,
    }

    local handler = urlTable[request.url]
    if handler then
        local response = handler(request)
        if response then modemAPI.sendMessage(response, replyChannel) end
    end

    return request.url ~= '/computer/update'
end

-- Occurs after any default event handling
function eventHandlerAPI.handlePost(_, _)
    return false
end

return eventHandlerAPI
