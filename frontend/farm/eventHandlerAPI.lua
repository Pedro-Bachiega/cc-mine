local cacheAPI = require('cacheAPI.lua')
local displayAPI = require('displayAPI.lua')
local functionAPI = require('functionAPI.lua')

local function changeSignal(computerInfo, state)
    return redstone.setOutput(computerInfo.redstoneSide, state)
end

-- TODO Send to backend
local function updateInfo(newInfo)
    local computerInfo = computerAPI.findComputer()

    -- TODO Fetch from backend
    local farmInfo = newInfo or functionAPI.requestFarmInfo(computerInfo.id)
    farmInfo.name = computerInfo.name

    -- Draw info
    if computerInfo.monitorSide ~= 'none' then displayAPI.writeFarmInfo(computerInfo, farmInfo) end

    -- Change signal
    redstone.setOutput(computerInfo.redstoneSide, farmInfo.state or false)
end

function handle(request, replyChannel)
    if request.url == '/farm/update' and request.method == 'POST' then
        if not request.body then
            print('E - Missing body')
            return false
        end

        updateInfo(request.body)
        return true
    end

    return false
end
