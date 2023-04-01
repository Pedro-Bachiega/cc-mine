os.loadAPI('constants.lua')
os.loadAPI('functions.lua')
os.loadAPI('json.lua')
os.loadAPI('storage.lua')

local function find(id, replyChannel)
    local response = storage.find(id)
    if not response then
        response = json.encode({
            error = 'NOT_FOUND',
            message = 'Not found for id: ' .. id
        })
    end

    sleep(1)
    print('Response: ' .. response)
    local modem = functions.openModem()
    print('Responding to channel: ' .. replyChannel)
    modem.transmit(replyChannel, constants.CHANNEL, response)
    return true
end

local function insert(id, content)
    content = json.encode(content)
    storage.insert(id, content)
    return find(id, id)
end

local function handleMessage(message, replyChannel)
    print('\nRequest: ' .. message)

    local handled = false

    local request = json.decode(message)
    local method = request.method
    local body = request.body
    local id = body.id

    if method == 'INSERT' then
        handled = insert(id, body)
    elseif method == 'FIND' then
        handled = find(id, replyChannel)
    end

    return handled
end

function runCommandIfExists(message, replyChannel)
    return handleMessage(message, replyChannel)
end
