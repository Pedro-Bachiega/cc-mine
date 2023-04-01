os.loadAPI('functions.lua')

function writeFarmInfo(infoTable)
    monitor = peripheral.wrap(constants.MONITOR_SIDE)

    function monitor:writeFarmType(info, x, y)
        self.setCursorPos(x, y)
        self.setTextColor(colors.purple)
        self.write('Farm type: ')
        self.setTextColor(colors.yellow)
        self.write(info)
    end
    
    function monitor:writeFarmState(state, x, y)
        self.setCursorPos(x, y)
        self.setTextColor(colors.white)
        self.write('State: ')
        self.setTextColor(state and colors.green or colors.red)
        self.write(state and 'ON' or 'OFF')
    end

    function monitor:writeFarmContents(label, contents, infoColor, x, y)
        self.setCursorPos(x, y)
        self.setTextColor(colors.white)
        self.write(label)
        self.setTextColor(infoColor)
        self.write(contents)
    end
    
    function monitor:writeFarmChannel(x, y)
        self.setCursorPos(x, y)
        self.setTextColor(colors.white)
        self.write('Channel: ')
        self.setTextColor(colors.blue)
        self.write(tostring(constants.CHANNEL))
    end
    
    function monitor:writeTimestamp(x, y)
        local text = 'Updated at: ' .. functions.getTimestamp()
        self.setCursorPos(x, y)
        self.setTextColor(colors.lightGray)
        self.write(text)
    end

    function monitor:drawDivider(size, x, y)
        self.setCursorPos(x, y)
        self.setTextColor(colors.white)
        self.write(string.rep('-', size))
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
    monitor:drawDivider(maxX, 1, 4)

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
    monitor:drawDivider(maxX, 1, maxY - 3)

    -- Channel and Time - Last Line
    monitor:writeFarmChannel(minX, maxY - 2)
    monitor:writeTimestamp(minX, maxY - 1)
end
