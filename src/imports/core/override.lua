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

local function bindOnce(bIsNet, eventname, listener)
    local event
    local fn = function(...)
        self.off(event)
        listener(...)
    end
    event = bIsNet and RegisterNetEvent(eventname, fn) or AddEventHandler(eventname, fn)
    return event
end

---@param eventname string
---@param listener function
---@return { key: number, name : string}
function self.once(eventname, listener)
    return bindOnce(false, eventname, listener)
end

---@param eventname string
---@param listener function
---@return { key: number, name : string}?
function self.onceNet(eventname, listener)
    return bindOnce(true, eventname, listener)
end
