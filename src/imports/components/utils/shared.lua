local math_random = math.random
local string_format = string.format

local Charset = {
    numeric = { len = 0, chars = {} },
    upper = { len = 0, chars = {} },
    lower = { len = 0, chars = {} },
}
do
    for i = 48, 57 do
        table.insert(Charset.numeric.chars, string.char(i))
    end
    Charset.numeric.len = #Charset.numeric.chars
    for i = 65, 90 do
        table.insert(Charset.upper.chars, string.char(i))
    end
    Charset.upper.len = #Charset.upper.chars
    for i = 97, 122 do
        table.insert(Charset.lower.chars, string.char(i))
    end
    Charset.lower.len = #Charset.lower.chars
end

local randomString
randomString = function(length, options)
    if (length > 0) then
        options = options or { "lower", "upper", "numeric" }
        options.op_len = options.op_len or #options
        local charType = options[math_random(1, options.op_len)]
        local randomChar = Charset[charType].chars[math_random(1, Charset[charType].len)]
        return randomChar .. randomString(length - 1, options)
    end
    return ""
end

local function uuidCharacter(position)
    if (position == 9) then return "-" end
    if (position == 14) then return "-" end
    if (position == 15) then return "4" end
    if (position == 19) then return "-" end
    if (position == 20) then return string_format("%x", math_random(8, 0xb)) end
    if (position == 24) then return "-" end
    return string_format("%x", math_random(0, 0xf))
end

local randomUUID
randomUUID = function()
    local id = ""
    for i = 1, 36, 1 do
        id = id .. uuidCharacter(i)
    end
    return id
end

cslib_component.randomUUID = randomUUID
cslib_component.randomString = randomString
