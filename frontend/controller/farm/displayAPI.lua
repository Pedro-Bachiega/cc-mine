local functionAPI = require('api.util.functionAPI')
local monitorAPI = require('api.ui.monitorAPI')
local peripheralAPI = require('api.util.peripheralAPI')

local displayAPI = {}

function displayAPI.writeFarmInfo(farmInfo)
    local this = {}

    function this:writeName(farmName)
        monitorAPI.printAt('Farm Name: ' .. farmName, 1, 1, colors.purple)
            .print(farmName, colors.yellow)
            .nextLine()
    end

    function this:writeState(state)
        monitorAPI.print('State: ')
            .print(state and 'ON' or 'OFF', state and colors.green or colors.red)
            .nextLine()
    end

    function this:writeContent(label, content, infoColor)
        if label then
            monitorAPI.printLine(label)
        end

        for _, item in ipairs(content) do
            monitorAPI.printLine('- ' .. item.name, infoColor)
        end
    end

    function this:writeId(y)
        monitorAPI.printAt('Id: ', 1, y)
            .print(tostring(farmInfo.id), colors.blue)
            .nextLine()
    end

    monitorAPI.clear()

    local maxY = monitorAPI.getMaxY()
    monitorAPI.setPadding(1, 1)

    -- Farm Type - Line 1
    this:writeName(farmInfo.name)

    -- State - Line 2
    this:writeState(farmInfo.data.state)

    -- Divider - Line 3
    monitorAPI.drawHorizontalDividerAt(3)

    -- Drops - Line 5+
    monitorAPI.setCursorPos(1, 5)
    if farmInfo.data.content then
        if farmInfo.data.content.fluid then
            this:writeContent('Fluid: ', farmInfo.data.content.fluid, colors.lime)
        end

        if farmInfo.data.content.solid then
            this:writeContent('Solid: ', farmInfo.data.content.solid, colors.lime)
        end
    end


    -- Divider 3 lines above max y
    monitorAPI.drawHorizontalDivider(maxY - 3)

    -- Id and Time - Last 2 lines
    this:writeId(maxY - 2)
    monitorAPI.drawTimestampFooter()
end

return displayAPI
