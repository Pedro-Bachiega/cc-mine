os.loadAPI('uiAPI.lua')

local monitor = peripheral.wrap(constants.MONITOR_SIDE)

local function format(log)
    return string.format('[%s] %s', log.time, log.label)
end

local function takeLogs(logs, quantity)
    local filtered = {}
    for i = (#logs - quantity), #logs do
        table.insert(filtered, logs[i])
    end
    return filtered
end

function draw(logs)
    monitor.clear()

    local minContentLine = uiAPI.drawHeader(monitor, 'Logs:')
    local maxContentLine = uiAPI.drawTimestampFooter(monitor)
    local linesAvailable = maxContentLine - minContentLine

    local logQuantity = logs and #logs or 0
    local filtered = logQuantity > linesAvailable and takeLogs(logs, linesAvailable) or logs or {}

    y = minContentLine
    for k, log in pairs(filtered) do
        uiAPI.drawAt(monitor, format(log), 2, y)
        y = y + 1
    end
end
