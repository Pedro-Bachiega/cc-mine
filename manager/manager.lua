os.loadAPI('button.lua')
os.loadAPI('channels.lua')
os.loadAPI('constants.lua')
os.loadAPI('functions.lua')
os.loadAPI('json.lua')

local function getButtonColor(state)
    return state and colors.green or colors.red
end

local function onButtonClick(buttonClicked)
    return function()
        local args = buttonClicked.args
        if args.state then args.state = not args.state end

        print('Toggling state on channel ' .. args.channel)
        functions.toggleFarmState(args.channel)

        local farmInfo = functions.getFarmInfo(args.channel)
        buttonClicked.args.state = farmInfo.state
        buttonClicked.setColor(getButtonColor(farmInfo.state)).draw()
    end
end

local buttonTable = {}
local x = 2
local y = ((#buttonTable * 3) or 0) + 2

for key, value in pairs(channels.ALL) do
    local farmInfo = functions.getFarmInfo(value.channel)
    local isOn = farmInfo.state or false
    local newButton = button.create(farmInfo.farmType or value.name)
        .setColor(getButtonColor(isOn))
        .setPos(x, y)
        .setArgs({state = isOn, channel = farmInfo.id or value.channel})
    newButton.onClick(onButtonClick(newButton))
    buttonTable[#buttonTable + 1] = newButton

    y = y + newButton.getHeight() + 1

    print('Creating button for ' .. value.name .. ' - args: ' .. json.encode(newButton.args))
end

local monitor = peripheral.wrap(constants.MONITOR_SIDE)
monitor.clear()
while true do button.await(buttonTable) end
