local repositoryAPI = require('repositoryAPI')
local modemAPI = require('modemAPI')
local computerRepository = {}

local defaultTimeoutSeconds = 30

function computerRepository.deleteComputer(id)
    ---@diagnostic disable-next-line: undefined-field
    local params = { id = id or os.getComputerID() }
    local request = repositoryAPI.buildRequest('/computer/delete', params)
    return modemAPI.broadcastMessage(request)
end

function computerRepository.findComputer(id, force)
    ---@diagnostic disable-next-line: undefined-field
    local params = { id = id or os.getComputerID(), force = force }
    local request = repositoryAPI.buildRequest('/computer/find', params)
    return modemAPI.broadcastMessageAndWaitResponse(request, nil, defaultTimeoutSeconds).message
end

function computerRepository.fetchNetworkingComputer(networkingComputerId)
    local params = { id = networkingComputerId }
    local request = repositoryAPI.buildRequest('/computer/find', params)
    return modemAPI.broadcastMessageAndWaitResponse(request, nil, defaultTimeoutSeconds, nil, networkingComputerId).message
end

function computerRepository.listComputers(computerType, force)
    local params = { computerType = computerType, force = force }
    local request = repositoryAPI.buildRequest('/computer/list', params)
    return modemAPI.broadcastMessageAndWaitResponse(request, nil, defaultTimeoutSeconds).message
end

function computerRepository.registerComputer(computer)
    local request = repositoryAPI.buildRequest('/computer/register', computer)
    return modemAPI.broadcastMessageAndWaitResponse(request, nil, defaultTimeoutSeconds).message
end

function computerRepository.updateComputer(computer, waitResponse)
    local request = repositoryAPI.buildRequest('/computer/update', computer)
    if waitResponse then
        return modemAPI.broadcastMessageAndWaitResponse(request, nil, defaultTimeoutSeconds).message
    else
        return modemAPI.broadcastMessage(request)
    end
end

return computerRepository
