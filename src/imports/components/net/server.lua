local function registerServerCallback(eventname, listener)
    local cbEventName = "cslib:svcb:" .. eventname
    return RegisterNetEvent(cbEventName, function(id, ...)
        local src = source
        TriggerClientEvent(cbEventName .. id, src, listener(...))
    end)
end

local function triggerClientCallback(eventname, listener, ...)
    if not (listener) then error("listener for server callback is nil") end
    local callbackId = lib.utils.randomString(16)
    local cbEventName = "cslib:clcb:" .. eventname
    lib.onceNet(cbEventName .. callbackId, listener)
    TriggerClientEvent(cbEventName, callbackId, ...)
end

local function triggerClientCallbackSync(eventname, ...)
    local function handler(...)
        local p = promise.new()
        triggerClientCallback(eventname, function(...)
            p:resolve({ ... })
        end, ...)
        return Citizen_Await(p)
    end

    return table_unpack(handler(...))
end

return {
    callback = setmetatable({
        register = registerServerCallback,
        await = triggerClientCallbackSync
    }, {
        __call = function(t, ...)
            return triggerClientCallback(...)
        end
    })
}
