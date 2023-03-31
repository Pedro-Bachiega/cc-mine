function insert(id, content)
    if not fs.exists('data') then fs.makeDir('data') end
    local file = fs.open('data/' .. id .. '.lua', 'w')
    file.write(content)
    file.close()
end

function find(id)
    if not fs.exists('data') or not fs.exists('data/' .. id .. '.lua') then return nil end

    local file = fs.open('data/' .. id .. '.lua', 'r')
    local contents = file.readAll()
    file.close()
    return contents
end
