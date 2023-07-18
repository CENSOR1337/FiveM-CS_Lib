local Wait = Wait

local tickpool = {}
tickpool.__index = tickpool

function tickpool.new(options)
    options = options or {}
    local self = {}
    self.handlers = {
        fn = {},
        list = {},
        length = 0,
    }
    self.bReassignTable = false
    self.key = 10
    self.tickRate = options.tickRate or 0
    self.interval = nil
    return setmetatable(self, tickpool)
end

function tickpool:add(fnHandler)
    lib.typeCheck(fnHandler, "function", "table")

    self.key += 1
    self.handlers.fn[self.key] = fnHandler
    self.bReassignTable = true

    if not (self.interval) then
        self.interval = lib.setInterval(function()
            local listEntries = self.handlers.list
            if (self.bReassignTable) then
                table.wipe(listEntries)
                for _, value in pairs(self.handlers.fn) do
                    listEntries[#listEntries + 1] = value
                end
                self.handlers.length = #listEntries
                if (self.handlers.length <= 0) then
                    self:clearTimer()
                end
            end
            for i = 1, self.handlers.length, 1 do
                listEntries[i]()
            end
        end, self.tickRate)
    end

    return self.key
end

function tickpool:remove(key)
    self.handlers.fn[key] = nil
    self.bReassignTable = true
end

function tickpool:onTick(...)
    return self:add(...)
end

function tickpool:clearTimer()
    if not (self.interval) then return end
    self.interval:destroy()
    self.interval = nil
end

function tickpool:destroy()
    self:clearTimer()
end

function tickpool:clearOnTick(...)
    return self:remove(...)
end

cslib_component = setmetatable({
    new = tickpool.new,
}, {
    __call = function(_, ...)
        return tickpool.new(...)
    end,
})
