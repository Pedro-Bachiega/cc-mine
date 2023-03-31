local args = {...}

os.loadAPI('cc-mine-atm8/utils/machine.lua')

local argsTable = machine.argsToKnownTable(args)
local computerType = argsTable.computerType

local function createStartup()
    local file = fs.open('startup.lua', 'w')
    file.write('shell.run(\'run.lua\')')
    file.close()
end

local function chooseSideFor(name, required)
    local sidesTable = {'top', 'right', 'bottom', 'left', 'back', 'none'}

    print('\nSelect the side the ' .. name .. ' is attached to:')

    for index, value in ipairs(sidesTable) do
        print(tostring(index) .. ') ' .. value)
    end

    local result = tonumber(read())
    local validResult = result > 0 and result <= #sidesTable

    if not validResult and required then
        error('Invalid choice')
    elseif not validResult then
        result = 6
    end

    return sidesTable[result]
end

local function chooseChannel()
    print('\nInput the channel this computer use: ')
    return read()
end

local function writeConstants()
    local modemSide = chooseSideFor('modem', true)
    local monitorSide = chooseSideFor('monitor', false)
    local redstoneSide = computerType == 'worker' and chooseSideFor('redstone', true) or 'none'

    local channel = chooseChannel()

    local constants = [[
-- Generic
MODEM_SIDE = '<modem_side>'
MONITOR_SIDE = '<monitor_side>'
REDSTONE_SIDE = '<redstone_side>'

-- Channels
CHANNEL = <channel>
    ]]

    constants = string.gsub(constants, '<modem_side>', modemSide)
    constants = string.gsub(constants, '<monitor_side>', monitorSide)
    constants = string.gsub(constants, '<redstone_side>', redstoneSide)
    constants = string.gsub(constants, '<channel>', channel)

    local file = fs.open('constants.lua', 'w')
    file.write(constants)
    file.close()
end

local function unpack()
    local contentDir = 'cc-mine-atm8/' .. computerType .. '/'
    local contentFiles = fs.list(contentDir)
    for index, fileName in ipairs(contentFiles) do
        if fs.exists(fileName) then fs.delete(fileName) end
        fs.copy(contentDir .. fileName, fileName)
    end

    local utilsDir = 'cc-mine-atm8/utils/'
    local utilFiles = fs.list(utilsDir)
    for index, fileName in ipairs(utilFiles) do
        if fs.exists(fileName) then fs.delete(fileName) end
        if fileName ~= 'install.lua' then fs.copy(utilsDir .. fileName, fileName) end
    end

    fs.delete('cc-mine-atm8/')

    if argsTable.skipConstants then print('\nUpdated') else writeConstants() end
    createStartup()
end

unpack()
shell.run('run.lua', '-t', computerType)
