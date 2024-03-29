local functionAPI = require('functionAPI')
local peripheralAPI = require('peripheralAPI')
local uiAPI = require('uiAPI')

local displayAPI = {}

function displayAPI.writeFarmInfo(computerInfo)
    local monitor = peripheralAPI.requirePeripheral('monitor')

    function monitor:writeFarmName(info, x, y)
        x = uiAPI.drawAt(self, 'Farm name: ', x, y, colors.purple)
        uiAPI.drawAt(self, info, x, y, colors.yellow)
    end
    
    function monitor:writeFarmState(state, x, y)
        x = uiAPI.drawAt(self, 'State: ', x, y, colors.white)
        uiAPI.drawAt(
            self,
            state and 'ON' or 'OFF',
            x,
            y,
            state and colors.green or colors.red
        )
    end

    function monitor:writeFarmContents(label, contents, infoColor, x, y)
        x = uiAPI.drawAt(self, label, x, y, colors.white)
        uiAPI.drawAt(self, contents, x, y, infoColor)
    end
    
    function monitor:writeFarmId(x, y)
        x = uiAPI.drawAt(self, 'Id: ', x, y, colors.white)
        uiAPI.drawAt(self, tostring(computerInfo.id), x, y, colors.blue)
    end
    
    function monitor:writeTimestamp(x, y)
        local text = 'Updated at: ' .. functionAPI.getDateTime(true)
        uiAPI.drawAt(self, text, x, y, colors.lightGray)
    end

    function monitor:drawDivider(y)
        uiAPI.drawHorizontalDividerAt(self, y)
    end

    local _, maxY = monitor.getSize()
    local minX = 2
    local minY = 2

    monitor.clear()

    -- Farm Type - Line 2
    monitor:writeFarmName(computerInfo.name, minX, minY)

    -- State - Line 3
    monitor:writeFarmState(computerInfo.data.state, minX, 3)

    -- Divider - Line 4
    monitor:drawDivider(4)

    -- Drops - Line 6+
    if computerInfo.data.content  then
        local cursorY = 6

        local function writeDrops(dropTable)
            local y = cursorY
            for _, drop in ipairs(dropTable) do
                y = y + 1
                monitor:writeFarmContents('', drop, colors.lime, minX + 2, y)
            end
            return y
        end

        if computerInfo.data.content.fluid then
            monitor:writeFarmContents('Fluids: ', '', colors.lime, minX, cursorY)
            cursorY = writeDrops(computerInfo.data.content.fluid)
        end

        if computerInfo.data.content.solid then
            cursorY = cursorY + 1
            monitor:writeFarmContents('Solids: ', '', colors.lime, minX, cursorY)
            cursorY = writeDrops(computerInfo.data.content.solid)
        end
    end


    -- Divider
    monitor:drawDivider(maxY - 3)

    -- Id and Time - Last Line
    monitor:writeFarmId(minX, maxY - 2)
    monitor:writeTimestamp(minX, maxY - 1)
end

return displayAPI
