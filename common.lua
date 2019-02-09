local common = {}

function common.equal_floats(a,b)
    local thresh = 1 / 8192
    return math.abs(a - b) < thresh
end

return common