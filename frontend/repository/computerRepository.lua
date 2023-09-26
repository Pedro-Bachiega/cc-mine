local cacheAPI = require('cacheAPI.lua')
local jsonAPI = require('jsonAPI.lua')
local httpAPI = require('httpAPI.lua')

local baseApiUrl = httpAPI.baseApiUrl .. '/computer'
local cachePath = 'computer/information.lua'

function deleteComputer()
    local statusCode, response = httpAPI.delete(baseApiUrl .. '/' .. os.getComputerId())
    if statusCode == 200 then
        print('Computer deleted')
    else
        print('Error searching for computer')
    end
end

function findComputer(force)
    if fs.exists(cachePath) then
        if force then
            cacheAPI.deleteFromCache(cachePath)
        else
            return cacheAPI.fromCache(cachePath)
        end
    end

    local statusCode, response = httpAPI.get(baseApiUrl .. '/' .. os.getComputerId())
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

function listComputers(computerTypes, force)
    if fs.exists(cachePath) then
        if force then
            cacheAPI.deleteFromCache(cachePath)
        else
            return cacheAPI.fromCache(cachePath)
        end
    end

    local url = baseApiUrl .. '/list'
    if computerTypes then
        local typesQueryParam = '?computerTypes='

        for index, computerType in ipairs(typesQueryParam) do
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

function registerComputer(request)
    local statusCode, response = httpAPI.post(baseApiUrl .. '/register', request)
    if statusCode == 200 then
        print('Computer registered')
        cacheAPI.saveToCache(cachePath, response, true, true)
        return response
    else
        print('Error registering computer')
    end

    return nil
end