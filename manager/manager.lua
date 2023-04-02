os.loadAPI('button.lua')
os.loadAPI('channels.lua')
os.loadAPI('constants.lua')
os.loadAPI('functions.lua')

local function drawHeader(monitor, monWidth, monHeight)
    monitor.setCursorPos(2, 2)
    monitor.setTextColor(colors.purple)
    monitor.write('Farms')
    monitor.setCursorPos(1, 3)
    monitor.setTextColor(colors.white)
    monitor.write(string.rep('-', monWidth))

    local nextContentLine = 5
    return nextContentLine
end

local function drawFooter(monitor, monWidth, monHeight)
    monitor.setCursorPos(2, monHeight - 1)
    monitor.setTextColor(colors.lightGray)
    monitor.write('Updated at: ' .. functions.getTimestamp())
    monitor.setCursorPos(1, monHeight - 2)
    monitor.setTextColor(colors.white)
    monitor.write(string.rep('-', monWidth))

    local maxContentLine = monHeight - 3
    return maxContentLine
end

local function getButtonColor(state)
    return state and colors.green or colors.red
end

local function onButtonClick(buttonClicked)
    return function()
        local args = buttonClicked.args
        if args.state then args.state = not args.state end

        print('Toggling state on channel ' .. args.channel)
        local farmInfo = functions.toggleFarmState(args.channel)
        buttonClicked.args.state = farmInfo.state
        buttonClicked.setColor(getButtonColor(farmInfo.state)).draw()
    end
end

local function getMargin(usableHeight)
    local buttonHeight = 3
    local buttonQuantity = functions.floor(usableHeight / buttonHeight)
    local availableSpace = usableHeight - (buttonQuantity * buttonHeight)
    local result = functions.round(availableSpace / (buttonQuantity - 1))
    return result > 1 and result or 1
end

local function createButtons(monitor, initialX, initialY, finalY, monWidth, monHeight)
    local buttonTable = {}

    local x = initialX
    local y = initialY
    local padding = 2
    local maxWidth = 0
    local margin = getMargin(finalY - initialY - padding)

    for key, value in pairs(channels.ALL) do
        if value.type == 'worker' then
            local farmInfo = functions.getFarmInfo(value.channel)
            local newButton = button.create(farmInfo.farmType or value.name)
                .setHorizontalPadding(padding)
                .setVerticalPadding(padding)
                .setAlignment('left')
                .setPos(x, y)
                .setArgs({
                    state = farmInfo.state or false,
                    channel = farmInfo.id or value.channel
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
    end

    for i, b in ipairs(buttonTable) do
        buttonTable[i] = b.setSize(maxWidth, b.height)
            .setColor(getButtonColor(b.args.state))
    end

    return buttonTable
end

local monitor = peripheral.wrap(constants.MONITOR_SIDE)

while true do
    monitor.clear()
    local monWidth, monHeight = monitor.getSize()
    local initialX = 2
    local initialY = drawHeader(monitor, monWidth, monHeight)
    local finalY = drawFooter(monitor, monWidth, monHeight)
    button.await(createButtons(monitor, initialX, initialY, finalY, monWidth, monHeight))
end
