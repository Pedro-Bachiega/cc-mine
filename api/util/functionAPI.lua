local functionAPI = {}

---------------- Public functions ----------------

function functionAPI.arrayContains(array, element)
    for _, value in ipairs(array) do
        if value == element then return true end
    end
    return false
end

function functionAPI.tableToKeyArray(table)
    local array = {}
    for key, _ in pairs(table) do array[#array+1] = key end
    return array
end

function functionAPI.tableToValueArray(table)
    local array = {}
    for _, value in pairs(table) do array[#array+1] = value end
    return array
end

function functionAPI.isTable(element)
    return type(element) == "table"
end

function functionAPI.runWithRetries(maxRetries, executionBlock)
    local result = nil
    local currentRetry = 0
    local defaultMaxRetries = 30
    local currentMaxRetries = maxRetries or defaultMaxRetries

    while not result and currentRetry < currentMaxRetries do
        if currentRetry > 0 then print('Retrying: ' .. currentRetry) end

        result = executionBlock()
        currentRetry = currentRetry + 1
    end

    if not result then
        print('Could not get result after ' .. currentRetry .. ' tries')
    end

    return result
end

function functionAPI.runWithTimeout(timeoutSeconds, executionBlock)
    local function waitTimeout()
        sleep(timeoutSeconds)
        print('Timeout reached')
        error('Timeout reached')
    end

    return pcall(parallel.waitForAny(waitTimeout, executionBlock))
end

return functionAPI
