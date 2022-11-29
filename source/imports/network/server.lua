function self.registerServerCallback(eventname, listener)
    local cbEventName = "cslib:serverCallbacks:" .. eventname
    RegisterNetEvent(cbEventName, function(id, ...)
        local src = source
        TriggerClientEvent(cbEventName .. id, src, listener(...))
    end)
end