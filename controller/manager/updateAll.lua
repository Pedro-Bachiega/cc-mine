local modemAPI = require('api.util.modemAPI')

modemAPI.broadcastMessage({url = '/systems/update'})
shell.run('update.lua')
