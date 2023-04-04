for k, v in pairs(fs.list('.')) then
    if v ~= 'rom' then fs.delete(v) end
end