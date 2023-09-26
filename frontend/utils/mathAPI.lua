function ceil(number, maximum)
    local result = math.ceil(number)
    if not maximum then return result end
    return result > maximum and maximum or result
end

function floor(number, minimum)
    local result = math.floor(number)
    if not minimum then return result end
    return result < minimum and minimum or result
end

function round(number, minimum)
    return floor(number + 0.5)
end
