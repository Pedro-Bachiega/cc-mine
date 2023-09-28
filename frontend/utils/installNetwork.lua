local computerAPI = require('computerAPI')
local functionAPI = require('functionAPI')
local fileAPI = require('fileAPI')

local args = { ... }
local computerType = args[1] or error('No computerType passed')

local function chooseSideFor(name, required)
    local sidesTable = functionAPI.tableToValueArray(computerAPI.computerSides)

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
        error('Invalid choice')
    elseif not validResult then
        return computerAPI.computerSides.NONE
    end

    return sidesTable[result]
end

local redstoneSide = pocket and computerAPI.computerSides.NONE or chooseSideFor('redstone')

---@diagnostic disable-next-line: undefined-field
local label = os.getComputerLabel()
while not label or label == '' do
    print('Choose a name for this computer: ')
    label = read()
end

---@diagnostic disable-next-line: undefined-field
os.setComputerLabel(label)

---@diagnostic disable-next-line: undefined-field
local computerId = os.getComputerID()
local computerInfo = {
    id = computerId,
    name = label,
    computerType = computerType,
    redstoneSide = redstoneSide,
    data = computerAPI.createDefaultData(computerType, { id = computerId })
}

computerAPI.registerComputer(computerInfo)

fileAPI.deleteFile('install.lua')

---@diagnostic disable-next-line: undefined-field
os.reboot()
