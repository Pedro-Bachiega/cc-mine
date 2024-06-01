local cacheAPI = require('api.repository.cacheAPI')
local httpAPI = require('api.network.httpAPI')

---@diagnostic disable-next-line: undefined-field
local localComputerId = os.getComputerID()

-- Where all requests on '/computer' api are made
local computerRepository = {}

-- Deletes computer on cache and backend
function computerRepository.deleteComputer()
    local options = httpAPI.getDefaultOptions()
        .onFailure(function(_, _) print('Error searching for computer') end)
        .onSuccess(function(_)
            cacheAPI.deleteFromCache('computer.json')
            print('Computer deleted')
        end)
    local _, deleted = httpAPI.delete('/computer/' .. localComputerId, options)
    return deleted
end

-- Searches for computer on cache or backend (only on system if 'force' == true)
function computerRepository.findComputer(id, force)
    local computerId = id or localComputerId
    local cachePath = 'computer/information-' .. computerId .. '.json'
    local cachedComputer = cacheAPI.fromCache(cachePath)

    if force then
        cacheAPI.deleteFromCache(cachePath)
    elseif cachedComputer then
        print('Computer found on cache')
        return cachedComputer
    end

    local options = httpAPI.getDefaultOptions()
        .onSuccess(function(response) cacheAPI.saveToCache(cachePath, response, nil, true) end)
        .onFailure(function(_, statusCode)
            print(statusCode == 404 and 'Computer not registered' or 'Error searching for computer')
        end)
    return httpAPI.get('/computer/' .. computerId, options)
end

-- Lists computers on cache or backend (only on system if 'force' == true).
-- Can be filtered by computerType by passing an array of 'model.computerTypes'
function computerRepository.listComputers(computerTypes, force)
    local cachePath = 'computer/list-' .. (computerTypes or 'all') .. '.json'
    local cachedList = cacheAPI.fromCache(cachePath)

    if force then
        cacheAPI.deleteFromCache(cachePath)
    elseif cachedList then
        print('Computers found on cache')
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

    local options = httpAPI.getDefaultOptions()
        .onFailure(function(_, _) print('Error searching for computer list') end)
        .onSuccess(function(response) cacheAPI.saveToCache(cachePath, response, nil, true) end)
    return httpAPI.get(url, options)
end

-- Registers computer on backend
function computerRepository.registerComputer(computer)
    local options = httpAPI.getDefaultOptions()
        .onFailure(function(_, _) print('Error registering computer') end)
    local _, success = httpAPI.post('/computer/register', computer, options)

    return success and computerRepository.findComputer() or nil
end

-- Updates computer on backend
function computerRepository.updateComputer(computer)
    local options = httpAPI.getDefaultOptions()
        .onFailure(function(_, _) print('Error updating computer') end)
    return httpAPI.post('/computer/update', computer, options)
end

return computerRepository
