os.loadAPI('channels.lua')
os.loadAPI('constants.lua')
os.loadAPI('functions.lua')

local mapByChannelType = {}

for k, value in pairs(channels.ALL) do
    if not mapByChannelType[value.type] then
        mapByChannelType[value.type] = {}
    end
    table.insert(mapByChannelType[value.type], value)
end

local function update(list)
    for k, value in pairs(list) do
        print('Updating ' .. value.name)
        functions.sendMessage('update', value.channel)
        sleep(0.5)
    end
end

update(mapByChannelType['storage'])
update(mapByChannelType['worker'])
update(mapByChannelType['manager'])

shell.run('update.lua')
