local computerAPI = require('computerAPI')
local functionAPI = require('functionAPI')
local fileAPI = require('fileAPI')

local function chooseComputerType()
    local typesArray = functionAPI.tableToValueArray(computerAPI.computerTypes)

    local validResult = false
    local result = 0
    while not validResult do
        print('\nSelect the computer type:')

        for index, value in ipairs(typesArray) do
            print(tostring(index) .. ' - ' .. value)
        end

        result = tonumber(read()) or 0
        validResult = result > 0 and result <= #typesArray
    end

    return typesArray[result]
end

local cachedComputerType = computerAPI.findComputerType()
local computerType = cachedComputerType or chooseComputerType()
local contentDir = 'cc-mine/' .. string.lower(computerType) .. '/'

fileAPI.deleteFiles(fs.list(contentDir))
fileAPI.copyFiles(contentDir, true)

if cachedComputerType then
    fileAPI.deleteFile('install.lua')
else
    local installContent = "shell.run('installNetwork.lua', 'computer_type')"
    installContent = installContent:gsub('computer_type', computerType)
    fileAPI.saveToFile('install.lua', installContent, true)
end

---@diagnostic disable-next-line: undefined-field
os.reboot()
