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

    -- State - Line 4
    monitor:writeFarmState(infoTable.state, minX, 4)

    -- Didivder - Line 5
    monitor:drawDivider(maxX, 1, 5)

    -- Drops - Line 7+
    if infoTable.content ~= nil then
        local cursorY = 7

        local function writeDrops(dropTable)
            local y = cursorY
            for index, drop in ipairs(dropTable) do
                y = y + 1
                monitor:writeFarmContents('', drop, colors.lime, minX + 2, y)
            end
            return y
        end

        if infoTable.content.fluid ~= nil then
            monitor:writeFarmContents('Fluids: ', '', colors.lime, minX, cursorY)
            cursorY = writeDrops(infoTable.content.fluid)
        end

        if infoTable.content.solid ~= nil then
            cursorY = cursorY + 1
            monitor:writeFarmContents('Solids: ', '', colors.lime, minX, cursorY)
            cursorY = writeDrops(infoTable.content.solid)
        end
    end


    -- Didivder - Penultimate Line
    monitor:drawDivider(maxX, 1, maxY - 2)

    -- Channel - Last Line
    monitor:writeFarmChannel(minX, maxY - 1)
end
