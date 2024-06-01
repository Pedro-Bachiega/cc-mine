local repositoryAPI = {}

-- Builds request object and returns it
function repositoryAPI.buildRequest(url, params)
    return { url = url, params = params }
end

return repositoryAPI
