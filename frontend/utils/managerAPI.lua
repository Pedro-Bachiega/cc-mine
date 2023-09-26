local modemAPI = require('modemAPI.lua')

function clearAllCaches()
    modemAPI.broadcastMessage({method = 'GET', url = '/cache/clear'})
end
