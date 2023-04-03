if not fs.exists('channels.lua') then
    shell.run('importChannels')
end
