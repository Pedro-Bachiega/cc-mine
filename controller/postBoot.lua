local computerType = require('api.computer.computerAPI').findComputerType()
shell.run('controller/' .. computerType .. '/postBoot.lua')

return