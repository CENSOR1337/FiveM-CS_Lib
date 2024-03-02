local lua_assert = assert
local validate = {}

function validate.type(value, ...)
    local types = { ... }
    if (#types == 0) then return true end

    local mapType = {}
    for i = 1, #types, 1 do
        local validateType = types[i]
        lua_assert(type(validateType) == "string", "bad argument types, only expected string") -- should never use anyhing else than string
        mapType[validateType] = true
    end

    local valueType = type(value)

    local matches = (mapType[valueType] ~= nil)

    if not (matches) then
        local requireTypes = table.concat(types, ", ")
        local errorMessage = ("bad value (%s expected, got %s)"):format(requireTypes, valueType)

        return false, errorMessage
    end

    return true
end

cslib_component = setmetatable({}, {
    __index = function(_, key)
        local medthod = validate[key]

        lua_assert(medthod, ("method validate.%s not found"):format(key))

        return setmetatable({}, {
            __call = function(_, ...)
                return medthod(...)
            end,
            __index = function(_, key)
                if (key ~= "assert") then return nil end

                return function(...)
                    local result, errorMessage = medthod(...)
                    lua_assert(result, errorMessage)
                end
            end,
        });
    end,
});
