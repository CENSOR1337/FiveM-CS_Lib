local chancePool = {}
chancePool.__index = chancePool

function chancePool.new()
    local self = setmetatable({}, chancePool)
    self.totalChance = 0
    self.key = 10
    self.pool = {}
    return self
end

function chancePool:addIntoPool(chance, data)
    self.key += 1
    self.pool[self.key] = {
        chanceEnd = self.totalChance + chance,
        data = data
    }
    self.totalChance = self.totalChance + chance
    return self.key
end

function chancePool:remove(key)
    local item = self.pool[key]
    if (item) then
        self.totalChance -= item.chanceEnd
        self.pool[key] = nil
    end
end

function chancePool:getRandomItem()
    local randomValue = math.random() * self.totalChance
    for _, item in pairs(self.pool) do
        if (randomValue <= item.chanceEnd) then
            return {
                randomValue = randomValue,
                data = item.data
            }
        end
    end
end

return {
    chancePool = chancePool
}
