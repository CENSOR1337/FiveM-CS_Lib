local RemoveEventHandler = RemoveEventHandler
local AddEventHandler = AddEventHandler
local RegisterNetEvent = RegisterNetEvent
local table_unpack = table.unpack

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
