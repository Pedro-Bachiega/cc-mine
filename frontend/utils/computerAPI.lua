local computerRepository = require("comuterRepository.lua")

computerTypes = {
    FARM = 'FARM',
    MANAGER = 'MANAGER',
    NETWORK = 'NETWORK',
    WORKER = 'WORKER'
}

computerSides = {
    TOP = 'TOP',
    RIGHT = 'RIGHT',
    BOTTOM = 'BOTTOM',
    LEFT = 'LEFT',
    BACK = 'BACK',
    NONE = 'NONE'
}

function deleteComputer(id)
    return computerRepository.deleteComputer(id)
end

function findComputer(force)
    local response = computerRepository.findComputer(os.getComputerId(), force)
    if not response then
        error('You must register this pc before using')
    end
    return response
end

function listComputers(computerType, force)
    return computerRepository.listComputers(computerType, force)
end

function registerComputer(request)
    return computerRepository.registerComputer(request)
end
