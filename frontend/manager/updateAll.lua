local modemAPI = require('modemAPI')

modemAPI.broadcastMessage({method = 'GET', url = '/computer/update'})
shell.run('update.lua')
