local math_random = math.random
local self = {}

local Charset = {
    numeric = { len = 10, chars = {} },
    upper = { len = 26, chars = {} },
    lower = { len = 26, chars = {} },
}
do
    for i = 48, 57 do
        table.insert(Charset.numeric.chars, string.char(i))
    end
    for i = 65, 90 do
        table.insert(Charset.upper.chars, string.char(i))
    end
    for i = 97, 122 do
        table.insert(Charset.lower.chars, string.char(i))
    end
end

function self.randomString(length, options)
    if (length > 0) then
        options = options or { "lower", "upper", "numeric" }
        options.op_len = options.op_len or #options
        local charType = options[math_random(1, options.op_len)]
        local randomChar = Charset[charType].chars[math_random(1, Charset[charType].len)]
        return randomChar .. self.randomString(length - 1, options)
    end
    return ""
end
