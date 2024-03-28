local VirtualEntity = {}
VirtualEntity.__instances = {}
VirtualEntity.__index = VirtualEntity
VirtualEntity.__eventname = {
    onSyncedMetaChange = "on.ve.synced.meta.change",
    onStreamIn = "on.ve.stream.in",
    onStreamOut = "on.ve.stream.out",
}

function VirtualEntity.initialize(veType)
    local self = {}
    self.veType = veType
    local veClass = setmetatable(self, VirtualEntity)

    if (lib.isClient) then
        local eventname = ("%s:%s"):format(veClass.__eventname.onStreamIn, veType)
        lib.resource.onServer(eventname, function(id, pos, syncedMeta)
            pos = vec(pos.x, pos.y, pos.z)
            veClass:new(id, pos, syncedMeta)
        end)
    end
    return veClass
end

function VirtualEntity:new(...)
    local args = { ... }
    local id, position, streamDistance, syncedMeta

    if (lib.isServer) then
        id = lib.randomUUID()
        position = args[1]
        streamDistance = args[2]
        lib.typeCheck(streamDistance, "number")
        syncedMeta = args[3]
    else
        id = args[1]
        position = args[2]
        syncedMeta = args[3]
    end

    lib.typeCheck(id, "string")
    lib.typeCheck(position, "vector3")

    local veType = self.veType
    local self = setmetatable(self, VirtualEntity)
    self.id = id
    self.dimension = 0
    self.pos = vec(position.x, position.y, position.z)
    self.veType = veType
    self.destroyed = false
    self.syncedMeta = {}

    if (syncedMeta) then
        for key, value in pairs(syncedMeta) do
            self.syncedMeta[key] = value
        end
    end

    if (lib.isServer) then
        self.streamingPlayers = lib.set()

        local onPlayerLeaveStreamingRange = function(src)
            self.streamingPlayers:remove(src)

            if (DoesPlayerExist(src)) then
                local eventname = ("%s:%s"):format(self.__eventname.onStreamOut, self.id)
                lib.resource.emitClient(eventname, src, self.id)
            end
        end

        local onEnterStreamingRange = function(handle)
            if not (DoesEntityExist(handle)) then return end
            local src = NetworkGetEntityOwner(handle)
            if not (DoesPlayerExist(src)) then return end

            self.streamingPlayers:add(src)

            local eventname = ("%s:%s"):format(self.__eventname.onStreamIn, self.veType)
            lib.resource.emitClient(eventname, src, self.id, self.pos, self.syncedMeta)
        end

        local onLeaveStreamingRange = function(handle)
            if not (DoesEntityExist(handle)) then return end

            local src = NetworkGetEntityOwner(handle)

            onPlayerLeaveStreamingRange(src)
        end

        local collision = lib.collision.sphere(position, streamDistance)
        collision.playersOnly = true
        collision:onBeginOverlap(onEnterStreamingRange)
        collision:onEndOverlap(onLeaveStreamingRange)

        cslib.on("playerDropped", function()
            local src = source
            self.streamingPlayers:remove(src)
        end)
    else
        lib.resource.onceServer(("%s:%s"):format(self.__eventname.onStreamOut, self.id), function()
            self:destroy()
        end)

        lib.resource.onServer(("%s:%s"):format(self.__eventname.onSyncedMetaChange, self.id), function(key, value)
            self.syncedMeta[key] = value

            if (self.onSyncedMetaChange) then
                self:onSyncedMetaChange(key, value)
            end
        end)

        if (self.onStreamIn) then
            self:onStreamIn()
        end

        cslib.resource.onStop(function()
            if (self.onStreamOut) then
                self:onStreamOut()
            end
        end)
    end

    return self
end

function VirtualEntity:destroy()
    if (self.destroyed) then return end
    self.destroyed = true

    if (lib.isServer) then
        for _, src in pairs(self.streamingPlayers:array()) do
            local eventname = ("%s:%s"):format(self.__eventname.onStreamOut, self.id)
            lib.resource.emitClient(eventname, src, self.id)
        end
    else
        if (self.onStreamOut) then
            self:onStreamOut()
        end
    end
end

function VirtualEntity:setSyncedMeta(key, value)
    self.syncedMeta[key] = value
    for _, src in pairs(self.streamingPlayers:array()) do
        local eventname = ("%s:%s"):format(self.__eventname.onSyncedMetaChange, self.id)
        lib.resource.emitClient(eventname, src, key, value)
    end
end

function VirtualEntity:getSyncedMeta(key)
    return self.syncedMeta[key]
end

cslib_component = VirtualEntity
