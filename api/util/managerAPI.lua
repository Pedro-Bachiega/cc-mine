local modemAPI = require('api.util.modemAPI')

local managerAPI = {}

function managerAPI.clearAllCaches()
    modemAPI.broadcastMessage({method = 'DELETE', url = '/cache'})
end

return managerAPI
