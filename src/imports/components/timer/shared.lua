local timer = {}
timer.__index = timer
local Wait = Wait
local CitizenCreateThreadNow = Citizen.CreateThreadNow

function timer.new(handler, delay, options)
    local self = {}
    self.delay = delay or 0
    self.bDestroyed = false
    self.isLoop = (options.isLoop ~= nil) and options.isLoop or false
    self.fnHandler = handler
    self.handler = function()
        if (self.bDestroyed) then return end
        Wait(self.delay)
        self.fnHandler()
    end

    CitizenCreateThreadNow(function(ref)
        self.id = ref
        if (self.isLoop) then
            while not (self.bDestroyed) do
                self.handler()
            end
        else
            self.handler()
        end
    end)

    return setmetatable(self, timer)
end

function timer:destroy()
    self.bDestroyed = true
end

cslib_component = setmetatable({
    new = timer.new,
}, {
    __call = function(_, ...)
        return timer.new(...)
    end,
})
