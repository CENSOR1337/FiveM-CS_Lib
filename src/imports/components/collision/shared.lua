local Collision = {}
Collision.__index = Collision

function Collision.new(position, options)
    options = options or {}
    local self = setmetatable({}, Collision)
    self.position = vec(position.x, position.y, position.z)
    self.playersOnly = false
    self.insideEntities = {}
    self.dimension = 0
    self.debug = {
        enabled = (options.debug and options.debug.enabled) or false,
        color = (options.debug and options.debug.color) and options.debug.color or { r = 0, g = 0, b = 255, a = 75 },
    }
    self.tickRate = 500
    self.destroyed = false
    self.tickpool = lib.tickpool.new()
    self.interval = lib.setInterval(function()
        self:onTick()
    end, self.tickRate)
    self.tickpoolIds = {}
    self.listeners = {
        enter = lib.dispatcher.new(),
        overlap = lib.dispatcher.new(),
        exit = lib.dispatcher.new(),
    }

    self:onBeginOverlap(function(handle)
        self.tickpoolIds[handle] = self.tickpool:onTick(function()
            self.listeners.overlap:broadcast(handle)
        end)
    end)

    self:onEndOverlap(function(handle)
        self.tickpool:remove(self.tickpoolIds[handle])
        self.tickpoolIds[handle] = nil
    end)

    if (self.debug and self.debug.enabled) then
        CreateThread(function() -- Wait for child class to be initialized
            if (self.debugThread) then
                self:debugThread()
            end
        end)
    end

    return self
end

function Collision:onTick()
    if (self.destroyed) then
        self.tickpool:destroy()
        self.interval:destroy()
        for handle, _ in pairs(self.insideEntities) do
            self.listeners.exit:broadcast(handle)
        end
        return
    end

    local entities = self:getRevelantEntities()

    for handle, _ in pairs(self.insideEntities) do
        local isValid = self:isEntityValid(handle)
        if not (isValid) then
            self.insideEntities[handle] = nil
            self.listeners.exit:broadcast(handle)
        end
    end

    for i = 1, #entities, 1 do
        local handle = entities[i]
        if not ((self.insideEntities[handle])) then
            local isValid = self:isEntityValid(handle)
            if (isValid) then
                self.insideEntities[handle] = true
                self.listeners.enter:broadcast(handle)
            end
        end
    end
end

function Collision:getRevelantEntities()
    if (self.playersOnly) then
        return lib.game.getPlayerPeds()
    end

    return lib.game.getEntities()
end

function Collision:isEntityValid(handle)
    if not (DoesEntityExist(handle)) then return false end
    if not (self:isEntityInside(handle)) then return false end
    if (lib.bIsServer) then
        if not (GetEntityRoutingBucket(handle) == self.dimension) then return false end
    end
    return true
end

function Collision:isEntityInside(handle)
    return false -- implement in child class
end

function Collision:isPositionInside(position)
    return false -- implement in child class
end

function Collision:onBeginOverlap(listener)
    local id = self.listeners.enter:add(listener)
    return { id = id, type = "enter" }
end

function Collision:onOverlapping(listener)
    local id = self.listeners.overlap:add(listener)
    return { id = id, type = "overlap" }
end

function Collision:onEndOverlap(listener)
    local id = self.listeners.exit:add(listener)
    return { id = id, type = "exit" }
end

function Collision:off(listenerInfo)
    if (listenerInfo.type == "enter") then
        self.listeners.enter:remove(listenerInfo.id)
    elseif (listenerInfo.type == "exit") then
        self.listeners.exit:remove(listenerInfo.id)
    elseif (listenerInfo.type == "overlap") then
        self.listeners.overlap:remove(listenerInfo.id)
    end
end

function Collision:destroy()
    self.destroyed = true
end

local CollisionSphere = {}
CollisionSphere.__index = CollisionSphere
setmetatable(CollisionSphere, { __index = Collision })

function CollisionSphere.new(position, radius, options)
    lib.typeCheck(position, "vector3", "vector4", "table")
    lib.typeCheck(radius, "number")

    local self = setmetatable(Collision.new(position, options), CollisionSphere)
    self.radius = radius
    return self
end

function CollisionSphere:isPositionInside(position)
    local dist = #(position - self.position)
    return (dist <= self.radius)
end

function CollisionSphere:isEntityInside(handle)
    local dist = #(GetEntityCoords(handle) - self.position)
    return (dist <= self.radius)
end

function CollisionSphere:debugThread()
    if (lib.bIsServer) then return end
    self.tickpool:add(function()
        local fRadius = self.radius + 0.0
        local color = self.debug.color
        DrawMarker(28, self.position.x, self.position.y, self.position.z, 0, 0, 0, 0, 0, 0, fRadius, fRadius, fRadius, color.r, color.g, color.b, color.a, false, false, 0, false, nil, nil, false)
    end)
end

cslib_component.sphere = setmetatable({
    new = CollisionSphere.new,
}, {
    __call = function(_, ...)
        return CollisionSphere.new(...)
    end,
})
