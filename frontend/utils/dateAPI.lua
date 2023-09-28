local dateAPI = {}

function dateAPI.addSeconds(timestampTable, seconds)
    if not seconds or seconds == 0 then return timestampTable end

    local minutesToAdd = 0

    timestampTable.sec = timestampTable.sec + seconds
    if timestampTable.sec >= 60 then
        minutesToAdd = timestampTable.sec / 60
        timestampTable.sec = timestampTable.sec % 60
    end

    return dateAPI.addMinutes(timestampTable, minutesToAdd)
end

function dateAPI.addMinutes(timestampTable, minutes)
    if not minutes or minutes == 0 then return timestampTable end

    local hoursToAdd = 0

    timestampTable.min = timestampTable.min + minutes
    if timestampTable.min >= 60 then
        hoursToAdd = timestampTable.min / 60
        timestampTable.min = timestampTable.min % 60
    end

    return dateAPI.addHours(timestampTable, hoursToAdd)
end

function dateAPI.addHours(timestampTable, hours)
    if not hours or hours == 0 then return timestampTable end

    local daysToAdd = 0

    timestampTable.hour = timestampTable.hour + hours
    if timestampTable.hour >= 24 then
        daysToAdd = timestampTable.hour / 24
        timestampTable.hour = timestampTable.hour % 24
    end

    return dateAPI.addDays(timestampTable, daysToAdd)
end

function dateAPI.addDays(timestampTable, days)
    if not days or days == 0 then return timestampTable end

    timestampTable.day = timestampTable.day + days
    return timestampTable
end

function dateAPI.getTimestampTable()
    ---@diagnostic disable-next-line: undefined-global
    return os.date("*t", timestamp) or os.date("%format", timestamp)
end

function dateAPI.getDateTime(pretty, fromTimestamp)
    local table = fromTimestamp or dateAPI.getTimestampTable()
    if pretty then
        return string.format(
            '%02d:%02d - %d/%d/%d',
            table.hour,
            table.min,
            table.day,
            table.month,
            table.year
        )
    else
        return string.format(
            '%d-%d-%d\'T\'%02d:%02d:%02d',
            table.year,
            table.month,
            table.day,
            table.hour,
            table.min
        )
    end
end

function dateAPI.getDate(pretty, fromTimestamp)
    local table = fromTimestamp or dateAPI.getTimestampTable()
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

function dateAPI.getTime(fromTimestamp)
    local table = fromTimestamp or dateAPI.getTimestampTable()
    return string.format(
        '%02d:%02d',
        table.hour,
        table.min
    )
end

return dateAPI
