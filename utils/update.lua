os.loadAPI('constants.lua')

if fs.exists('cc-mine-atm8') then fs.delete('cc-mine-atm8') end
shell.run('git_clone', 'https://github.com/Pedro-Bachiega/cc-mine-atm8.git')
shell.run('cc-mine-atm8/utils/install.lua', '--silent', '-t', constants.COMPUTER_TYPE)
