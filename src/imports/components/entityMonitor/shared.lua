local reservedEntries = lib.set.fromArray({ "handle", "id" })
local EntityMonitor = {}
EntityMonitor.__index = EntityMonitor

local function getNonPlayerPeds()
    local peds = lib.game.getPeds()
    local aiPeds = {}
    local count = 0
    for i = 1, #peds, 1 do
        local ped = peds[i]
        if (not IsPedAPlayer(ped)) then
            count += 1
            aiPeds[count] = ped
        end
    end
    return aiPeds
end

function EntityMonitor.new(options)
    lib.typeCheck(options, "table", "nil")

    options = options or {}
    options.types = options.types or { "ped", "vehicle", "object", "playerped" }

    local self = setmetatable({}, EntityMonitor)
    self.types = lib.set.fromArray(options.types)
    self.tickRate = options.tickRate or 500
    self.dispatcher = lib.dispatcher.new()
    self.natives = {}

    self.tickpool = lib.setInterval(function()
        local entities = {}

        if (self.types:contain("object")) then
            entities["object"] = lib.game.getObjects()
        end

        if (self.types:contain("ped")) then
            entities["ped"] = getNonPlayerPeds()
        end

        if (self.types:contain("vehicle")) then
            entities["vehicle"] = lib.game.getVehicles()
        end

        if (self.types:contain("playerped")) then
            entities["playerped"] = lib.game.getPlayerPeds()
        end

        local entityCount = 1
        for _, entityHandles in pairs(entities) do
            for i = 1, #entityHandles, 1 do
                entityCount += 1
                local entityHandle = entityHandles[i]
                local entityInfo = {}
                entityInfo.handle = entityHandle

                for entryName, propertyGetter in pairs(self.natives) do
                    local result = propertyGetter(entityHandle)
                    entityInfo[entryName] = result
                end

                self.dispatcher:broadcast(entityInfo, { type = entityHandle, index = i, count = entityCount })
            end
        end
    end, self.tickRate)

    return self
end

function EntityMonitor:destroy()
    lib.clearInterval(self.tickpool)
end

function EntityMonitor:setTypes(types)
    lib.assertType(types, "table")
    self.types = lib.set.fromArray(types)
end

function EntityMonitor:subscribe(listener)
    lib.assertType(listener, "function")
    return self.dispatcher:add(listener)
end

function EntityMonitor:unsubscribe(id)
    lib.assertType(id, "number")
    self.dispatcher:remove(id)
end

-- TODO: implement onBeginTick, onTick, onEndTick, off
function EntityMonitor:onTick(listener)
    lib.assertType(listener, "function")
    return self.dispatcher:add(listener)
end

function EntityMonitor:registerGetter(entryName, propertyGetter)
    lib.assertType(entryName, "string")
    lib.assertType(propertyGetter, "function")
    assert(not reservedEntries:contain(entryName), ("Entry name '%s' is reserved"):format(entryName))

    self.natives[entryName] = propertyGetter
end

function EntityMonitor:unregisterGetter(entryName)
    lib.assertType(entryName, "string")

    self.natives[entryName] = nil
end

function EntityMonitor:hasGetter(entryName)
    lib.assertType(entryName, "string")
    return (self.natives[entryName] ~= nil)
end

cslib_component = setmetatable({
    new = EntityMonitor.new,
}, {
    __call = function()
        return EntityMonitor.new()
    end,
})


--[[ This is an example of how to use the EntityMonitor component (TO BE REMOVED)

local exampleMonitor = EntityMonitor.new({
    types = { "playerped" },
    tickRate = 500,
})

if (lib.isServer) then
    exampleMonitor:registerGetter("position", GetEntityCoords)
    exampleMonitor:registerGetter("dimension", GetEntityRoutingBucket)
else
    exampleMonitor:registerGetter("position", function(entity)
        return GetEntityCoords(entity, false)
    end)
end ]]
