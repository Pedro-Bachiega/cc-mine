os.loadAPI('functionAPI.lua')

local basePanelChannel = 999
local request = functionAPI.toJson({command = 'exportChannels'})
local response = functionAPI.sendMessageAndWaitResponse(request, basePanelChannel)
local decodedResponse = functionAPI.fromJson(response.message)

functionAPI.toFile('channels.lua', decodedResponse.body)
print('Channels imported :)')
