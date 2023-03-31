local args = {...}

local function argsToKnownTable(args)
    local computerType = nil

    for index, value in ipairs(args) do
        if value == '-t' or value == '--type' then
            computerType = args[index + 1]
        end
    end

    return {
        computerType = computerType
    }
end

local argsTable = argsToKnownTable(args)
local computerType = argsTable.computerType

if fs.exists('constants.lua') then
    os.loadAPI('constants.lua')
    computerType = constants.COMPUTER_TYPE or computerType
else
    constants = {}
end

local function createStartup()
    local file = fs.open('startup.lua', 'w')
    file.write(string.format('shell.run(\'run.lua\', \'-t\', \'%s\')'), computerType)
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
    local modemSide = constants.MODEM_SIDE or chooseSideFor('modem', true)
    local monitorSide = constants.MONITOR_SIDE or chooseSideFor('monitor', false)
    local redstoneSide = constants.REDSTONE_SIDE or (computerType == 'worker' and chooseSideFor('redstone', true) or 'none')

    local channel = constants.CHANNEL or (computerType == 'storage' and '420' or chooseChannel())

    local constants = [[
-- Computer
COMPUTER_TYPE = '<computer_type>'

-- Generic
MODEM_SIDE = '<modem_side>'
MONITOR_SIDE = '<monitor_side>'
REDSTONE_SIDE = '<redstone_side>'

-- Channels
CHANNEL = <channel>
CHANNEL_STORAGE = 420
    ]]

    constants = string.gsub(constants, '<computer_type>', computerType)
    constants = string.gsub(constants, '<modem_side>', modemSide)
    constants = string.gsub(constants, '<monitor_side>', monitorSide)
    constants = string.gsub(constants, '<redstone_side>', redstoneSide)
    constants = string.gsub(constants, '<channel>', channel)

    local file = fs.open('constants.lua', 'w')
    file.write(constants)
    file.close()
end

local function deleteFiles(list)
    for index, fileName in ipairs(list) do
        if fs.exists(fileName) then fs.delete(fileName) end
    end
end

local function unpack()
    local contentDir = 'cc-mine-atm8/' .. computerType .. '/'
    local contentFiles = fs.list(contentDir)
    deleteFiles(contentFiles)

    local utilsDir = 'cc-mine-atm8/utils/'
    local utilFiles = fs.list(utilsDir)
    deleteFiles(utilFiles)
    
    for index, fileName in ipairs(contentFiles) do
        fs.copy(contentDir .. fileName, fileName)
    end
    for index, fileName in ipairs(utilFiles) do
        if not fs.exists(fileName) and fileName ~= 'install.lua' then
            fs.copy(utilsDir .. fileName, fileName)
        end
    end

    fs.delete('cc-mine-atm8/')

    writeConstants()
    createStartup()
end

unpack()
shell.run('run.lua', '-t', computerType)
