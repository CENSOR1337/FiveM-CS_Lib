local resourceName = GetCurrentResourceName()
local getResourceEventName = function(eventname)
    return resourceName .. ":" .. eventname
end

local callback = setmetatable({
    register = function(eventname, listener)
        eventname = getResourceEventName(eventname)
        return lib.net.callback.register(eventname, listener)
    end,
    await = function(eventname, ...)
        eventname = getResourceEventName(eventname)
        return lib.net.callback.await(eventname, ...)
    end
}, {
    __call = function(_, eventname, cb)
        eventname = getResourceEventName(eventname)
        return lib.net.callback(eventname, cb)
    end
})

return {
    name = resourceName,
    event = setmetatable({}, {
        __call = function(t, eventname)
            return getResourceEventName(eventname)
        end
    }),
    onStop = function(cb)
        return lib.on("onResourceStop", function(resource)
            if resource ~= resourceName then return end
            cb(resource)
        end)
    end,
    onStart = function(cb)
        return lib.on("onResourceStart", function(resource)
            if resource ~= resourceName then return end
            cb(resource)
        end)
    end,
    on = function(eventname, cb)
        return lib.on(getResourceEventName(eventname), cb)
    end,
    onNet = function(eventname, cb)
        return lib.onNet(getResourceEventName(eventname), cb)
    end,
    once = function(eventname, cb)
        return lib.once(getResourceEventName(eventname), cb)
    end,
    onceNet = function(eventname, cb)
        return lib.onceNet(getResourceEventName(eventname), cb)
    end,
    emit = function(eventname, ...)
        return lib.emit(getResourceEventName(eventname), ...)
    end,
    emitServer = (not lib.bIsServer) and function(eventname, ...)
        return lib.emitServer(getResourceEventName(eventname), ...)
    end,
    emitClient = (lib.bIsServer) and function(eventname, target, ...)
        return lib.emitClient(getResourceEventName(eventname), target, ...)
    end,
    emitAllClients = (lib.bIsServer) and function(eventname, ...)
        return lib.emitAllClients(getResourceEventName(eventname), -1, ...)
    end,
    callback = callback
}
