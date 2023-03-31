os.loadAPI('constants.lua')
os.loadAPI('functions.lua')
os.loadAPI('json.lua')
os.loadAPI('storage.lua')

local function insert(id, content)
    content = json.encode(content)
    storage.insert(id, content)
    print('\nInserting id: ' .. id)
    return true
end

local function find(id, replyChannel)
    local response = storage.find(id)
    if response then
        print('\nFound for id: ' .. id)
    else
        print('\nNot found for id: ' .. id)
        response = json.encode({
            error = 'NOT_FOUND',
            message = 'Not found for id: ' .. id
        })
    end

    sleep(1)
    local modem = functions.openModem()
    modem.transmit(replyChannel, constants.CHANNEL, response)
    print('Response: ' .. response)
    return true
end

local function handleMessage(message, replyChannel)
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
