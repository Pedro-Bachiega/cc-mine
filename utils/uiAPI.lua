os.loadAPI('functionAPI.lua')

function drawAt(monitor, text, x, y, color)
    monitor.setCursorPos(x, y)
    monitor.setTextColor(color or colors.white)
    monitor.write(text)

    return x + #text + 1
end

function drawHorizontalDividerAt(monitor, y)
    local monWidth, monHeight = monitor.getSize()
    drawAt(monitor, string.rep('-', monWidth), 1, y)
end

function drawHeader(monitor, text)
    drawAt(monitor, text, 2, 2, colors.purple)
    drawHorizontalDividerAt(monitor, 3)

    local nextContentLine = 5
    return nextContentLine
end

function drawFooter(monitor, text)
    local monWidth, monHeight = monitor.getSize()
    drawAt(monitor, text, 2, monHeight - 1, colors.lightGray)
    drawHorizontalDividerAt(monitor, monHeight - 2)

    local maxContentLine = monHeight - 3
    return maxContentLine
end

function drawTimestampFooter(monitor)
    return drawFooter(monitor, 'Updated at: ' .. functionAPI.getDateTime())
end
