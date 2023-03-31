os.loadAPI('constants.lua')
os.loadAPI('functions.lua')

local function changeSignal(state)
    return function()
        redstone.setOutput(constants.REDSTONE_SIDE, state)

        if constants.MONITOR_SIDE ~= 'none' then
            local monitor = peripheral.wrap(constants.MONITOR_SIDE)
            local maxX, maxY = monitor.getSize()
            local cursorX = 0

            monitor.clear()
            cursorY = functions.round((maxY / 2) - 1)
            cursorX = functions.round((maxX / 2) - 2, 2)
            monitor.setCursorPos(cursorX, cursorY)
            monitor.write('State:')
            cursorY = functions.round((maxY / 2) + 1)
            cursorX = functions.round((maxX / 2) - (state and 0 or 1))
            monitor.setCursorPos(cursorX, cursorY)
            monitor.write(state and 'On' or 'Off')
        end
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
