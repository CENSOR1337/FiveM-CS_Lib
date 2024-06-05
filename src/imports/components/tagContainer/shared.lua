local TagContainer = {}
TagContainer.__index = TagContainer

function TagContainer.new(...)
    local self = {}
    self.tags = {}

    return setmetatable(self, TagContainer)
end

function TagContainer:add(tag)
    local tagCount = self:count(tag)
    self.tags[tag] = tagCount + 1
end

function TagContainer:remove(tag)
    local tagCount = self:count(tag)
    local newCount = tagCount - 1

    self.tags[tag] = newCount > 0 and newCount or nil
end

function TagContainer:has(tag)
    return self.tags[tag] ~= nil
end

function TagContainer:count(tag)
    return self.tags[tag] or 0
end

function TagContainer:clear()
    table.wipe(self.tags)
end

cslib_component = setmetatable({
    new = TagContainer.new,
}, {
    __call = function(_, ...)
        return TagContainer.new(...)
    end,
})
