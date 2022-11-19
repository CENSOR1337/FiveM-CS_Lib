local Wait = Wait

tickpool = {}
tickpool.__index = tickpool

function tickpool.new()
    local self = {}
    self.handlers = {
        fn = {},
        list = {},
        length = 0,
    }
    self.bReassignTable = false
    self.bThreadCreated = false
    self.key = 10
    self.tickRate = 0
    return setmetatable(self, tickpool)
end

function tickpool:updateTable()
    if not (self.bReassignTable) then return end

    table.wipe(self.handlers.list)
    for _, value in pairs(self.handlers.fn) do
        self.handlers.list[#self.handlers.list + 1] = value
    end
    self.handlers.length = #self.handlers.list
end

function tickpool:add(fnHandler)
    self.key += 1
    self.handlers.fn[self.key] = fnHandler
    self.bReassignTable = true

    if not (self.bThreadCreated) then
        self.bThreadCreated = true
        Citizen.CreateThreadNow(function()
            while true do
                if (self.bReassignTable) then
                    self:updateTable()
                    if (self.handlers.length < 1) then
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

function tickpool:remove(key)
    self.handlers[key] = nil
    self.bReassignTable = true
end

-- [[ Base Tick Pool ]] --
local baseTickPool = nil
function self.onTick(fnHandler)
    if not (baseTickPool) then
        baseTickPool = tickpool.new()
    end
    return baseTickPool:add(fnHandler)
end

function self.clearOnTick(key)
    if not (baseTickPool) then return end
    baseTickPool:remove(key)
end
