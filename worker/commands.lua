os.loadAPI('constants.lua')
os.loadAPI('display.lua')
os.loadAPI('functions.lua')
os.loadAPI('json.lua')

local function updateInfo()
    return functions.requestFarmInfo(constants.CHANNEL)
end

local function handleMessage(message)
    local infoTable = {}

    if message == 'updateInfo' then
        infoTable = updateInfo()
    else
        infoTable = json.decode(response.message)
    end

    if constants.MONITOR_SIDE ~= 'none' then display.writeFarmInfo(infoTable) end
    return infoTable.state and 'turnOn' or 'turnOff'
end

local function changeSignal(state)
    return function()
        redstone.setOutput(constants.REDSTONE_SIDE, state)
    end
end

local commandTable = {
    turnOn = changeSignal(true),
    turnOff = changeSignal(false)
}

function runCommandIfExists(message, replyChannel)
    local commandName = handleMessage(message)
    local command = commandTable[commandName]
    if not command then return false end

    print('\nExecuting: ' .. commandName)
    command()
    return true
end
