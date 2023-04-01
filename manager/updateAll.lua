os.loadAPI('channels.lua')
os.loadAPI('constants.lua')
os.loadAPI('functions.lua')

for k, value in pairs(channels.ALL) do
    print('Updating ' .. value.name)
    functions.sendMessage(value.channel, constants.CHANNEL, 'update')
    sleep(0.2)
end

shell.run('update.lua')
