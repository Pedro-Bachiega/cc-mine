local sidesTable = {'top', 'right', 'bottom', 'left', 'back', 'none'}
local sidesCount = 6

local function chooseSideFor(name, required)
    print('\nSelect the side the ' .. name .. ' is attached to:')

    for index, value in ipairs(sidesTable) do
        print(tostring(index) .. ') ' .. value)
    end

    local result = tonumber(read())
    local validResult = result > 0 and result <= sidesCount

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
    local redstoneSide = chooseSideFor('redstone', true)

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

local function createStartup()
    local file = fs.open('startup.lua', 'w')
    file.write('shell.run(\'work.lua\')')
    file.close()
end

local function unpack()
    local workerDir = 'cc-mine-atm8/worker/'
    local workerFiles = fs.list(workerDir)
    for index, fileName in ipairs(workerFiles) do
        if fs.exists(fileName) then fs.delete(fileName) end
        if fileName ~= 'install.lua' then fs.copy(workerDir .. fileName, fileName) end
    end

    local utilsDir = 'cc-mine-atm8/utils/'
    local utilFiles = fs.list(utilsDir)
    for index, fileName in ipairs(utilFiles) do
        if fs.exists(fileName) then fs.delete(fileName) end
        fs.copy(utilsDir .. fileName, fileName)
    end

    fs.delete('cc-mine-atm8/')

    writeConstants()
    createStartup()
end

unpack()
shell.run('work.lua')
