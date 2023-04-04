os.loadAPI('functionAPI.lua')

function insert(channel, content)
    if not fs.exists('data') then fs.makeDir('data') end
    functionAPI.toFile('data/' .. channel .. '.lua', content)
end

function find(channel)
    if not fs.exists('data') or not fs.exists('data/' .. channel .. '.lua') then return nil end
    return functionAPI.fromFile('data/' .. channel .. '.lua')
end
