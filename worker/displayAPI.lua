os.loadAPI('functionAPI.lua')
os.loadAPI('uiAPI.lua')

function writeFarmInfo(infoTable)
    monitor = peripheral.wrap(constants.MONITOR_SIDE)

    function monitor:writeFarmType(info, x, y)
        x = uiAPI.drawAt(self, 'Farm type: ', x, y, colors.purple)
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
    
    function monitor:writeFarmChannel(x, y)
        x = uiAPI.drawAt(self, 'Channel: ', x, y, colors.white)
        uiAPI.drawAt(self, tostring(constants.CHANNEL), x, y, colors.blue)
    end
    
    function monitor:writeTimestamp(x, y)
        local text = 'Updated at: ' .. functionAPI.getDateTime()
        uiAPI.drawAt(self, text, x, y, colors.lightGray)
    end

    function monitor:drawDivider(y)
        uiAPI.drawHorizontalDividerAt(self, y)
    end

    local maxX, maxY = monitor.getSize()
    local minX = 2
    local minY = 2

    monitor.clear()

    -- Farm Type - Line 2
    monitor:writeFarmType(infoTable.farmType, minX, minY)

    -- State - Line 3
    monitor:writeFarmState(infoTable.state, minX, 3)

    -- Didider - Line 4
    monitor:drawDivider(4)

    -- Drops - Line 6+
    if infoTable.content  then
        local cursorY = 6

        local function writeDrops(dropTable)
            local y = cursorY
            for index, drop in ipairs(dropTable) do
                y = y + 1
                monitor:writeFarmContents('', drop, colors.lime, minX + 2, y)
            end
            return y
        end

        if infoTable.content.fluid then
            monitor:writeFarmContents('Fluids: ', '', colors.lime, minX, cursorY)
            cursorY = writeDrops(infoTable.content.fluid)
        end

        if infoTable.content.solid then
            cursorY = cursorY + 1
            monitor:writeFarmContents('Solids: ', '', colors.lime, minX, cursorY)
            cursorY = writeDrops(infoTable.content.solid)
        end
    end


    -- Didider
    monitor:drawDivider(maxY - 3)

    -- Channel and Time - Last Line
    monitor:writeFarmChannel(minX, maxY - 2)
    monitor:writeTimestamp(minX, maxY - 1)
end
