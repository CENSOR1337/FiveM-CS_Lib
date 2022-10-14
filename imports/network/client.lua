function self.triggerServerCallback(eventname, listener, ...)
    local callbackId = self.utils.randomString(16)
    local cbEventName = "cslib:serverCallbacks:" .. eventname
    self.network.onceNet(cbEventName .. callbackId, listener)
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
