local function firstDefinedValue(...)
    local params = { ... }
    local returnValue = nil

    for i = 1, #params, 1 do
        local value = params[i]
        if (value ~= nil) then
            returnValue = value
            break
        end
    end

    return returnValue
end

cslib_component.firstDefined = firstDefinedValue
