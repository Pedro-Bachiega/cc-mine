function arrayContains(array, element)
    for index, value in ipairs(array) do
        if value == element then return true end
    end
    return false
end

local function getTimestampTable()
    return os.date("*t", timestamp) or os.date("%format", timestamp)
end

function getDateTime()
    local table = getTimestampTable()
    return string.format(
        '%02d:%02d - %d/%d/%d',
        table.hour,
        table.min,
        table.day,
        table.month,
        table.year
    )
end

function getDate(pretty)
    local table = getTimestampTable()
    if pretty then
        return string.format(
            '%d/%d/%d',
            table.day,
            table.month,
            table.year
        )
    else
        return string.format(
            '%d-%d-%d',
            table.year,
            table.month,
            table.day
        )
    end
end

function getTime()
    local table = getTimestampTable()
    return string.format(
        '%02d:%02d',
        table.hour,
        table.min
    )
end

function isTable(element)
	return type(element) == "table"
end
