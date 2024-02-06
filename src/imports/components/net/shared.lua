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
    for _, handler in ipairs(self.onChangeHandlers) do
        RemoveStateBagChangeHandler(handler)
    end
end

cslib_component.replicated = replication.new

-- Callbacks
local promise = promise
local Await = Citizen.Await
local table_unpack = table.unpack

local prefix = "cslib.cb:"
local timeoutTime = 10 * 1000

local function registerCallback(eventname, listener)
    local cbEventName = prefix .. eventname

    return lib.onNet(cbEventName, function(id, ...)
        local src = source

        if (lib.isServer) then
            lib.emitClient(id, src, listener(...))
        else
            lib.emitServer(id, listener(...))
        end
    end)
end

local function triggerCallback(eventname, src, listener, ...)
    local callbackId = lib.randomUUID()
    local cbEventName = prefix .. eventname

    if (lib.isServer) then
        lib.typeCheck(src, "number", "string")
        lib.typeCheck(listener, "function", "table")

        lib.onceClient(callbackId, listener)
        lib.emitClient(cbEventName, src, callbackId, ...)
    else
        -- if client triggering server callback src or player id is not required
        -- src is going to be listener
        lib.typeCheck(src, "function", "table")

        lib.onceServer(callbackId, src)
        lib.emitServer(cbEventName, callbackId, listener, ...)
    end
end

local function triggerCallbackAwait(eventname, src, ...)
    local function handler(...)
        local p = promise.new()

        triggerCallback(eventname, src, function(...)
            p:resolve({
                success = true,
                params = { ... },
            })
        end, ...)

        lib.setTimeout(function()
            p:resolve({
                success = false,
            })
        end, timeoutTime)

        return Await(p)
    end

    local returnValues = handler(...)
    if not (returnValues.success) then return end
    return table_unpack(returnValues.params)
end

cslib_component.callback = setmetatable({
    register = registerCallback,
    await = triggerCallbackAwait,
}, {
    __call = function(t, ...)
        return triggerCallback(...)
    end,
})
