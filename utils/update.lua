os.loadAPI('constants.lua')

if fs.exists('cc-mine-atm8') then fs.delete('cc-mine-atm8') end
if fs.exists('git_clone') and not fs.exists('gitClone.lua') then
    shell.run('mv', 'git_clone', 'gitClone.lua')
end
shell.run('gitClone', 'https://github.com/Pedro-Bachiega/cc-mine-atm8.git')
shell.run('cc-mine-atm8/utils/install.lua', '-t', constants.COMPUTER_TYPE)
