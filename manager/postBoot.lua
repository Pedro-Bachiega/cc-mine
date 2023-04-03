if not fs.exists('channels.lua') then
    shell.run('importChannels.lua')
end

if pocket then return end

sleep(2)
local id = multishell.launch({}, 'manager.lua')
multishell.setTitle(id, 'Managing')
