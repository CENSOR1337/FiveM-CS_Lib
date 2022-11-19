local interval = {}
interval.__index = interval
local Wait = Wait

function interval.new(handler, delay, options)
    local self = {}
    self.handler = handler
    self.delay = delay or 0
    self.bDestroyed = false
    self.bLoop = (options.bLoop ~= nil) and options.bLoop or false
    Citizen.CreateThreadNow(function(ref)
        self.id = ref
        if (self.bLoop) then
            while not (self.bDestroyed) do
                Wait(self.delay)
                if (self.bDestroyed) then break end
                self.handler()
            end
        else
            Wait(self.delay)
            if (self.bDestroyed) then return end
            self.handler()
        end
    end)
    return setmetatable(self, interval)
end

function interval:destroy()
    self.bDestroyed = true
end

function self.setInterval(handler, time)
    return interval.new(handler, time, { bLoop = true })
end

function self.setTimeout(handler, time)
    return interval.new(handler, time, { bLoop = false })
end

function self.clearInterval(instance)
    instance:destroy()
end
