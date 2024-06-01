local dateAPI = require('api.util.dateAPI')
local peripheralAPI = require('api.util.peripheralAPI')

-- Responsible for controlling a monitor
local monitorAPI = {
    cursor = {
        x = 0,
        y = 0
    },
    padding = {
        horizontal = 0,
        vertical = 0
    },
    monitor = peripheralAPI.getPeripheral('monitor'),
    textColor = colors.white,
}

-- Clears the monitor's content
function monitorAPI.clear()
    monitorAPI.monitor.clear()
    return monitorAPI
end

-- Gets the monitor's size
function monitorAPI.getSize()
    return monitorAPI.monitor.getSize()
end

-- Gets the monitor's maximum y position
function monitorAPI.getMaxY()
    local _, height = monitorAPI.getSize()
    return height - monitorAPI.padding.vertical
end

-- Jumps to the next line
function monitorAPI.nextLine()
    monitorAPI.cursor.y = monitorAPI.cursor.y + 1
    return monitorAPI
end

-- Returns the monitor or asks for a new monitor to be attached
function monitorAPI.requireMonitor()
    return monitorAPI.monitor or peripheralAPI.requirePeripheral('monitor')
end

-- Sets the cursor position
function monitorAPI.setCursorPos(x, y)
    monitorAPI.cursor.x = x + monitorAPI.padding.horizontal or monitorAPI.cursor.x
    monitorAPI.cursor.y = y + monitorAPI.padding.vertical or monitorAPI.cursor.y
    monitorAPI.monitor.setCursorPos(monitorAPI.cursor.x, monitorAPI.cursor.y)
    return monitorAPI
end

-- Set the monitor we're using
function monitorAPI.setMonitor(monitor)
    monitorAPI.monitor = monitor
    return monitorAPI
end

-- Sets the monitor's padding
function monitorAPI.setPadding(horizontal, vertical)
    monitorAPI.padding.horizontal = horizontal or monitorAPI.padding.horizontal
    monitorAPI.padding.vertical = vertical or monitorAPI.padding.vertical
    return monitorAPI
end

-- Set the text color
function monitorAPI.setTextColor(color)
    monitorAPI.textColor = color
    return monitorAPI
end

-- Print text to the monitor
function monitorAPI.print(text, color)
    monitorAPI.monitor.setTextColor(color or monitorAPI.textColor)
    monitorAPI.monitor.write(text)
    return monitorAPI.setCursorPos(nil, monitorAPI.cursor.x + #text + 1)
end

-- Print text to the monitor at the specified position
function monitorAPI.printAt(text, x, y, color)
    return monitorAPI.setCursorPos(x, y)
        .print(text, color)
end

-- Prints text to the monitor and jumps to a new line
function monitorAPI.printLine(text, color)
    return monitorAPI.printAt(text, 1, monitorAPI.cursor.y, color)
        .setCursorPos(nil, monitorAPI.cursor.y + 1)
end

-- Draws a horizontal divider repeating the specified character
function monitorAPI.drawHorizontalDivider(character)
    local monWidth, _ = monitorAPI.getSize()
    return monitorAPI.printLine(string.rep(character or '-', monWidth))
end

-- Draws a horizontal divider at given y repeating the specified character
function monitorAPI.drawHorizontalDividerAt(y, character)
    return monitorAPI.setCursorPos(1, y)
        .drawHorizontalDivider(character)
end

function monitorAPI.drawHeaderAt(y, text, color)
    return monitorAPI.printAt(text, 1, y, color or colors.purple)
        .drawHorizontalDividerAt(y + 1)
end

function monitorAPI.drawHeader(text, color)
    return monitorAPI.drawHeaderAt(1, text, color)
end

function monitorAPI.drawFooterAt(y, text, color)
    return monitorAPI.drawHorizontalDividerAt(y - 1)
        .printLine(text, color or colors.lightGray)
end

function monitorAPI.drawFooter(text, color)
    return monitorAPI.drawFooterAt(monitorAPI.getMaxY() - monitorAPI.padding.vertical, text, color)
end

function monitorAPI.drawTimestampFooter()
    return monitorAPI.drawFooter('Updated at: ' .. dateAPI.getDateTime(true))
end

return monitorAPI
