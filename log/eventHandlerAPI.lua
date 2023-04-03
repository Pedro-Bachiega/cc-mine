os.loadAPI('displayAPI.lua')
os.loadAPI('functionAPI.lua')

local fileName = string.format('data/%s-logs.json', functionAPI.getDate(false))

local function update()
    shell.run('update')
end

local function getLogs()
    if not fs.exists('data') then fs.makeDir('data') end
    local content = functionAPI.fromFile(fileName)
    return content and functionAPI.fromJson(content) or {}
end

local function saveLog(newLog)
    local logs = getLogs()
    table.insert(logs, newLog)
    functionAPI.toFile(fileName, functionAPI.toJson(logs))
    return logs
end

local function writeLog(message)    
    local info = {time = functionAPI.getDateTime(true), label = message}
    local logs = saveLog(info)
    displayAPI.draw(logs)
end

local function clearLogs()
    if fs.exists(fileName) then fs.delete(fileName) end
    displayAPI.draw(getLogs())
end

function handle(request, replyChannel)
    if request.command == 'write' then
        writeLog(request.body.message)
    elseif request.command == 'clear' then
        clearLogs()
    end
end
