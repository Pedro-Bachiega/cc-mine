os.loadAPI('displayAPI.lua')
os.loadAPI('functionAPI.lua')

local function update()
    shell.run('update')
end

local function getLogs()
    if not fs.exists('data') then fs.makeDir('data') end
    local content = functionAPI.fromFile('data/logs.txt')
    return content and functionAPI.fromJson(content) or {}
end

local function saveLog(newLog)
    local logs = getLogs()
    table.insert(logs, newLog)
    functionAPI.toFile('data/logs.txt', functionAPI.toJson(logs))
    return logs
end

local function writeLog(message)    
    local info = {time = functionAPI.getTimestamp(true), label = message}
    local logs = saveLog(info)
    displayAPI.draw(logs)
end

local function clearLogs()
    if fs.exists('data/logs.txt') then fs.delete('data/logs.txt') end
    displayAPI.draw(getLogs())
end

local function handleMessage(message, replyChannel)
    local request = functionAPI.fromJson(message)
    if request.command == 'write' then
        writeLog(request.body.message)
    elseif request.command == 'clear' then
        clearLogs()
    end
end

displayAPI.draw(getLogs())

while true do
    local eventTable = functionAPI.waitForEvent('modem_message')
    if eventTable.message == 'update' then
        update()
    else
        handleMessage(eventTable.message, eventTable.replyChannel)
    end
end
