local computerAPI = require('computerAPI')
local fileAPI = require('fileAPI')

-- Refresh computer information
computerAPI.findComputer(true)

-- Delete previous files
fileAPI.deleteFile('cc-mine')

-- Update
shell.run('pastebin', 'run', 'sEGM5iaW')
