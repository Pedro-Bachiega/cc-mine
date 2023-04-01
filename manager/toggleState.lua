local args = {...}

os.loadAPI('functions.lua')

local channel = functions.argsToKnownTable(args).channel
if not channel then error('\nMust choose a valid channel through the "-c" argument') end

functions.toggleFarmState(tonumber(channel))
