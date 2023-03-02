local function rollPercentage(percent)
    return math.random() * 100 <= percent
end

local chancePool = {}
chancePool.__index = chancePool

function chancePool.new()
    local self = setmetatable({}, chancePool)
    self.pool = {}
    self.key = 10
    self.cumulative = 0
    return self
end

function chancePool:calculateCumulative()
    self.cumulative = 0
    for _, item in pairs(self.pool) do
        self.cumulative = self.cumulative + item.chance
        item.chanceEnd = self.cumulative
    end
end

function chancePool:addIntoPool(chance, data)
    self.key = self.key + 1
    self.pool[self.key] = {
        chance = chance,
        data = data
    }
    self:calculateCumulative()
    return self.key
end

function chancePool:remove(key)
    self.pool[key] = nil
    self:calculateCumulative()
end

function chancePool:getRandomItem()
    local random = math.random() * self.cumulative
    for _, value in pairs(self.pool) do
        if (random <= value.chanceEnd) then
            return value.data
        end
    end
end

return {
    rollPercentage = rollPercentage,
    pool = setmetatable({
        new = chancePool.new
    }, {
        __call = function()
            return chancePool.new()
        end
    })
}
