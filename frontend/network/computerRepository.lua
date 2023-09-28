local cacheAPI = require('cacheAPI')
local httpAPI = require('httpAPI')

-- Where all requests on '/computer' api are made
local computerRepository = {}

-- Deletes computer on cache and system
function computerRepository.deleteComputer(id)
    local statusCode, _ = httpAPI.delete('/computer/' .. id)
    if statusCode == 200 then
        local cachePath = 'computer/information-' .. id .. '.json'
        cacheAPI.deleteFromCache(cachePath)

        print('Computer deleted')
        return true
    else
        print('Error searching for computer')
    end

    return false
end

-- Searches for computer on cache or system (only on system if 'force' == true)
function computerRepository.findComputer(id, force)
    local cachePath = 'computer/information-' .. id .. '.json'
    if fs.exists(cachePath) then
        if force then
            cacheAPI.deleteFromCache(cachePath)
        else
            return cacheAPI.fromCache(cachePath)
        end
    end

    local statusCode, response = httpAPI.get('/computer/' .. id)
    if statusCode == 200 and response then
        print('Computer found')
        cacheAPI.saveToCache(cachePath, response, true, true)
        return response
    elseif statusCode == 404 then
        print('Computer not registered')
    else
        print('Error searching for computer')
    end

    return nil
end

-- Lists computers on cache or system (only on system if 'force' == true).
-- Can be filtered by computerType by passing an array of 'computerAPI.computerTypes'
function computerRepository.listComputers(computerTypes, force)
    local cachePath = 'computer/list-' .. (computerTypes or 'all') .. '.json'
    if fs.exists(cachePath) then
        if force then
            cacheAPI.deleteFromCache(cachePath)
        else
            return cacheAPI.fromCache(cachePath)
        end
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

    local statusCode, response = httpAPI.get(url)
    if statusCode == 200 and response then
        print('Computer found')
        cacheAPI.saveToCache(cachePath, response, true, true)
        return response
    elseif statusCode == 404 then
        print('Computer not registered')
    else
        print('Error searching for computer')
    end

    return nil
end

-- Registers computer on system
function computerRepository.registerComputer(computer)
    local statusCode, response = httpAPI.post('/computer/register', computer)
    if statusCode == 200 then
        print('Computer registered')
        return response
    else
        print('Error registering computer')
    end

    return nil
end

-- Updates computer on system
function computerRepository.updateComputer(computer)
    local statusCode, response = httpAPI.post('/computer/update', computer)
    if statusCode == 200 then
        print('Computer updated')
        return response
    else
        print('Error updating computer')
    end

    return nil
end

return computerRepository
