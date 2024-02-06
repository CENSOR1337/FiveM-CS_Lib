-- find value by percent from a max value
local function percent(maxValue, percent)
    return maxValue * (percent / 100)
end

-- find percent from a value
local function findPercent(value, percent)
    return (value / percent) * 100
end

-- find base value from percent
local function findBaseValueFromPercent(value, percent)
    return value / (percent / 100)
end


cslib_component.percent = percent
cslib_component.findPercent = findPercent
cslib_component.findBaseValueFromPercent = findBaseValueFromPercent