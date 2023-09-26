local functionAPI = require('functionAPI.lua')

local args = {...}
local info = { id = os.getComputerId(), content = {} }

local function splitIntoTable(line)
    local result = {}
    for item in string.gmatch(line, "[^,]+") do
        table.insert(result, item)
    end
    return result
end

for i, v in ipairs(args) do
    if v == '-f' then
        info.content.fluid = splitIntoTable(args[i + 1])
    elseif  v == '-s' then
        info.content.solid = splitIntoTable(args[i + 1])
    end
end

functionAPI.setFarmInfo(info)
