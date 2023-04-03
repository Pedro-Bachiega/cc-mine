os.loadAPI('constants.lua')
os.loadAPI('functionAPI.lua')
os.loadAPI('logAPI.lua')
os.loadAPI('storageAPI.lua')

local function find(id, replyChannel)
    local response = storageAPI.find(id)
    if not response then
        response = functionAPI.toJson({
            error = 'NOT_FOUND',
            message = 'Not found for id: ' .. id
        })
    end

    sleep(0.2)
    functionAPI.sendMessage(response, replyChannel)
    return response
end

local function insert(id, replyChannel, request)
    content = functionAPI.toJson(request)
    storageAPI.insert(id, content)

    functionAPI.sendMessage(content, id)
    functionAPI.sendMessage(content, replyChannel)
end

function handle(request, replyChannel)
    print('\nRequest: ' .. functionAPI.toJson(request))

    local command = request.command
    if not request.body then return false end

    local body = request.body
    local id = body.id

    if command == 'insert' then
        insert(id, replyChannel, body)
        return true
    elseif command == 'find' then
        find(id, replyChannel)
        return true
    end

    return false
end
