-- Required by other scripts
if not computerAPI then os.loadAPI('computerAPI.lua') end

shell.run('postBoot.lua')
shell.run('run.lua')
