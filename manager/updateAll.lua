os.loadAPI('channels.lua')
os.loadAPI('functions.lua')

local modem = functions.openModem()
for k, v in pairs(channels.ALL) do
    print('Updating channel ' .. v)
    modem.transmit(v, constant.CHANNEL, 'update')
    sleep(1)
end

shell.run('update.lua')
