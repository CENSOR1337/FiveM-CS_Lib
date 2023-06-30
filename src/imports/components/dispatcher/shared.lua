local Dispatcher = {}
Dispatcher.__index = Dispatcher

function Dispatcher.new()
    local self = setmetatable({}, Dispatcher)
    self.listenerId = 0
    self.listeners = {}
    return self
end

function Dispatcher:add(listener)
    self.listenerId = self.listenerId + 1
    local listenerInfo = {
        id = self.listenerId,
        listener = listener,
    }
    self.listeners[#self.listeners + 1] = listenerInfo
end

function Dispatcher:remove(id)
    for i = 1, #self.listenerId, 1 do
        local listenerInfo = self.listeners[i]
        if (listenerInfo.id == id) then
            table.remove(self.listeners, i)
            break
        end
    end
end

function Dispatcher:broadcast(...)
    for _, listenerInfo in pairs(self.listeners) do
        listenerInfo.listener(...)
    end
end

cslib_component = setmetatable({
    new = Dispatcher.new,
}, {
    __call = function()
        return Dispatcher.new()
    end,
})
