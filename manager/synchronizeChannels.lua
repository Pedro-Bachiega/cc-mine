if not fs.exists('channels.lua') then error('You don\'t have a channels file') end

os.loadAPI('channels.lua')
os.loadAPI('functions.lua')

local content = functions.fromFile('channels.lua')
local request = functions.toJson({
    command = 'synchronizeChannels',
    body = content
})

for k, value in pairs(channels.ALL) do
    if value.type == 'manager' then
        print('Updating ' .. value.name)
        functions.sendMessage(request, value.channel)
    end
end
