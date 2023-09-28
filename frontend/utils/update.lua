local computerAPI = require('computerAPI')
-- Refresh computer information
computerAPI.findComputer(true)

-- Delete previous files
if fs.exists('cc-mine') then fs.delete('cc-mine') end

-- Update
shell.run('gitClone', 'https://github.com/Pedro-Bachiega/cc-mine.git')
shell.run('cc-mine/utils/install.lua')
