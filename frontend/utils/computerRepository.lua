local repositoryAPI = require('repositoryAPI')
local modemAPI = require('modemAPI')
local computerRepository = {}

local defaultTimeoutSeconds = 30

function computerRepository.deleteComputer()
    local params = { id = os.getComputerID() }
    local request = repositoryAPI.buildRequest('/computer/delete', params)
    return modemAPI.broadcastMessage(request)
end

function computerRepository.findComputer(force)
    local params = { id = os.getComputerID(), force = force }
    local request = repositoryAPI.buildRequest('/computer/find', params)
    return modemAPI.broadcastMessageAndWaitResponse(request, nil, defaultTimeoutSeconds)
end

function computerRepository.listComputers(computerType, force)
    local params = { computerType = computerType, force = force }
    local request = repositoryAPI.buildRequest('/computer/list', params)
    return modemAPI.broadcastMessageAndWaitResponse(request, nil, defaultTimeoutSeconds)
end

function computerRepository.registerComputer(computer)
    local request = repositoryAPI.buildRequest('/computer/register', computer)
    return modemAPI.broadcastMessageAndWaitResponse(request, nil, defaultTimeoutSeconds)
end

function computerRepository.updateComputer(computer, waitResponse)
    local request = repositoryAPI.buildRequest('/computer/update', computer)
    if waitResponse then
        return modemAPI.broadcastMessageAndWaitResponse(request, nil, defaultTimeoutSeconds)
    else
        return modemAPI.broadcastMessage(request)
    end
end

return computerRepository
