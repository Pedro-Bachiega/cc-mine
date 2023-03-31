local args = {...}
local computerType = nil

os.loadAPI('machine.lua')

local argsTable = machine.argsToKnownTable(args)

shell.run('git_clone', 'https://github.com/Pedro-Bachiega/cc-mine-atm8.git')
shell.run('cc-mine-atm8/utils/install.lua', '--silent', '-t', argsTable.computerType)
