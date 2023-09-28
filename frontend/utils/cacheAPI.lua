local dateAPI = require('dateAPI')
local fileAPI = require('fileAPI')
local jsonAPI = require('jsonAPI')

local cacheAPI = {}

local function createCacheFile(content, secondsToInvalidate)
    if not secondsToInvalidate then
        secondsToInvalidate = 24 * 60 * 60
    end

    local result = {
        content = content,
        invalidateAt = secondsToInvalidate == 0 and 0 or dateAPI.getTimeEpoch() + secondsToInvalidate
    }
    return jsonAPI.toJson(result)
end

function cacheAPI.clear()
    fileAPI.deleteFile('cache')
end

function cacheAPI.deleteFromCache(path)
    fileAPI.deleteFile('cache/' .. path)
end

function cacheAPI.fromCache(path, deleteAfter)
    local cachePath = 'cache/' .. path
    local file = jsonAPI.fromJsonFile(cachePath)
    if not file then return nil end

    if file.invalidateAt > 0 and dateAPI.getTimeEpoch() > file.invalidateAt then
        cacheAPI.deleteFromCache(path)
        return nil
    end

    if deleteAfter then cacheAPI.deleteFromCache(cachePath) end

    return file.content
end

function cacheAPI.saveToCache(path, content, secondsToInvalidate, force)
    if not fs.exists('cache') then fs.makeDir('cache') end

    local jsonString = createCacheFile(content, secondsToInvalidate)
    return fileAPI.saveToFile('cache/' .. path, jsonString, force)
end

return cacheAPI
