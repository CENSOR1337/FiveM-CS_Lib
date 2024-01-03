local set = {}
set.__index = set

function set.new(...)
    local self = {}
    self.data = {}
    self.length = 0

    self = setmetatable(self, set)

    local args = { ... }
    for i = 1, #args do
        local value = args[i]
        self:add(value)
    end

    return self
end

function set.fromArray(array)
    lib.typeCheck(array, "table")

    local self = set.new()
    for _, value in pairs(array) do
        self:add(value)
    end

    return self
end

function set:contain(value)
    return self.data[value] ~= nil
end

function set:contains(...)
    local args = { ... }

    for i = 1, #args do
        if not (self:contain(args[i])) then return false end
    end

    return true
end

function set:append(...)
    local args = { ... }
    for i = 1, #args do
        local otherSet = args[i]
        lib.typeCheck(otherSet, "table")
        lib.typeCheck(otherSet.data, "table")

        for value in pairs(otherSet.data) do
            self:add(value)
        end
    end
end

function set:array()
    local array = {}
    for value in pairs(self.data) do
        array[#array + 1] = value
    end
    return array
end

function set:add(value)
    lib.typeCheck(value, "string", "number", "boolean", "table")

    self.data[value] = true
    self.length = self.length + 1
end

function set:remove(value)
    lib.typeCheck(value, "string", "number", "boolean", "table")
    if not (self:contain(value)) then return end

    self.data[value] = nil
    self.length = self.length - 1
end

function set:count()
    return self.length
end

function set:clear()
    self.data = {}
    self.length = 0
end

cslib_component = setmetatable({
    new = set.new,
    fromArray = set.fromArray,
}, {
    __call = function(_, ...)
        return set.new(...)
    end,
})
