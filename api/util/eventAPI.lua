local eventAPI = {}

function eventAPI.waitForEvent(eventName)
    ---@diagnostic disable-next-line: undefined-field
    local event, param1, param2, param3, param4, param5 = os.pullEvent(eventName)
    return {
        event = event,
        param1 = param1,
        param2 = param2,
        param3 = param3,
        param4 = param4,
        param5 = param5
    }
end

return eventAPI
