local computerRepository = require('computerRepository')

local computerAPI = {
    computerTypes = {
        FARM = 'FARM',
        MANAGER = 'MANAGER',
        NETWORK = 'NETWORK',
        WORKER = 'WORKER'
    },
    computerSides = {
        TOP = 'TOP',
        RIGHT = 'RIGHT',
        BOTTOM = 'BOTTOM',
        LEFT = 'LEFT',
        BACK = 'BACK',
        NONE = 'NONE'
    }
}

local defaultData = {
    FARM = {
        state = false
    }
}

function computerAPI.createDefaultData(computerType, args)
    local data = defaultData[computerType]
    if not data then return nil end

    for key, value in pairs(args) do data[key] = value end

    return data
end

function computerAPI.deleteComputer()
    return computerRepository.deleteComputer()
end

function computerAPI.findComputer(force)
    return computerRepository.findComputer(force)
end

function computerAPI.listComputers(computerType, force)
    return computerRepository.listComputers(computerType, force)
end

function computerAPI.registerComputer(computer)
    return computerRepository.registerComputer(computer)
end

function computerAPI.updateComputer(computer)
    return computerRepository.updateComputer(computer)
end

return computerAPI
