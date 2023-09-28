local repositoryAPI = require("repositoryAPI")
local modemAPI = require("modemAPI")
local computerRepository = {}

local defaultTimeoutSeconds = 30

function computerRepository.deleteComputer()
    local args = { id = os.getComputerId() }
    local request = repositoryAPI.buildRequest('/computer/delete', args)
    return modemAPI.broadcastMessage(request)
end

function computerRepository.findComputer(force)
    local args = { id = os.getComputerId(), force = force }
    local request = repositoryAPI.buildRequest('/computer/find', args)
    return modemAPI.broadcastMessageAndWaitResponse(request, nil, defaultTimeoutSeconds)
end

function computerRepository.listComputers(computerType, force)
    local args = { computerType = computerType, force = force }
    local request = repositoryAPI.buildRequest('/computer/list', args)
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
