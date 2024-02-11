local EnityStreamer = {}
EnityStreamer.__index = EnityStreamer

function EnityStreamer.new(options)
    lib.typeCheck(options, "table", "nil")

    options = options or {}
    options.types = options.types or { "ped", "vehicle", "object", "playerped" }

    local self = setmetatable({}, EnityStreamer)
    self.types = lib.fromArray(options.types)
    self.tickRate = options.tickRate or 500
    self.tickpool = lib.tickpool.new()
    self.dispatcher = lib.dispatcher.new()

    self.tickpool:onTick(function()
        local entities = {}

        if (self.types:contains("object")) then
            entities["object"] = lib.game.getObjects()
        end

        if (self.types:contains("ped")) then
            entities["ped"] = lib.game.getPeds()
        end

        if (self.types:contains("vehicle")) then
            entities["vehicle"] = lib.game.getVehicles()
        end

        local procressedEntities = {}
        for entityType, entityHandles in pairs(entities) do
            for i = 1, #entityHandles, 1 do
                local entityHandle = entityHandles[i]

                local dimension = 0
                if (cslib.isServer) then
                    dimension = GetEntityRoutingBucket(entityHandle)
                end
                local processedEntity = {
                    type = entityType,
                    pos = GetEntityCoords(entityHandle),
                    handle = entityHandle,
                    dimension = dimension,
                }

                procressedEntities[#procressedEntities + 1] = processedEntity
            end
        end

        self.dispatcher:broadcast(procressedEntities)
    end)

    return self
end

function EnityStreamer:onTick(listener)
    lib.typeCheck(listener, "function", "table")
    return self.dispatcher:add(listener)
end
