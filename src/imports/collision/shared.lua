local GetEntityCoords = GetEntityCoords
local DoesEntityExist = DoesEntityExist

local collisionBase = {}
collisionBase.__index = collisionBase

function collisionBase.new(options)
    local self = {}
    self.poolTypes = options.poolTypes or { "CObject", "CPed", "CVehicle" }
    self.bOnlyRelevant = options.bOnlyRelevant or false
    self.tickRate = options.tickRate or 500
    self.bDebug = options.bDebug or false
    self.color = { r = 0, g = 0, b = 255, a = 75 }

    self.relevant = {
        entities = {},
        players = {}
    }
    self.overlapping = {}
    return self
end

function collisionBase:destroy()
    if (self.interval) then
        cslib.clearInterval(self.interval)
        self.interval = nil
    end

    if (self.debugInterval) then
        cslib.clearInterval(self.debugInterval)
        self.debugInterval = nil
    end

    if (self.tickpool) then
        for _, entity in pairs(self.overlapping) do
            if (entity.interval) then
                self.tickpool:clearOnTick(entity.interval)
                entity.interval = nil
            end
        end
    end
end

function collisionBase:addRelevantEntity(entity)
    if not (DoesEntityExist(entity)) then return end
    if (self:isEntityRelevant(entity)) then return end
    self.relevant.entities[entity] = entity
end

function collisionBase:removeRelevantEntity(entity)
    if not (self:isEntityRelevant(entity)) then return end
    self.relevant.entities[entity] = nil
end

function collisionBase:isEntityRelevant(entity)
    return self.relevant.entities[entity] ~= nil
end

function collisionBase:clearRelevantEntities()
    self.relevant.entities = {}
end

function collisionBase:getRelevantEntities()
    return self.relevant.entities
end

function collisionBase:addRelevantPlayer(src)
    if (self:isPlayerRelevant(src)) then return end
    self.relevant.players[src] = src
end

function collisionBase:removeRelevantPlayer(src)
    if not (self:isPlayerRelevant(src)) then return end
    self.relevant.players[src] = nil
end

function collisionBase:isPlayerRelevant(src)
    return self.relevant.players[src] ~= nil
end

function collisionBase:clearRelevantPlayers()
    self.relevant.players = {}
end

function collisionBase:getRelevantPlayers()
    return self.relevant.players
end

function collisionBase:clearRelevant()
    self:clearRelevantEntities()
    self:clearRelevantPlayers()
end

--[[ Sphere ]]
local collisionSphere = {}
collisionSphere.__index = collisionSphere
setmetatable(collisionSphere, collisionBase)

function collisionSphere.new(options)
    if not (options.radius) then return end
    if (options.coords) then
        options.position = options.coords
    end
    if not (options.position) then return end
    local self = setmetatable(collisionBase.new(options), collisionSphere)
    self.type = "sphere"
    self.radius = options.radius or 1.0
    self.position = vector3(options.position.x, options.position.y, options.position.z)
    self.tickpool = cslib.tickpool.new()

    self.interval = cslib.setInterval(function()
        for key, entity in pairs(self.overlapping) do
            if not (DoesEntityExist(entity.id)) then
                if (entity.interval) then
                    self.tickpool:clearOnTick(entity.interval)
                    entity.interval = nil
                end
                self.overlapping[key] = nil
            end
        end

        local entities = {}
        if (self.bOnlyRelevant) then
            local count = 0
            for _, entity in pairs(self:getRelevantEntities()) do
                if (DoesEntityExist(entity)) then
                    count += 1
                    entities[count] = entity
                end
            end

            for _, src in pairs(self:getRelevantPlayers()) do
                local playerId = cslib.bIsServer and src or GetPlayerFromServerId(src)
                local entity = GetPlayerPed(playerId)
                if (DoesEntityExist(entity)) then
                    count += 1
                    entities[count] = entity
                end
            end
        else
            entities = cslib.game.getEntitiesByTypes(self.poolTypes)
        end
        for i = 1, #entities, 1 do
            local entityId = entities[i]
            local entity = self.overlapping[entityId] or { id = entityId }

            entity.coords = GetEntityCoords(entity.id)
            local bInside = self:isPointInside(entity.coords)

            if (bInside) then
                if not (self.overlapping[entity.id]) then
                    if (self.onBeginOverlap) then
                        self:onBeginOverlap(entity)
                    end

                    if (self.onOverlapping) then
                        entity.interval = self.tickpool:onTick(function()
                            local interval = entity.interval
                            entity.interval = nil
                            self:onOverlapping(entity)
                            entity.interval = interval
                        end)
                    end
                end
            else
                if (self.overlapping[entity.id]) then
                    if (self.onOverlapping) then
                        if (entity.interval) then
                            self.tickpool:clearOnTick(entity.interval)
                            entity.interval = nil
                        end
                    end

                    if (self.onEndOverlap) then
                        self:onEndOverlap(entity)
                    end
                end
            end

            self.overlapping[entity.id] = bInside and entity or nil
        end
    end, self.tickRate)

    if (self.debugThread and self.bDebug) then
        self:debugThread()
    end

    return self
end

self.sphere = setmetatable({
    new = collisionSphere.new,
}, {
    __call = function(t, ...)
        return t.new(...)
    end
})

function collisionSphere:isPointInside(coords)
    local distance = #(vec(coords.x, coords.y, coords.z) - self.position)
    return (distance <= self.radius)
end

function collisionSphere:isEntityInside(entity)
    return self:isPointInside(GetEntityCoords(entity))
end

if not (bServer) then
    function collisionSphere:debugThread()
        self.debugInterval = cslib.setInterval(function()
            DrawMarker(28, self.position.x, self.position.y, self.position.z, 0, 0, 0, 0, 0, 0, self.radius, self.radius, self.radius, self.color.r, self.color.g, self.color.b, self.color.a, false, false, 0, false, nil, nil, false)
        end, 0)
    end
end

function collisionSphere:setOrigin(coords)
    self.position = vector3(coords.x, coords.y, coords.z)
end

function collisionSphere:setRadius(radius)
    self.radius = radius + 0.0
end
