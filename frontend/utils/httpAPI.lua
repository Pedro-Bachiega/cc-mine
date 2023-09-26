local fileAPI = require('fileAPI.lua')
local jsonAPI = require('jsonAPI.lua')

local timeoutSeconds = 15
local maxRetriesDefault = 5
local methodsWithData = {'POST', 'PUT'}

local baseApiUrl = 'https://southamerica-east1-mine-cc-dev.cloudfunctions.net'

---------------- Processing ----------------

local function performAsynchronously(method, url, request, maxRetries) {
    local response, statusCode

    if arrayContains(methodsWithData, method) and request == nil then
        error('Method ' .. method .. ' requires a body')
    end

    print('[HTTP] - Asynchronous\nMethod: ' .. method .. '\nUrl: ' .. url)

    local retryCount = 0
    while (retryCount < (maxRetries or maxRetriesDefault)) do
        local requesting = true
        http.request {
            url = url,
            method = method,
            body = request and jsonAPI.toJson(request) or nil,
            timeout = timeoutSeconds
        }

        repeat
            local event, eventUrl, connection = os.pullEvent()

            if event == "http_success" then
                response = connection.readAll()
                statusCode = connection.getResponseCode()
                connection.close()
                print(response)

                requesting = false
              elseif event == "http_failure" then
                print("Server didn't respond.")
                requesting = false
              end
        until not requesting

        print('[HTTP]\nResponse code: ' .. statusCode .. '\nBody:\n' .. jsonAPI.prettifyJson(response))

        if statusCode >= 200 and < 300 then break end
    end

    if response then return statusCode, jsonAPI.fromJson(response) end
    return statusCode
}

local function performSynchronously(method, url, request, maxRetries) {
    local response, statusCode

    if arrayContains(methodsWithData, method) and request == nil then
        error('Method ' .. method .. ' requires a body')
    end

    print('[HTTP] - Synchronous\nMethod: ' .. method .. '\nUrl: ' .. url)

    local retryCount = 0
    while (retryCount < (maxRetries or maxRetriesDefault)) do
        local connection = nil
        if method == 'POST' then
            connection = http.post(url, jsonAPI.toJson(request))
        elseif method == 'GET' then
            connection = http.get(url)
        else
            error('Method ' .. method .. ' not coded')
        end

        response = connection.readAll()
        statusCode = connection.getResponseCode()
        connection.close()

        print('[HTTP]\nResponse code: ' .. statusCode .. '\nBody:\n' .. jsonAPI.prettifyJson(response))

        if statusCode >= 200 and < 300 then break end
    end

    if response then return statusCode, jsonAPI.fromJson(response) end
    return statusCode
}

---------------- Methods ----------------

function delete(url)
    return performAsynchronously('DELETE', url)
end

function get(url)
    return performSynchronously('GET', url)
end

function post(url, request)
    return performSynchronously('POST', url, request)
end

---------------- Download ----------------

function download(url, fileName)
    print('Downloading file:\n' .. fileName .. '\n')
    local code, response = get(url)
    if code == 200 and response then
        fileAPI.saveToFile(fileName, response, true)
        print('Downloaded file:\n' .. fileName .. '\n')
    else
        print('Error downloading file from url:\n' .. url .. '\n')
    end
end
