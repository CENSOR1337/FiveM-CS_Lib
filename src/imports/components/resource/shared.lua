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
    end,
}, {
    __call = function(_, eventname, cb, ...)
        eventname = getResourceEventName(eventname)
        return lib.net.callback(eventname, cb, ...)
    end,
})


cslib_component.name = resourceName
cslib_component.event = setmetatable({}, {
    __call = function(t, eventname)
        return getResourceEventName(eventname)
    end,
})
cslib_component.onStop = function(cb)
    return lib.on("onResourceStop", function(resource)
        if resource ~= resourceName then return end
        cb(resource)
    end)
end
cslib_component.onStart = function(cb)
    return lib.on("onResourceStart", function(resource)
        if resource ~= resourceName then return end
        cb(resource)
    end)
end
cslib_component.on = function(eventname, cb)
    return lib.on(getResourceEventName(eventname), cb)
end
cslib_component.onNet = function(eventname, cb)
    return lib.onNet(getResourceEventName(eventname), cb)
end
cslib_component.once = function(eventname, cb)
    return lib.once(getResourceEventName(eventname), cb)
end
cslib_component.onceNet = function(eventname, cb)
    return lib.onceNet(getResourceEventName(eventname), cb)
end
cslib_component.emit = function(eventname, ...)
    return lib.emit(getResourceEventName(eventname), ...)
end
cslib_component.emitServer = (not lib.bIsServer) and function(eventname, ...)
    return lib.emitServer(getResourceEventName(eventname), ...)
end
cslib_component.emitClient = (lib.bIsServer) and function(eventname, target, ...)
    return lib.emitClient(getResourceEventName(eventname), target, ...)
end
cslib_component.emitAllClients = (lib.bIsServer) and function(eventname, ...)
    return lib.emitAllClients(getResourceEventName(eventname), -1, ...)
end
cslib_component.onServer = cslib_component.onNet
cslib_component.onClient = cslib_component.onNet
cslib_component.onceServer = cslib_component.onceNet
cslib_component.onceClient = cslib_component.onceNet
cslib_component.callback = callback
