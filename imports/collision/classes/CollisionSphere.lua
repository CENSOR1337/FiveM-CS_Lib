--[[ local collisionSphere = {}
collisionSphere.__index = collisionSphere
setmetatable(collisionSphere, collisionBase)

function collisionSphere.new(options)
    local self = setmetatable({}, collisionSphere)
    self.options = options
    self.relevant = {
        entities = {},
        players = {}
    }
    self:initialize()
    return self
end

self.sphere = {
    new = collisionSphere.new
}
 ]]