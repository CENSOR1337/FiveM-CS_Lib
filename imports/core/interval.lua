local Interval = {}
Interval.__index = Interval
local Wait = Wait

function Interval.new(handler, delay, options)
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
    return setmetatable(self, Interval)
end

function Interval:destroy()
    self.bDestroyed = true
end

function self.setInterval(handler, interval)
    return Interval.new(handler, interval, { bLoop = true })
end

function self.setTimeout(handler, interval)
    return Interval.new(handler, interval, { bLoop = false })
end

function self.clearInterval(interval)
    interval:destroy()
end
