local peripheralAPI = {}

function peripheralAPI.requirePeripheral(name)
    local attachedPeripheral = peripheral.find(name)
    local retrySeconds = 5

    while not attachedPeripheral do
        print('Please attach a ' .. name .. ' to this computer')
        print('Retrying in ' .. retrySeconds .. ' seconds')
        sleep(retrySeconds)
        attachedPeripheral = peripheral.find(name)
    end

    return attachedPeripheral
end

function peripheralAPI.getPeripheral(name)
    return peripheral.find(name)
end

return peripheralAPI
