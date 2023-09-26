local args = {...}
local computerAPI = nil

if fs.exists('computerAPI.lua') then
    computerAPI = require('computerAPI')
elseif fs.exists('cc-mine/utils/computerAPI.lua') then
    computerAPI = require('cc-mine/utils/computerAPI')
end

local function chooseComputerType()
    local types = computerAPI.computerTypes
    print('\nSelect the computer type:')

    for index, value in ipairs(types) do
        print(tostring(index) .. ') ' .. value)
    end

    local result = tonumber(read())
    local validResult = result > 0 and result <= #types
    if not validResult then result = #types end

    return types[result]
end

local function chooseSideFor(name, required)
    local sidesTable = computerAPI.computerSides

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
        result = #sidesTable
    end

    return sidesTable[result]
end

local function chooseSides() {
    local modemSide = chooseSideFor('modem', true)
    local monitorSide = chooseSideFor('monitor', false)
    local redstoneSide = chooseSideFor('redstone', true)

    return modemSide, monitorSide, redstoneSide
}

local function deleteFiles(list)
    for index, fileName in ipairs(list) do
        if fs.exists(fileName) then fs.delete(fileName) end
    end
end

local function copyFiles(path, force)
    local files = fs.list(path)
    for index, fileName in ipairs(files) do
        if (force or not fs.exists(fileName)) and fileName ~= 'install.lua' then
            fs.copy(path .. fileName, fileName)
        end
    end
end

local function unpack()
    local computerInfo = computerAPI and computerAPI.findComputer() or nil
    local computerType = computerInfo and computerInfo.computerType or chooseComputerType()

    local contentDir = 'cc-mine/' .. string.lower(computerType) .. '/'
    local contentFiles = fs.list(contentDir)

    local repositoryDir = 'cc-mine/repository/'
    local repositoryFiles = fs.list(repositoryDir)

    local utilDir = 'cc-mine/utils/'
    local utilFiles = fs.list(utilDir)

    deleteFiles(contentFiles)
    deleteFiles(repositoryFiles)
    deleteFiles(utilFiles)

    copyFiles(contentDir, true)
    copyFiles(repositoryDir)
    copyFiles(utilDir)

    fs.delete('cc-mine/')

    if not computerInfo then
        local modemSide, monitorSide, redstoneSide = chooseSides()

        local label = os.getComputerLabel()
        while not label or label == '' do
            print('Choose a name for this computer: ')
            label = read()
        end
        os.setComputerLabel(label)

        computerInfo = {
            id = os.getComputerID(),
            name = label,
            computerType = computerType,
            modemSide = modemSide,
            monitorSide = monitorSide,
            redstoneSide = redstoneSide
        }
        computerAPI.registerComputer(computerInfo)
    end
end

unpack()
os.reboot()
