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
lib.onClient = isServer and RegisterNetEvent

-- Client
lib.triggerServerCallback = not isServer and lib.net.triggerServerCallback
lib.triggerServerCallbackSync = not isServer and lib.net.triggerServerCallbackSync
lib.emitServer = not isServer and TriggerServerEvent
lib.onServer = not isServer and RegisterNetEvent

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

lib.typeCheck = function(value, ...)
    local types = { ... }
    if (#types == 0) then return true end
    local mapType = {}
    for i = 1, #types, 1 do
        mapType[types[i]] = true
    end
    local valueType = type(value)
    local requireTypes = table.concat(types, " or ")
    local errorMessage = ("bad value (%s expected, got %s)"):format(requireTypes, valueType)
    local matches = mapType[valueType] ~= nil
    assert(matches, errorMessage)
    return matches
end

lib.randomUUID = lib.utils.randomUUID