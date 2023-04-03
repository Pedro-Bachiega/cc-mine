if not fs.exists('channels.lua') then
    shell.run('importChannels.lua')
end

displayAPI.draw(getLogs())
