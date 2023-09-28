---@diagnostic disable-next-line: undefined-field
--sleep(os.getComputerID() * 2)

if fs.exists('install.lua') then
    shell.run('install.lua')
    return
end

local computerAPI = require('computerAPI')
local fileAPI = require('fileAPI')

fileAPI.deleteFile('cc-mine')
fileAPI.deleteFile('installContent.lua')
fileAPI.deleteFile('installNetwork.lua')
fileAPI.deleteFile('installUtils.lua')

-- Cache computer information for the given time on every startup
computerAPI.findComputer()

shell.run('postBoot.lua')
shell.run('run.lua')
