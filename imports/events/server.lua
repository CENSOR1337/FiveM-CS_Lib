function self.registerCallback(eventname, listener)
    local eventData
    eventData = AddEventHandler(eventname, function(...)
        listener(...)
        RemoveEventHandler(eventData)
    end)
    return eventData
end