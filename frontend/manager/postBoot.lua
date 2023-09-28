if pocket then return end

local id = multishell.launch({}, 'manager.lua')
multishell.setTitle(id, 'Managing')
