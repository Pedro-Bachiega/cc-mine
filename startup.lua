if fs.exists('install.lua') then
    shell.run('install.lua')
    return
end

shell.run('controller/postBoot.lua')
shell.run('controller/main.lua')
