if pocket then return end

os.loadAPI('functionAPI.lua')
os.loadAPI('logAPI.lua')

local function clearCache()
    logAPI.log('Clearing cache')
    if fs.exists('cache') then fs.delete('cache') end
end

local function exportChannels(content, replyChannel)
    print('\nExporting channels')
    local content = functionAPI.fromFile('channels.lua')
    local response = {body = content}
    functionAPI.sendMessage(functionAPI.toJson(response), replyChannel)
end

local function updateChannels(content)
    print('\nSynchronizing channels')
    functionAPI.toFile('channels.lua', content)
end

function handle(request, replyChannel)
    local command = request.command
    if command == 'clearCache' then
        clearCache()
        return true
    elseif command == 'exportChannels' then
        exportChannels(request.body, replyChannel)
        return true
    elseif command == 'synchronizeChannels' then
        updateChannels(request.body)
        return true
    end

    return false
end
