local functionAPI = require('functionAPI')

local uiAPI = {}

function uiAPI.drawAt(monitor, text, x, y, color)
    monitor.setCursorPos(x, y)
    monitor.setTextColor(color or colors.white)
    monitor.write(text)

    return x + #text + 1
end

function uiAPI.drawHorizontalDividerAt(monitor, y)
    local monWidth, _ = monitor.getSize()
    uiAPI.drawAt(monitor, string.rep('-', monWidth), 1, y)
end

function uiAPI.drawHeader(monitor, text)
    uiAPI.drawAt(monitor, text, 2, 2, colors.purple)
    uiAPI.drawHorizontalDividerAt(monitor, 3)

    local nextContentLine = 5
    return nextContentLine
end

function uiAPI.drawFooter(monitor, text)
    local _, monHeight = monitor.getSize()
    uiAPI.drawAt(monitor, text, 2, monHeight - 1, colors.lightGray)
    uiAPI.drawHorizontalDividerAt(monitor, monHeight - 2)

    local maxContentLine = monHeight - 3
    return maxContentLine
end

function uiAPI.drawTimestampFooter(monitor)
    return uiAPI.drawFooter(monitor, 'Updated at: ' .. functionAPI.getDateTime(true))
end

return uiAPI
