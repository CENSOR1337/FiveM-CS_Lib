local function registerServerCallback(eventname, listener)
    local cbEventName = "cslib:serverCallbacks:" .. eventname
    return RegisterNetEvent(cbEventName, function(id, ...)
        local src = source
        TriggerClientEvent(cbEventName .. id, src, listener(...))
    end)
end

return {
    registerServerCallback = registerServerCallback
}
