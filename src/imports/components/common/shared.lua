local function coalesce(...)
    local params = { ... }
    local return_value = nil

    for i = 1, #params, 1 do
        local value = params[i]
        if (value ~= nil) then
            return_value = value
            break
        end
    end

    return return_value
end

cslib_component.coalesce = coalesce
