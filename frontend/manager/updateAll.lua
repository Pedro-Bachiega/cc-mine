local modemAPI = require('modemAPI.lua')

modemAPI.broadcastMessage({method = 'GET', url = '/computer/update'})
shell.run('update.lua')
