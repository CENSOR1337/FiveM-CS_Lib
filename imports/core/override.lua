local RemoveEventHandler = RemoveEventHandler
local AddEventHandler = AddEventHandler
local RegisterNetEvent = RegisterNetEvent

self.bIsServer = IsDuplicityVersion()
self.on = AddEventHandler

if (IsDuplicityVersion()) then
    self.onClient = RegisterNetEvent
else
    self.onServer = RegisterNetEvent
end

---@param eventname string
---@param listener function
---@return { key: number, name : string}
function self.once(eventname, listener)
    local eventData
    eventData = AddEventHandler(eventname, function(...)
        listener(...)
        RemoveEventHandler(eventData)
    end)
    return eventData
end

---@param eventname string
---@param listener function
---@return { key: number, name : string}?
function self.onceNet(eventname, listener)
    local eventData
    eventData = RegisterNetEvent(eventname, function(...)
        listener(...)
        RemoveEventHandler(eventData)
    end)
    return eventData
end
