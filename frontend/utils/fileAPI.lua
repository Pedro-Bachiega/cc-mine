local fileAPI = {}

function fileAPI.appendToFile(fileName, content)
    local mode = 'a'
    if not fs.exists(fileName) then mode = 'w' end

    local file = fs.open(fileName, mode)
    file.write(mode == 'a' and ('\n' .. content) or content)
    file.close()
end

function fileAPI.deleteFile(fileName)
    if fs.exists(fileName) then fs.delete(fileName) end
end

function fileAPI.fromFile(fileName)
    if not fs.exists(fileName) then return nil end

    local file = fs.open(fileName, 'r')
    local content = file.readAll()
    file.close()
    return content
end

function fileAPI.saveToFile(fileName, content, force)
    if force then
        fileAPI.deleteFile(fileName)
    elseif not force and fs.exists(fileName) then
        return false
    end

    local file = fs.open(fileName, 'w')
    file.write(content)
    file.close()

    return true
end

return fileAPI
