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
    self.bThreadCreated = false
    self.key = 10
    self.tickRate = options.tickRate or 0
    return setmetatable(self, tickpool)
end

function tickpool:onTick(fnHandler)
    self.key += 1
    self.handlers.fn[self.key] = fnHandler
    self.bReassignTable = true

    if not (self.bThreadCreated) then
        self.bThreadCreated = true
        Citizen.CreateThreadNow(function()
            while true do
                if (self.bReassignTable) then
                    table.wipe(self.handlers.list)
                    for _, value in pairs(self.handlers.fn) do
                        self.handlers.list[#self.handlers.list + 1] = value
                    end
                    self.handlers.length = #self.handlers.list
                    if (self.handlers.length <= 0) then
                        self.bThreadCreated = false
                        break
                    end
                end
                for i = 1, self.handlers.length, 1 do
                    self.handlers.list[i]()
                end
                Wait(self.tickRate)
            end
        end)
    end

    return self.key
end

function tickpool:clearOnTick(key)
    self.handlers[key] = nil
    self.bReassignTable = true
end

self.tickpool = tickpool.new
-- [[ Base Tick Pool ]] --
local baseTickPool = nil
function self.onTick(fnHandler)
    if not (baseTickPool) then
        baseTickPool = tickpool.new()
    end
    return baseTickPool:onTick(fnHandler)
end

function self.clearOnTick(key)
    if not (baseTickPool) then return end
    baseTickPool:clearOnTick(key)
end
