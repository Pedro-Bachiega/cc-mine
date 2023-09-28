local computerAPI = require('computerAPI')
local computerRepository = require('computerRepository')
local modemAPI = require('modemAPI')
local repositoryAPI = require('repositoryAPI')

-- Only fire requests from this computer so we can cache stuff and prevent from spamming firebase with requests
local eventHandlerAPI = {}

-- Deletes computer on cache and system
local function handleComputerDelete(request, _)
    computerRepository.deleteComputer(request.params.id)
end

-- Searches for computer on cache or system (only on system if 'force' == true)
local function handleComputerFind(request, replyChannel)
    local response = computerRepository.findComputer(request.params.id, request.params.force)
    modemAPI.sendMessage(response, replyChannel)
end

-- Lists computers on cache or system (only on system if 'force' == true).
-- Can be filtered by computerType by passing an array of 'computerAPI.computerTypes'
local function handleComputerList(request, replyChannel)
    local response = computerRepository.listComputers(request.params.computerTypes, request.params.force)
    modemAPI.sendMessage(response, replyChannel)
end

-- Registers computer on system
local function handleComputerRegister(request, replyChannel)
    local response = computerRepository.registerComputer(request.params)
    modemAPI.sendMessage(response, replyChannel)
end

-- Updates computer on system
local function handleComputerUpdate(request, replyChannel)
    local response = computerRepository.updateComputer(request.params)
    modemAPI.sendMessage(response, replyChannel)
end

-- Makes every computer in the network update itself
local function handleSystemsUpdate()
    local computers = computerAPI.listComputers()
    for _, computer in computers do
        if computer.id ~= os.getComputerID() then
            local message = repositoryAPI.buildRequest('/systems/update')
            modemAPI.sendMessage(message, computer.id)
            print('Updating computer: ' .. computer.id)
        end
    end
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
    if handler then handler(request, replyChannel) end

    return request.url ~= '/computer/update'
end

-- Occurs after any default event handling
function eventHandlerAPI.handlePost(_, _)
    return false
end

return eventHandlerAPI
