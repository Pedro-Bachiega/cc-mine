os.loadAPI('functions.lua')

function insert(id, content)
    if not fs.exists('data') then fs.makeDir('data') end
    functions.toFile('data/' .. id .. '.lua', content)
end

function find(id)
    if not fs.exists('data') or not fs.exists('data/' .. id .. '.lua') then return nil end
    return functions.fromFile('data/' .. id .. '.lua')
end
