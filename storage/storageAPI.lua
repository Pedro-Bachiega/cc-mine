os.loadAPI('functionAPI.lua')

function insert(id, content)
    if not fs.exists('data') then fs.makeDir('data') end
    functionAPI.toFile('data/' .. id .. '.lua', content)
end

function find(id)
    if not fs.exists('data') or not fs.exists('data/' .. id .. '.lua') then return nil end
    return functionAPI.fromFile('data/' .. id .. '.lua')
end
