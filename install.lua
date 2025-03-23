local computerAPI = require('api.computer.computerAPI')
local computerSides = require('model.computerSides')
local computerTypes = require('model.computerTypes')
local functionAPI = require('api.util.functionAPI')
local fileAPI = require('api.util.fileAPI')

-- Choose computer type from [computerTypes] enum
local function chooseComputerType()
    local typesArray = functionAPI.tableToValueArray(computerTypes)

    local validResult = false
    local result = 0
    while not validResult do
        print('\nSelect the computer type:')

        for index, value in ipairs(typesArray) do
            print(tostring(index) .. ' - ' .. value)
        end

        result = tonumber(read()) or 0
        validResult = result > 0 and result <= #typesArray
    end

    return typesArray[result]
end

-- Choose a side from [computerSides] enum
local function chooseSideFor(name, required)
    if pocket then return computerSides.NONE end

    local sidesTable = functionAPI.tableToValueArray(computerSides)

    print('\nSelect the side the ' .. name .. ' is attached to:')

    for index, value in ipairs(sidesTable) do
        print(tostring(index) .. ' - ' .. value)
    end

    local result = read()
    local validResult = false
    if result ~= "" then
        result = tonumber(result)
        validResult = result > 0 and result <= #sidesTable
    end

    if not validResult and required then
        print('Invalid choice')
        chooseSideFor(name, required)
    elseif not validResult then
        return computerSides.NONE
    end

    return sidesTable[result]
end

---@diagnostic disable-next-line: undefined-field
local label = os.getComputerLabel()
while not label or label == '' do
    print('Choose a name for this computer: ')
    label = read()
end

---@diagnostic disable-next-line: undefined-field
os.setComputerLabel(label)

local computerType = computerAPI.findComputerType() or chooseComputerType()
local redstoneSide = chooseSideFor('redstone', true)

print('\nPlease input the network manager computer ID: ')
local networkManagerId = read()

-- Check if networkManagerId not a number
while not networkManagerId or not networkManagerId:match('^[0-9]+$') do
    print('Invalid network manager ID. It must be a number.')
    networkManagerId = read()
end

---@diagnostic disable-next-line: undefined-field
computerAPI.registerComputer(os.getComputerID(), label, computerType, redstoneSide)

fileAPI.deleteFile('install.lua')

---@diagnostic disable-next-line: undefined-field
os.reboot()
