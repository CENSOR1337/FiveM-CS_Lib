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

local ReplicatedTagContainer = {}
ReplicatedTagContainer.__index = ReplicatedTagContainer
ReplicatedTagContainer.__eventname = {
    onTagContainerUpdate = "on.tag.container.update",
}

function ReplicatedTagContainer.new(id, ...)
    local self = {}
    self.id = id
    self.container = TagContainer.new(...)
    self.events = {
        onTagContainerUpdate = ("%s:%s"):format(joaat("tag:rep:get:tags"), id),
    }

    if (lib.isServer) then
        lib.resource.callback.register(self.events.onTagContainerUpdate, function()
            return self.container.tags
        end)
    else

    end

    return setmetatable(self, ReplicatedTagContainer)
end

function ReplicatedTagContainer:updateTag()
    if (lib.isServer) then
        lib.resource.emitAllClients(self.events.onTagContainerUpdate)
    end
    local tags = lib.resource.callback.await(self.events.onTagContainerUpdate)
    local newTagContainer = TagContainer.new()
end

cslib_component = setmetatable({
    new = TagContainer.new,
}, {
    __call = function(_, ...)
        return TagContainer.new(...)
    end,
})
