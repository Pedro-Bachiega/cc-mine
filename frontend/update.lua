local computerAPI = require('api.computer.computerAPI')

-- Refresh computer information
computerAPI.findComputer(nil, true)

-- Clean old files
for _, v in pairs(fs.list('.')) do
    if not ('rom,update'):find(v) then fs.delete(v) end
end

-- Update
shell.run('pastebin', 'run', 'sEGM5iaW')
