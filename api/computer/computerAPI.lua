local computerModel = require('model.computer')
local computerRepository = require('repository.computerRepository')

local computerAPI = {}

function computerAPI.createDefaultData(computerType, args)
    local data = computerModel.defaultData[computerType]
    if not data then return {} end

    for key, value in pairs(args) do data[key] = value end

    return data
end

function computerAPI.deleteComputer()
    return computerRepository.deleteComputer()
end

function computerAPI.findComputer(id, force)
    return computerRepository.findComputer(id, force)
end

function computerAPI.findComputerType()
    return computerAPI.findComputer().type
end

function computerAPI.listComputers(computerType, force)
    return computerRepository.listComputers(computerType, force)
end

function computerAPI.registerComputer(id, name, type, redstoneSide)
    local computer = {
        name = name,
        computerId = id,
        type = type,
        redstoneSide = redstoneSide,
        data = computerAPI.createDefaultData(type, { id = id })
    }
    return computerRepository.registerComputer(computer)
end

function computerAPI.updateComputer(computer)
    return computerRepository.updateComputer(computer)
end

return computerAPI
