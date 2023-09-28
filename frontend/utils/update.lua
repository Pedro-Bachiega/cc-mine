local computerAPI = require('computerAPI')
local fileAPI = require('fileAPI')

-- Refresh computer information
computerAPI.findComputer(true)

-- Delete previous files
fileAPI.deleteFile('cc-mine')

-- Update
shell.run('gitClone', 'https://github.com/Pedro-Bachiega/cc-mine.git')
fileAPI.moveDir('cc-mine/frontend', 'cc-mine', true, true)
fileAPI.deleteFile('cc-mine/backend')
fileAPI.deleteFile('cc-mine/frontend')
shell.run('cc-mine/utils/install.lua')
