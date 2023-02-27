local resourceName = GetCurrentResourceName()
local getResourceEventName = function(eventname)
    return resourceName .. ":" .. eventname
end

return {
    name = resourceName,
    event = setmetatable({}, {
        __call = function(t, eventname)
            return getResourceEventName(eventname)
        end
    }),
    onStop = function(cb)
        lib.on("onResourceStop", function(resource)
            if resource ~= resourceName then return end
            cb(resource)
        end)
    end,
    onStart = function(cb)
        lib.on("onResourceStart", function(resource)
            if resource ~= resourceName then return end
            cb(resource)
        end)
    end,
    on = function(eventname, cb)
        lib.on(getResourceEventName(eventname), cb)
    end,
    onNet = function(eventname, cb)
        lib.onNet(getResourceEventName(eventname), cb)
    end,
    emit = function(eventname, ...)
        lib.emit(getResourceEventName(eventname), ...)
    end,
    emitServer = (not lib.bIsServer) and function(eventname, ...)
        lib.emitServer(getResourceEventName(eventname), ...)
    end,
    emitClient = (lib.bIsServer) and function(eventname, target, ...)
        lib.emitClient(getResourceEventName(eventname), target, ...)
    end,
    emitAllClients = (lib.bIsServer) and function(eventname, ...)
        lib.emitAllClients(getResourceEventName(eventname), -1, ...)
    end,
}
