os.loadAPI('buttonAPI.lua')
os.loadAPI('functionAPI.lua')
os.loadAPI('managerAPI.lua')
os.loadAPI('uiAPI.lua')

local monitor = peripheral.wrap(constants.MONITOR_SIDE)

local function getCachedFarmInfo(channel)
    return functionAPI.getFromCache('farmInfo', channel)
end

local function saveFarmInfo(channel, response)
    return functionAPI.cacheResponse('farmInfo', channel, response)
end

local function getFarmInfo(channel, skipCache)
    local info = nil
    if not skipCache then info = getCachedFarmInfo(channel) end
    if not info then info = functionAPI.requestFarmInfo(channel) end
    return info
end

local function toggleFarmState(channel)
    local farmInfo = getFarmInfo(channel)

    if farmInfo.error then
        print('Operation cancelled. ' .. farmInfo.message)
        return nil
    else
        farmInfo.state = not farmInfo.state

        local content = {command = 'insert', body = farmInfo}

        local request = functionAPI.toJson(content)
        print(request)
        local response = functionAPI.sendMessageAndWaitResponse(request, constants.CHANNEL_STORAGE)
        if not response.error then saveFarmInfo(channel, response.message) end
        return response
    end
end

local function getButtonColor(state)
    return state and colors.green or colors.red
end

local function onButtonClick(buttonClicked)
    return function()
        local args = buttonClicked.args
        if args.state then args.state = not args.state end

        local farmInfo = toggleFarmState(args.channel.channel)

        if not farmInfo then
            buttonClicked.blink(colors.lightGray)
            return
        end

        logAPI.log('Toggling state on channel ' .. args.channel.name)
        buttonClicked.args.state = farmInfo.state
        buttonClicked.setColor(getButtonColor(farmInfo.state)).draw()
    end
end

local function getMargin(usableHeight)
    local buttonHeight = 3
    local buttonQuantity = functionAPI.floor(usableHeight / buttonHeight)
    local availableSpace = usableHeight - (buttonQuantity * buttonHeight)
    local result = functionAPI.round(availableSpace / (buttonQuantity - 1))
    return result > 1 and result or 1
end

local function createButtons(monitor, initialX, initialY, finalY, monWidth, monHeight)
    local buttonTable = {}
    local workers = channelAPI.listWorkerChannels()
    table.sort(workers, function(w1, w2) return w1.channel < w2.channel end)

    local x = initialX
    local y = initialY
    local padding = 2
    local maxWidth = 0
    local margin = getMargin(finalY - initialY - padding)

    for key, value in pairs(workers) do
        if maxWidth < #value.name then maxWidth = #value.name end
    end

    for key, value in pairs(workers) do
        local farmInfo = getCachedFarmInfo(value.channel) or {}

        local newButton = buttonAPI.create(value.name)
            .setHorizontalPadding(padding)
            .setVerticalPadding(padding)
            .setAlignment('left')
            .setPos(x, y)
            .setArgs({
                state = farmInfo.state or false,
                channel = value
            })

        newButton.setSize(maxWidth, newButton.height)
            .setColor(getButtonColor(newButton.args.state))

        local atEnd = (newButton.x + newButton.getWidth()) >= monWidth
        if atEnd then
            x = initialX
            y = y + newButton.getHeight() + margin
        end

        newButton.onClick(onButtonClick(newButton))
            .setPos(x, y)

        buttonTable[#buttonTable + 1] = newButton

        x = x + maxWidth + padding + 1
    end

    return buttonTable
end

managerAPI.clearCache()

while true do
    monitor.clear()
    local monWidth, monHeight = monitor.getSize()
    local initialX = 2
    local initialY = uiAPI.drawHeader(monitor, 'Farms: ')
    local finalY = uiAPI.drawTimestampFooter(monitor)
    local buttons = createButtons(monitor, initialX, initialY, finalY, monWidth, monHeight)
    buttonAPI.await(buttons)
end
