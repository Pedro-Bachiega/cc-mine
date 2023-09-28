local jsonAPI = require('jsonAPI')

local repositoryAPI = {}

-- Builds request object and returns its json string
function repositoryAPI.buildRequest(url, params)
    return jsonAPI.toJson({ ['url'] = url, ['params'] = params })
end

return repositoryAPI
