local node = {}
node.__index = node

function node.new(value)
    local self = {}
    self.value = value
    self.next = nil

    return setmetatable(self, node)
end

local list = {}
list.__index = list

function list.new()
    local self = {}
    self.head = nil
    self.tail = nil
    self.size = 0

    return setmetatable(self, list)
end

function list.fromArray(array)
    lib.assertType(array, "table")

    local self = list.new()
    for _, value in pairs(array) do
        self:add(value)
    end

    return self
end

function list:num()
    return self.size
end

function list:add(value)
    local newNode = node.new(value)

    if self.size == 0 then
        self.head = newNode
        self.tail = newNode
    else
        self.tail.next = newNode
        self.tail = newNode
    end

    self.size = self.size + 1
end

list.push = list.add

function list:removeAt(index)
    if index < 1 or index > self.size then return nil end

    local current = self.head
    local previous = nil

    for i = 1, index do
        if i == index then
            if previous == nil then
                self.head = current.next
            else
                previous.next = current.next
            end

            self.size = self.size - 1
            return current.value
        end

        previous = current
        current = current.next
    end
end

function list:get(index)
    if index < 1 or index > self.size then return nil end

    local current = self.head

    for i = 1, index do
        if i == index then
            return current.value
        end

        current = current.next
    end
end

function list:find(value)
    local current = self.head

    for i = 1, self.size do
        if current.value == value then
            return i
        end

        current = current.next
    end

    return nil
end

function list:remove(value)
    local index = self:find(value)
    if index == nil then return nil end

    return self:removeAt(index)
end

function list:pop()
    return self:removeAt(self.size)
end

function list:shift()
    return self:removeAt(1)
end

function list:each()
    local current = self.head

    return function()
        if current == nil then return nil end

        local value = current.value
        current = current.next

        return value
    end
end

function list:empty()
    self.head = nil
    self.tail = nil
    self.size = 0
end

cslib_component = setmetatable({
    new = list.new,
    fromArray = list.fromArray,
}, {
    __call = function(_, ...)
        return list.fromArray(...)
    end,
})
