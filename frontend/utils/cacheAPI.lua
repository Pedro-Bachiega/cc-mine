local fileAPI = require('fileAPI.lua')
local jsonAPI = require('jsonAPI.lua')

function clear()
    fileAPI.deleteFile('cache')
end

function deleteFromCache(path)
    fileAPI.deleteFile('cache/' .. path)
end

function saveToCache(path, content, encode, force)
    if not fs.exists('cache') then fs.makeDir('cache') end

    local processedContent = encode and jsonAPI.toJson(content) or content
    return fileAPI.saveToFile('cache/%s' .. path, processedContent, force)
end

function fromCache(path, decode)
    local cachePath = 'cache/%s' .. path
    if not fs.exists(cachePath) then return nil end

    local content = fileAPI.fromFile(cachePath)
    return decode and jsonAPI.fromJson(content) or content
end
