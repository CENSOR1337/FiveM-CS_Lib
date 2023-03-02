--[[ Init ]]
if (not _VERSION:find("5.4")) then error("^1[ Please enable Lua 5.4 ]^0", 2) end

local isServer = IsDuplicityVersion()

local function bindOnce(bIsNet, eventname, listener)
    local event
    local fn = function(...)
        lib.off(event)
        listener(...)
    end
    event = bIsNet and RegisterNetEvent(eventname, fn) or AddEventHandler(eventname, fn)
    return event
end

lib.setInterval = function(handler, time)
    return lib.timer.new(handler, time, { isLoop = true })
end

lib.setTimeout = function(handler, time)
    return lib.timer.new(handler, time, { isLoop = false })
end

lib.clearInterval = function(instance)
    if not (instance) then return end
    instance:destroy()
end

lib.isServer = isServer
lib.bIsServer = isServer
lib.on = AddEventHandler
lib.off = RemoveEventHandler
lib.emit = TriggerEvent
lib.onNet = RegisterNetEvent
lib.once = function(eventname, listener)
    return bindOnce(false, eventname, listener)
end
lib.onceNet = function(eventname, listener)
    return bindOnce(true, eventname, listener)
end


-- Server
lib.registerServerCallback = lib.net.registerServerCallback
lib.emitClient = isServer and TriggerClientEvent
lib.emitAllClients = isServer and function(eventname, ...)
    self.emitClient(eventname, -1, ...)
end

-- Client
lib.triggerServerCallback = not isServer and lib.net.triggerServerCallback
lib.triggerServerCallbackSync = not isServer and lib.net.triggerServerCallbackSync
lib.emitServer = not isServer and TriggerServerEvent

-- Tick Pool
local baseTickPool
lib.onTick = function(fnHandler)
    if not (baseTickPool) then
        baseTickPool = lib.tickpool.new()
    end
    return baseTickPool:onTick(fnHandler)
end

lib.clearOnTick = function(key)
    if not (baseTickPool) then return end
    baseTickPool:clearOnTick(key)
end
