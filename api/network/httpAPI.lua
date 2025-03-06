local fileAPI = require('api.util.fileAPI')
local jsonAPI = require('api.util.jsonAPI')

local defaultTimeoutSeconds = 15
local maxRetriesDefault = 5

local baseApiUrl = 'https://baseurl.com'

local RequestStatus = {
    LOADING = 0,
    SUCCESS = 1,
    ERROR = 2,
    RETRY = 3,
}

---------------- Processing ----------------

-- Executes a request with set timeout and retry count
local function performRequest(method, url, body, options)
    local response, statusCode = nil, nil
    local requestUrl = baseApiUrl .. url
    local serializedBody = body and jsonAPI.toJson(body) or nil

    local requestStatus = RequestStatus.LOADING

    print('---------------------')
    print('[HTTP]\nMethod: ' .. method .. '\nUrl: ' .. requestUrl)
    if body then print('Body:\n' .. serializedBody) end

    local retryCount = 0
    while (retryCount < options.maxRetries) do
        local httpConfig = {
            url = requestUrl,
            method = method,
            headers = { ['Content-Type'] = 'application/json' },
            timeout = options.timeout
        }

        local connection = nil
        if ('PATCH,POST,PUT'):find(method) then
            httpConfig.body = serializedBody
            connection = http.post(httpConfig)
        else
            connection = http.get(httpConfig)
        end
        response = connection.readAll()
        statusCode = connection.getResponseCode()
        connection.close()

        print('[HTTP]\nResponse code: ' .. statusCode .. '\nBody:\n' .. jsonAPI.prettifyJson(response))

        if statusCode >= 200 and statusCode <= 204 then
            requestStatus = RequestStatus.SUCCESS
            if options.onSuccess then options.onSuccess(response) end
            break
        end

        print('Retrying in 5 seconds')
        requestStatus = RequestStatus.RETRY
        sleep(5)
    end

    if response then response = jsonAPI.fromJson(response) end

    if requestStatus ~= RequestStatus.SUCCESS then
        requestStatus = RequestStatus.ERROR
        if options.onFailure then options.onFailure(response, statusCode) end
    end

    print('---------------------')
    return response, requestStatus == RequestStatus.SUCCESS
end

---------------- Public ----------------

-- Default options for a request
local defaultOptions = {
    timeout = defaultTimeoutSeconds,
    maxRetries = maxRetriesDefault,
    onSuccess = nil,
    onFailure = nil,
}

-- Change request timeout
function defaultOptions.timeout(seconds)
    defaultOptions.timeout = seconds
    return defaultOptions
end

-- Change request max retries
function defaultOptions.maxRetries(retries)
    defaultOptions.maxRetries = retries
    return defaultOptions
end

-- Change request success callback
function defaultOptions.onSuccess(callback)
    defaultOptions.onSuccess = callback
    return defaultOptions
end

-- Change request failure callback
function defaultOptions.onFailure(callback)
    defaultOptions.onFailure = callback
    return defaultOptions
end

-- Where all requests are made
local httpAPI = {}

-- Creates default options
function httpAPI.getDefaultOptions()
    return defaultOptions
end

-- Executes a DELETE request
function httpAPI.delete(url, options)
    return performRequest('DELETE', url, options or httpAPI.getDefaultOptions())
end

-- Executes a GET request
function httpAPI.get(url, options)
    return performRequest('GET', url, options or httpAPI.getDefaultOptions())
end

-- Executes a POST request
function httpAPI.post(url, body, options)
    return performRequest('POST', url, body, options or httpAPI.getDefaultOptions())
end

-- Downloads a file from given url
function httpAPI.download(url, fileName)
    print('Downloading file:\n' .. fileName .. '\n')
    local code, response = httpAPI.get(url)
    if code == 200 and response then
        fileAPI.saveToFile(fileName, response, true)
        print('Downloaded file:\n' .. fileName .. '\n')
    else
        print('Error downloading file from url:\n' .. url .. '\n')
    end
end

return httpAPI
