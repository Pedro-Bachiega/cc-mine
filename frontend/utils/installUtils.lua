local fileAPI = require('fileAPI')
local utilDir = 'cc-mine/utils/'

fileAPI.deleteFiles(fs.list(utilDir))
fileAPI.copyFiles(utilDir)

local installContent = "shell.run('installContent.lua')"
fileAPI.saveToFile('install.lua', installContent, true)

---@diagnostic disable-next-line: undefined-field
os.reboot()
