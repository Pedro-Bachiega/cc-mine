os.loadAPI('constants.lua')
os.loadAPI('functions.lua')

local function changeSignal(state)
    return function()
        redstone.setOutput(constants.REDSTONE_SIDE, state)
    end
end

local commandTable = {
    turnOn = changeSignal(true),
    turnOff = changeSignal(false)
}

function runCommandIfExists(commandName)
    local command = commandTable[commandName]
    if command == nil then return false end

    print("\nExecuting: " .. commandName)
    command()
    return true
end
