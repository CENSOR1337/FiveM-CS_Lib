--[[ local collisionBase = {}
collisionBase.__index = collisionBase

function collisionBase.new(options)
    local self = setmetatable({}, collisionBase)
    self.options = options
    self.relevant = {
        entities = {},
        players = {}
    }
    self:initialize()
    return self
end
 ]]