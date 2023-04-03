os.loadAPI('constants.lua')
os.loadAPI('display.lua')
os.loadAPI('functionAPI.lua')
os.loadAPI('logAPI.lua')

local function changeSignal(state)
    return redstone.setOutput(constants.REDSTONE_SIDE, state)
end

local function updateInfo(newInfo)
    logAPI.log('Updating farm info')
    local farmInfo = newInfo or functionAPI.requestFarmInfo(constants.CHANNEL)

    if constants.MONITOR_SIDE ~= 'none' then display.writeFarmInfo(farmInfo) end
    changeSignal(farmInfo.state or false)
end

function handle(request, replyChannel)
    if not request.command then
        updateInfo(request)
        return true
    elseif request.command == 'updateInfo' then
        updateInfo()
        return true
    end

    return true
end
