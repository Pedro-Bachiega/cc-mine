local cacheAPI = require('cacheAPI')
local httpAPI = require('httpAPI')

-- Where all requests on '/computer' api are made
local computerRepository = {}

-- Deletes computer on cache and system
function computerRepository.deleteComputer(id)
    print('---------------------')

    local statusCode, _ = httpAPI.delete('/computer/' .. id)
    if statusCode == 200 then
        local cachePath = 'computer/information-' .. id .. '.json'
        cacheAPI.deleteFromCache(cachePath)

        print('Computer deleted')
        return true
    else
        print('Error searching for computer')
    end

    print('---------------------')

    return false
end

-- Searches for computer on cache or system (only on system if 'force' == true)
function computerRepository.findComputer(id, force)
    ---@diagnostic disable-next-line: undefined-field
    local computerId = id or os.getComputerID()
    local cachePath = 'computer/information-' .. computerId .. '.json'
    local cachedComputer = cacheAPI.fromCache(cachePath)

    if force then
        cacheAPI.deleteFromCache(cachePath)
    elseif cachedComputer then
        return cachedComputer
    end

    print('---------------------')

    local statusCode, response = httpAPI.get('/computer/' .. computerId)
    if statusCode == 200 and response then
        cacheAPI.saveToCache(cachePath, response, nil, true)
        return response
    elseif statusCode == 404 then
        print('Computer not registered')
    else
        print('Error searching for computer')
    end

    print('---------------------')

    return nil
end

-- Lists computers on cache or system (only on system if 'force' == true).
-- Can be filtered by computerType by passing an array of 'computerAPI.computerTypes'
function computerRepository.listComputers(computerTypes, force)
    local cachePath = 'computer/list-' .. (computerTypes or 'all') .. '.json'
    local cachedList = cacheAPI.fromCache(cachePath)

    if force then
        cacheAPI.deleteFromCache(cachePath)
    elseif cachedList then
        return cachedList
    end

    local url = '/computer/list'
    if computerTypes then
        local typesQueryParam = '?computerTypes='

        for index, computerType in ipairs(computerTypes) do
            if index > 0 then typesQueryParam = typesQueryParam .. ',' end
            typesQueryParam = typesQueryParam .. computerType
        end

        url = url .. typesQueryParam
    end

    print('---------------------')

    local statusCode, response = httpAPI.get(url)
    if statusCode == 200 and response then
        cacheAPI.saveToCache(cachePath, response, nil, true)
        return response
    elseif statusCode == 404 then
        print('Computer not registered')
    else
        print('Error searching for computer')
    end

    print('---------------------')

    return nil
end

-- Registers computer on system
function computerRepository.registerComputer(computer)
    print('---------------------')

    local statusCode, response = httpAPI.post('/computer/register', computer)
    if statusCode == 200 then
        return response
    else
        print('Error registering computer')
    end

    print('---------------------')

    return nil
end

-- Updates computer on system
function computerRepository.updateComputer(computer)
    print('---------------------')

    local statusCode, response = httpAPI.post('/computer/update', computer)
    if statusCode == 200 then
        return response
    else
        print('Error updating computer')
    end

    print('---------------------')

    return nil
end

return computerRepository
