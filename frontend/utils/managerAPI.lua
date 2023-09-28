local modemAPI = require('modemAPI')

local managerAPI = {}

function managerAPI.clearAllCaches()
    modemAPI.broadcastMessage({method = 'GET', url = '/cache/clear'})
end

return managerAPI
