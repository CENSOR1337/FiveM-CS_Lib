local resourceName = GetCurrentResourceName()
return {
    name = resourceName,
    event = setmetatable({}, {
        __call = function(t, eventname)
            return resourceName .. ":" .. eventname
        end
    })
}
