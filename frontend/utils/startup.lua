sleep(os.getComputerId() * 2)

local computerAPI = require('computerAPI')

-- Cache computer information for the given time on every startup
computerAPI.findComputer()

shell.run('postBoot.lua')
shell.run('run.lua')
