local msgpack = msgpack
local msgpack_pack = msgpack.pack

local GetStateBagValue = GetStateBagValue
local SetStateBagValue = SetStateBagValue
local AddStateBagChangeHandler = AddStateBagChangeHandler
local RemoveStateBagChangeHandler = RemoveStateBagChangeHandler

local replication = {}
replication.__index = replication

function replication.new(id)
    assert(type(id) == "string", "replication.new id must be a string")
    local self = setmetatable({}, replication)
    self.id = ("%s:rep:%s"):format(lib.resource.name, tostring(id))
    self.bagName = "global"
    self.onChangeHandlers = {}
    self.data = self:get()
    self:onChange(function(value)
        self.data = value
    end)

    return self
end

function replication:get()
    if (self.data) then
        return self.data
    end

    return GetStateBagValue(self.bagName, self.id)
end

function replication:onChange(callback)
    assert(type(callback) == "function", "replication:onChange callback must be a function")
    local handlerId = AddStateBagChangeHandler(self.id, self.bagName, function(bagName, key, value, _, _)
        callback(value)
    end)
    self.onChangeHandlers[#self.onChangeHandlers + 1] = handlerId
    return handlerId
end

function replication:set(value)
    assert(lib.bIsServer, "replication:set can only be called on the server")
    local valType = type(value)
    assert(valType == "table" or valType == "string" or valType == "number" or valType == "boolean", "replication:set value must be a table, string, number or boolean")
    local payload = msgpack_pack(value)
    SetStateBagValue(self.bagName, self.id, payload, payload:len(), true)
end

function replication:destroy()
    self.data = nil
    for _, handler in ipairs(self.onChangeHandlers) do
        RemoveStateBagChangeHandler(handler)
    end
end

return {
    replicated = replication.new,
}
