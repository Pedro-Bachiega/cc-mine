local jsonAPI = require('jsonAPI')

local repositoryAPI = {}

-- Builds request object and returns its json string
function repositoryAPI.buildRequest(url, args)
    return jsonAPI.toJson({ url = url, args = args })
end

return repositoryAPI
