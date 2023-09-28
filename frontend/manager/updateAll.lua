local modemAPI = require('modemAPI')

modemAPI.broadcastMessage({url = '/systems/update'})
shell.run('update.lua')
