local EnityStreamer = {}
EnityStreamer.__index = EnityStreamer

local function getNonPlayerPeds()
    local peds = lib.game.getPeds()
    local aiPeds = {}
    local count = 0
    for i = 1, #peds, 1 do
        local ped = peds[i]
        if (not lib.game.isPedAPlayer(ped)) then
            count += 1
            aiPeds[count] = ped
        end
    end
    return aiPeds
end

function EnityStreamer.new(options)
    lib.typeCheck(options, "table", "nil")

    options = options or {}
    options.types = options.types or { "ped", "vehicle", "object", "playerped" }

    local self = setmetatable({}, EnityStreamer)
    self.types = lib.set.fromArray(options.types)
    self.tickRate = options.tickRate or 500
    self.tickpool = lib.tickpool.new()
    self.dispatcher = lib.dispatcher.new()

    self.tickpool:onTick(function()
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

        for entityType, entityHandles in pairs(entities) do
            for i = 1, #entityHandles, 1 do
                local entityHandle = entityHandles[i]

                local dimension = 0
                if (cslib.isServer) then
                    dimension = GetEntityRoutingBucket(entityHandle)
                end

                local processedEntity = {
                    entityType = entityType,
                    position = GetEntityCoords(entityHandle),
                    handle = entityHandle,
                    dimension = dimension,
                }

                self.dispatcher:broadcast(processedEntity)
            end
        end
    end)

    return self
end

function EnityStreamer:onTick(listener)
    lib.typeCheck(listener, "function", "table")
    return self.dispatcher:add(listener)
end

cslib_component = setmetatable({
    new = EnityStreamer.new,
}, {
    __call = function()
        return EnityStreamer.new()
    end,
})
