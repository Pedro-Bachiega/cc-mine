function argsToKnownTable(args)
    local computerType = nil
    local skipConstants = false

    for index, value in ipairs(args) do
        if value == '-t' or value == '--type' then
            computerType = args[index + 1]
        elseif value == '-s' or value == '--silent' then
            skipConstants = true
        end
    end

    return {
        computerType = computerType,
        skipConstants = skipConstants
    }
end
