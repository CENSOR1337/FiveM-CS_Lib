local table_unpack = table.unpack

function self.triggerServerCallback(eventname, listener, ...)
    if not (listener) then error("listener for server callback is nil") end
    local callbackId = cslib.utils.randomString(16)
    local cbEventName = "cslib:serverCallbacks:" .. eventname
    cslib.onceNet(cbEventName .. callbackId, listener)
    TriggerServerEvent(cbEventName, callbackId, ...)
end

function self.triggerServerCallbackAsync(eventname, ...)
    local function handler(...)
        local p = promise.new()
        self.triggerServerCallback(eventname, function(...)
            p:resolve({ ... })
        end, ...)
        return Citizen.Await(p)
    end

    return table_unpack(handler(...))
end
