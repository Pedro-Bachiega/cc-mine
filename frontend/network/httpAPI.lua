local fileAPI = require('fileAPI')
local jsonAPI = require('jsonAPI')

local defaultTimeoutSeconds = 15
local maxRetriesDefault = 5

local baseApiUrl = 'https://southamerica-east1-mine-cc-dev.cloudfunctions.net'

---------------- Processing ----------------

-- Executes a request with set timeout and retry count
local function performRequest(method, url, body, timeout, maxRetries)
    local response, statusCode
    local requestUrl = baseApiUrl .. url
    local serializedBody = body and jsonAPI.toJson(body) or nil

    print('[HTTP] - Synchronous\nMethod: ' .. method .. '\nUrl: ' .. requestUrl)
    if body then print('Body:\n' .. serializedBody) end

    local retryCount = 0
    while (retryCount < (maxRetries or maxRetriesDefault)) do
        local httpConfig = {
            url = requestUrl,
            method = method,
            headers = { ['Content-Type'] = 'application/json' },
            timeout = timeout or defaultTimeoutSeconds
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

        if statusCode >= 200 and statusCode < 300 then break end

        print('Retrying in 5 seconds')
        sleep(5)
    end

    if response then return statusCode, jsonAPI.fromJson(response) end
    return statusCode
end

---------------- Public ----------------

-- Where all requests are made
local httpAPI = {}

-- Executes a DELETE request
function httpAPI.delete(url)
    return performRequest('DELETE', url)
end

-- Executes a GET request
function httpAPI.get(url)
    return performRequest('GET', url)
end

-- Executes a POST request
function httpAPI.post(url, request)
    return performRequest('POST', url, request)
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
