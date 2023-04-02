os.loadAPI('functions.lua')

local basePanelChannel = 999
local request = functions.toJson({command = 'exportChannels'})
local response = functions.sendMessageAndWaitResponse(request, basePanelChannel)
local decodedResponse = functions.fromJson(response.message)

functions.toFile('channels.lua', decodedResponse.body)
print('Channels imported :)')
