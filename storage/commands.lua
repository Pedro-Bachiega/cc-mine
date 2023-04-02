os.loadAPI('constants.lua')
os.loadAPI('functions.lua')
os.loadAPI('storage.lua')

local function find(id, replyChannel)
    local response = storage.find(id)
    if not response then
        response = functions.toJson({
            error = 'NOT_FOUND',
            message = 'Not found for id: ' .. id
        })
    end

    sleep(0.2)
    print('Response: ' .. response)
    print('Responding to channel: ' .. replyChannel)
    functions.sendMessage(response, replyChannel)
    return response
end

local function insert(id, replyChannel, content)
    content = functions.toJson(content)
    storage.insert(id, content)

    print(string.format('Updating channels: [%d, %d]', id, replyChannel))
    functions.sendMessage(content, id)
    functions.sendMessage(content, replyChannel)
end

local function handleMessage(message, replyChannel)
    print('\nRequest: ' .. message)

    local handled = false

    local request = functions.fromJson(message)
    local method = request.method
    local body = request.body
    local id = body.id

    if method == 'INSERT' then
        insert(id, replyChannel, body)
        return true
    elseif method == 'FIND' then
        find(id, replyChannel)
        return true
    end

    return false
end

function runCommandIfExists(message, replyChannel)
    return handleMessage(message, replyChannel)
end
