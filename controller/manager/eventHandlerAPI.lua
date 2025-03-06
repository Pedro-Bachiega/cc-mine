if pocket then return end

local eventHandlerAPI = {}

-- Occurs before any default event handling
function eventHandlerAPI.handlePre(_, _)
    return false
end

-- Occurs after any default event handling
function eventHandlerAPI.handlePost(_, _)
    return false
end

return eventHandlerAPI
