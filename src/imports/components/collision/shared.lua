local entityMonitor = lib.entityMonitor({})

if (lib.isServer) then
    entityMonitor:registerGetter("position", GetEntityCoords)
    entityMonitor:registerGetter("dimension", GetEntityRoutingBucket)
else
    entityMonitor:registerGetter("position", function(entity)
        return GetEntityCoords(entity, false)
    end)
end

local Collision = {}
Collision.__index = Collision

function Collision.new(position, options)
    options = options or {}
    local self = setmetatable({}, Collision)
    self.position = vec(position.x, position.y, position.z)
    self.localPlayerOnly = false
    self.playersOnly = false
    self.insideEntities = cslib.set.new()
    self.validatedEntities = cslib.set.new()
    self.dimension = 0
    self.debug = {
        enabled = (options.debug and options.debug.enabled) or false,
        color = (options.debug and options.debug.color) and options.debug.color or { r = 0, g = 0, b = 255, a = 75 },
    }
    self.tickRate = 500
    self.destroyed = false
    self.tickpool = lib.tickpool.new()
    self.monitorTickId = entityMonitor:subscribe(function(...)
        self:onTick(...)
    end)
    self.tickpoolIds = {}
    self.listeners = {
        enter = lib.dispatcher.new(),
        overlap = lib.dispatcher.new(),
        exit = lib.dispatcher.new(),
    }
    self.onOverlapId = nil

    self:onEndOverlap(function(handle)
        if (self.tickpoolIds[handle]) then
            self.tickpool:remove(self.tickpoolIds[handle])
            self.tickpoolIds[handle] = nil
        end
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

function Collision:onTick(entity, monitorInfo)
    local handle = entity.handle

    -- check conditions
    local isInside = self:isPositionInside(entity.position)
    local isSameDimension = (self.dimension == (entity.dimension or self.dimension))
    local isValid = isInside and isSameDimension

    if (isValid) then
        if not (self.insideEntities:contain(handle)) then
            self.validatedEntities:add(handle)
            self.insideEntities:add(handle)
            self.listeners.enter:broadcast(handle)
        end

        self.validatedEntities:add(handle)
    end

    -- Discard all entities that are not inside anymore, (only after interated through all entities)
    if (monitorInfo.index == monitorInfo.count) then
        for _, handle in pairs(self.insideEntities:array()) do
            if not (self.validatedEntities:contain(handle)) then
                self.insideEntities:remove(handle)
                self.listeners.exit:broadcast(handle)
            end
        end

        self.validatedEntities:clear()
    end
end

function Collision:getRevelantEntities()
    if (self.localPlayerOnly and lib.isClient) then
        return { PlayerPedId() }
    end

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

    if (self.listeners.overlap:size() == 1) then
        self.onOverlapId = self:onBeginOverlap(function(handle)
            self.tickpoolIds[handle] = self.tickpool:onTick(function()
                self.listeners.overlap:broadcast(handle)
            end)
        end)
    end

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
        if (self.listeners.overlap:size() == 0) then
            self.listeners.enter:remove(self.onOverlapId.id)
        end
    end
end

function Collision:destroy()
    if (self.destroyed) then return end
    self.destroyed = true

    self.tickpool:destroy()

    if (self.monitorTickId) then
        entityMonitor:unsubscribe(self.monitorTickId)
    end

    for handle, _ in pairs(self.insideEntities) do
        self.listeners.exit:broadcast(handle)
    end
end

local CollisionSphere = {}
CollisionSphere.__index = CollisionSphere
setmetatable(CollisionSphere, { __index = Collision })

function CollisionSphere.new(position, radius, options)
    lib.assertType(position, "vector3", "vector4", "table")
    lib.assertType(radius, "number")

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

function CollisionSphere:setRadius(radius)
    lib.assertType(radius, "number")
    self.radius = radius
end

function CollisionSphere:getRadius()
    return self.radius
end

cslib_component.sphere = setmetatable({
    new = CollisionSphere.new,
    classes = CollisionSphere,
}, {
    __call = function(_, ...)
        return CollisionSphere.new(...)
    end,
})
