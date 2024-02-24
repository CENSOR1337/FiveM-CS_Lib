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
lib.isClient = not isServer
lib.bIsClient = not isServer
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
lib.emitClient = isServer and function(eventName, playerId, ...)
    playerId = type("number") and playerId or tostring(playerId)

    if (playerId <= 0) then
        error("cslib: [emitClient] with -1 is not allowed, use emitAllClients instead")
    end

    TriggerClientEvent(eventName, playerId, ...)
end
lib.emitAllClients = isServer and function(eventname, ...)
    TriggerClientEvent(eventname, -1, ...)
end
lib.onClient = isServer and RegisterNetEvent
lib.onceClient = isServer and lib.onceNet

-- Client
lib.triggerServerCallback = not isServer and lib.net.triggerServerCallback
lib.triggerServerCallbackSync = not isServer and lib.net.triggerServerCallbackSync
lib.emitServer = not isServer and TriggerServerEvent
lib.onServer = not isServer and RegisterNetEvent
lib.onceServer = not isServer and lib.onceNet

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

lib.validateType = function(value, ...)
    local types = { ... }
    if (#types == 0) then return true end

    local mapType = {}
    for i = 1, #types, 1 do
        local validateType = types[i]
        assert(type(validateType) == "string", "bad argument types, only expected string") -- should never use anyhing else than string
        mapType[validateType] = true
    end

    local valueType = type(value)

    local matches = (mapType[valueType] ~= nil)

    if not (matches) then
        local requireTypes = table.concat(types, " or ")
        local errorMessage = ("bad value (%s expected, got %s)"):format(requireTypes, valueType)

        return false, errorMessage
    end

    return true
end

lib.assertType = function(...)
    local matches, errorMessage = lib.validateType(...)

    assert(matches, errorMessage)

    return matches
end

lib.typeCheck = lib.assertType -- Mask as DEPRECATED, use assertType instead

lib.randomUUID = lib.utils.randomUUID
lib.export = lib.module.export
lib.import = lib.module.import

lib.init = function()
    lib.time.getNetTime() -- client call, server register, a callback
end
