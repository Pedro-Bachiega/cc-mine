local buttonAPI = require('buttonAPI')
local computerAPI = require('computerAPI')
local functionAPI = require('functionAPI')
local mathAPI = require('mathAPI')
local uiAPI = require('uiAPI')

local function getButtonColor(state)
    return state and colors.green or colors.red
end

local function onButtonClick()
    return function(buttonClicked)
        local computer = buttonClicked.args

        if not computer.data then
            buttonClicked.blink(colors.lightGray)
            return
        end

        computer.data.state = not computer.data.state

        local function updateButton()
            buttonClicked.args = computer
            buttonClicked.setColor(getButtonColor(computer.data.state)).draw()
        end

        local function updateComputer()
            computerAPI.updateComputer(computer)
        end

        parallel.waitForAny(updateButton, updateComputer)
    end
end

local function getMargin(usableHeight)
    local buttonHeight = 3
    local buttonQuantity = mathAPI.floor(usableHeight / buttonHeight)
    local availableSpace = usableHeight - (buttonQuantity * buttonHeight)
    local result = mathAPI.round(availableSpace / (buttonQuantity - 1))
    return result > 1 and result or 1
end

local function createButtons(initialX, initialY, finalY, monWidth)
    local buttonTable = {}
    local farms = computerAPI.listComputers({ computerAPI.computerTypes.FARM })
    if not farms or not functionAPI.isTable(farms) then
        error('No farms listed, check logs')
    end

    local x = initialX
    local y = initialY
    local padding = 2
    local maxWidth = 0
    local margin = getMargin(finalY - initialY - padding)

    ---@diagnostic disable-next-line: param-type-mismatch
    for _, computer in pairs(farms) do
        if maxWidth < #computer.name then maxWidth = #computer.name end
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    for _, computer in pairs(farms) do
        local newButton = buttonAPI.create(computer.name)
            .setHorizontalPadding(padding)
            .setVerticalPadding(padding)
            .setAlignment('left')
            .setPos(x, y)
            .setArgs(computer)

        newButton.setSize(maxWidth, newButton.height)
            .setColor(getButtonColor(computer.data.state))

        local atEnd = (newButton.x + newButton.getWidth()) >= monWidth
        if atEnd then
            x = initialX
            y = y + newButton.getHeight() + margin
        end

        newButton.onClick(onButtonClick()).setPos(x, y)

        buttonTable[#buttonTable + 1] = newButton

        x = x + maxWidth + padding + 1
    end

    return buttonTable
end

local computerInfo = computerAPI.findComputer() or error('Computer not registered')
local monitor = peripheral.wrap(computerInfo.monitorSide)

while true do
    monitor.clear()
    local monWidth, _ = monitor.getSize()
    local initialX = 2
    local initialY = uiAPI.drawHeader(monitor, 'Farms: ')
    local finalY = uiAPI.drawTimestampFooter(monitor)
    local buttons = createButtons(initialX, initialY, finalY, monWidth)
    buttonAPI.await(buttons)
end
