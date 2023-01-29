local msgpack = msgpack
local msgpack_pack = msgpack.pack

local replicator = {}
replicator.__index = replicator
replicator.service = IsDuplicityVersion() and "server" or "client"
replicator.isServer = replicator.service == "server"
replicator.resourceName = GetCurrentResourceName()
replicator.bagName = "cslib_rep:global"

function replicator.new(name, options)
    local self = setmetatable({}, replicator)
    options = options or {}
    self.name = name
    self.data = {}
    self.bagName = options.bagName and options.bagName or "global"
    self.bagName = self.bagName:format("cslib_rep:%s", self.bagName)
    if not (replicator.isServer) then
        self.changeHandlder = AddStateBagChangeHandler(nil, self.bagName, function(bagName, key, value, _, _)
            self.data[key] = value
        end)
    end
    return self
end

function replicator:destroy()
    if not (replicator.isServer) then
        RemoveStateBagChangeHandler(self.changeHandlder)
    end
    self.data = nil
end

function replicator:get(key)
    local value = self.data[key]

    if not (value) then
        value = GetStateBagValue(self.bagName, key)
        if (value) then
            self.data[key] = value
        end
    end

    return value
end

function replicator:set(key, value)
    if not (replicator.isServer) then return end

    local keyType = type(key)
    if (keyType ~= "number" and keyType ~= "string") then
        return
    end

    self.data[key] = value

    local payload = msgpack_pack(value)
    SetStateBagValue(self.bagName, key, payload, payload:len(), replicator.isServer)
end

return {
    replicator = setmetatable({
        new = function(...)
            local replicatorObject = replicator.new(...)
            return setmetatable({}, {
                __index = function(t, k)
                    return replicatorObject:get(k)
                end,
                __newindex = function(table, key, value)
                    replicatorObject:set(key, value)
                end
            })
        end
    }, {
        __call = function(t, ...)
            return t.new(...)
        end
    }),
}
