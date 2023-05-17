local table_unpack = table.unpack
local Citizen_Await = Citizen.Await

local function registerServerCallback(eventname, listener)
    local cbEventName = "cslib:svcb:" .. eventname
    return RegisterNetEvent(cbEventName, function(id, ...)
        local src = source
        TriggerClientEvent(cbEventName .. id, src, listener(...))
    end)
end

local function triggerClientCallback(eventname, src, listener, ...)
    if not (src) then error("source for server callback is nil") end
    if not (listener) then error("listener for server callback is nil") end
    local callbackId = lib.utils.randomString(16)
    local cbEventName = "cslib:clcb:" .. eventname
    lib.onceNet(cbEventName .. callbackId, listener)
    TriggerClientEvent(cbEventName, src, callbackId, ...)
end

local function triggerClientCallbackSync(eventname, src, ...)
    local function handler(...)
        local p = promise.new()
        triggerClientCallback(eventname, src, function(...)
            p:resolve({ ... })
        end, ...)
        return Citizen_Await(p)
    end

    return table_unpack(handler(...))
end

cslib_component.callback = setmetatable({
    register = registerServerCallback,
    await = triggerClientCallbackSync,
}, {
    __call = function(t, ...)
        return triggerClientCallback(...)
    end,
})
