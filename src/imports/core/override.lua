self.bIsServer = IsDuplicityVersion()
self.on = AddEventHandler
self.onNet = RegisterNetEvent
self.off = RemoveEventHandler
self.emit = TriggerEvent

if (self.bIsServer) then
    self.registerServerCallback = cslib.network.registerServerCallback
    self.emitClient = TriggerClientEvent
    self.emitAllClients = function(eventname, ...)
        self.emitClient(eventname, -1, ...)
    end
else
    self.triggerServerCallback = cslib.network.triggerServerCallback
    self.triggerServerCallbackSync = cslib.network.triggerServerCallbackSync
    self.emitServer = TriggerServerEvent
end

---@param eventname string
---@param listener function
---@return { key: number, name : string}
function self.once(eventname, listener)
    local eventData
    eventData = AddEventHandler(eventname, function(...)
        self.off(eventData)
        listener(...)
    end)
    return eventData
end

---@param eventname string
---@param listener function
---@return { key: number, name : string}?
function self.onceNet(eventname, listener)
    local eventData
    eventData = RegisterNetEvent(eventname, function(...)
        self.off(eventData)
        listener(...)
    end)
    return eventData
end
