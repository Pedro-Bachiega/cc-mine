local dateAPI = require('dateAPI')
local fileAPI = require('fileAPI')
local jsonAPI = require('jsonAPI')

local cacheAPI = {}

local function createCacheFile(content, encode, secondsToInvalidate)
    local defaultSecondsToInvalidate = 24 * 60 * 60
    local currentSecondsToInvalidate = secondsToInvalidate or defaultSecondsToInvalidate
    local currentTimestamp = dateAPI.getTimestampTable()
    local cachedAt = dateAPI.getDateTime(false, currentTimestamp)
    local invalidateAt = dateAPI.getDateTime(
        false,
        dateAPI.addSeconds(currentTimestamp, currentSecondsToInvalidate)
    )

    local result = {
        content = encode and jsonAPI.toJson(content) or content,
        cachedAt = cachedAt,
        invalidateAt = invalidateAt
    }
    return jsonAPI.toJson(result)
end

function cacheAPI.clear()
    fileAPI.deleteFile('cache')
end

function cacheAPI.deleteFromCache(path)
    fileAPI.deleteFile('cache/' .. path)
end

function cacheAPI.saveToCache(path, content, encode, secondsToInvalidate, force)
    if not fs.exists('cache') then fs.makeDir('cache') end

    local jsonString = createCacheFile(content, encode, secondsToInvalidate)
    return fileAPI.saveToFile('cache/' .. path, jsonString, force)
end

function cacheAPI.fromCache(path, decode, deleteAfter)
    local cachePath = 'cache/' .. path
    if not fs.exists(cachePath) then return nil end

    local result = decode and jsonAPI.fromJsonFile(cachePath) or fileAPI.fromFile(cachePath)
    if deleteAfter then cacheAPI.deleteFromCache(cachePath) end

    return result
end

return cacheAPI
