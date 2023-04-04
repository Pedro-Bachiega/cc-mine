os.loadAPI('functionAPI.lua')

local args = {...}
local info = {}

local function splitIntoTable(line)
    local result = {}
    for item in string.gmatch(line, "[^,]+") do
        table.insert(result, item)
    end
    return result
end

for i, v in ipairs(args) do
    if v == '-c' then
        info.channel = tonumber(args[i + 1])
    elseif v == '-f' then
        if not info.content then info.content = {} end
        info.content.fluid = splitIntoTable(args[i + 1])
    elseif  v == '-s' then
        if not info.content then info.content = {} end
        info.content.solid = splitIntoTable(args[i + 1])
    end
end

local channelValue = info.channel
if not channelValue then
    print('Channel: ')
    channelValue = tonumber(read())
end

if not info.channel then
    info.channel = channelValue
end

functionAPI.setFarmInfo(info)
