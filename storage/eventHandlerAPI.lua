os.loadAPI('functionAPI.lua')
os.loadAPI('storageAPI.lua')

local function find(channel, replyChannel)
    local response = storageAPI.find(channel)
    if not response then
        response = functionAPI.toJson({
            error = 'NOT_FOUND',
            message = 'Not found for channel: ' .. channel
        })
    end

    sleep(0.2)
    functionAPI.sendMessage(response, replyChannel)
    return response
end

local function insert(channel, replyChannel, request)
    content = functionAPI.toJson(request)
    storageAPI.insert(channel, content)

    functionAPI.sendMessage(content, channel)
    functionAPI.sendMessage(content, replyChannel)
end

function handle(request, replyChannel)
    print('\nRequest: ' .. functionAPI.toJson(request))

    local command = request.command
    if not request.body then return false end

    local body = request.body
    local channel = body.channel

    if command == 'insert' then
        insert(channel, replyChannel, body)
        return true
    elseif command == 'find' then
        find(channel, replyChannel)
        return true
    end

    return false
end
