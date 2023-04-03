os.loadAPI('buttonAPI.lua')
os.loadAPI('channelAPI.lua')
os.loadAPI('constants.lua')
os.loadAPI('functionAPI.lua')
os.loadAPI('logAPI.lua')
os.loadAPI('managerAPI.lua')
os.loadAPI('uiAPI.lua')

local firstRun = true
local monitor = peripheral.wrap(constants.MONITOR_SIDE)

local function getButtonColor(state)
    return state and colors.green or colors.red
end

local function onButtonClick(buttonClicked)
    return function()
        local args = buttonClicked.args
        if args.state then args.state = not args.state end

        logAPI.log('Toggling state on channel ' .. args.channel.name)
        local farmInfo = functionAPI.toggleFarmState(args.channel.channel)
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

    local x = initialX
    local y = initialY
    local padding = 2
    local maxWidth = 0
    local margin = getMargin(finalY - initialY - padding)

    for key, value in pairs(workers) do
        local farmInfo = functionAPI.getFarmInfo(value.channel, firstRun)
        local newButton = buttonAPI.create(farmInfo.farmType or value.name)
            .setHorizontalPadding(padding)
            .setVerticalPadding(padding)
            .setAlignment('left')
            .setPos(x, y)
            .setArgs({
                state = farmInfo.state or false,
                channel = value
            })

        local atBottom = (newButton.y + newButton.getHeight()) > finalY
        if atBottom then
            x = x + maxWidth + padding + 1
            y = initialY
        end

        if maxWidth == 0 or newButton.width > maxWidth then
            maxWidth = newButton.width
        end

        newButton.onClick(onButtonClick(newButton))
            .setPos(x, y)

        buttonTable[#buttonTable + 1] = newButton

        y = y + newButton.getHeight() + margin
    end

    for i, b in ipairs(buttonTable) do
        buttonTable[i] = b.setSize(maxWidth, b.height)
            .setColor(getButtonColor(b.args.state))
    end

    firstRun = false
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
