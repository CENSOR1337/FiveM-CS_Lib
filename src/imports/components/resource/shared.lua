local Resource = {}
Resource.__index = Resource

function Resource:prefix(...)
    local args = { ... }
    table.insert(args, 1, self.name)
    return table.concat(args, ":")
end

local AResource = {}
AResource.__index = AResource
setmetatable(AResource, Resource)

function AResource.new(resource)
    local self = setmetatable({}, AResource)
    self.name = resource
    self.callback = setmetatable({
        register = function(eventname, ...)
            return lib.net.callback.register(self:prefix(eventname), ...)
        end,
        await = function(eventname, ...)
            return lib.net.callback.await(self:prefix(eventname), ...)
        end,
    }, {
        __call = function(t, eventname, ...)
            return lib.net.callback(self:prefix(eventname), ...)
        end,
    })

    return setmetatable(self, {
        __index = function(t, field)
            return setmetatable({}, {
                __call = function(_, arg1, ...)
                    if (arg1 == self) then
                        return AResource[field](arg1, ...)
                    end

                    return AResource[field](self, arg1, ...)
                end,
            })
        end,
    })
end

function AResource:prefix(...)
    local args = { ... }
    table.insert(args, 1, self.name)
    return table.concat(args, ":")
end

function AResource:on(eventname, callback)
    return lib.on(self:prefix(eventname), callback)
end

function AResource:once(eventname, callback)
    return lib.once(self:prefix(eventname), callback)
end

function AResource:emit(eventname, ...)
    return lib.emit(self:prefix(eventname), ...)
end

if (lib.isServer) then
    function AResource:emitClient(eventname, client, ...)
        return lib.emitClient(self:prefix(eventname), client, ...)
    end

    function AResource:emitAllClients(eventname, ...)
        return lib.emitAllClients(self:prefix(eventname), ...)
    end

    function AResource:onClient(eventname, callback)
        return lib.onClient(self:prefix(eventname), callback)
    end

    function AResource:onceClient(eventname, callback)
        return lib.onceClient(self:prefix(eventname), callback)
    end
else
    function AResource:emitServer(eventname, ...)
        return lib.emitServer(self:prefix(eventname), ...)
    end

    function AResource:onServer(eventname, callback)
        return lib.onServer(self:prefix(eventname), callback)
    end

    function AResource:onceServer(eventname, callback)
        return lib.onceServer(self:prefix(eventname), callback)
    end
end

function AResource:onStart(callback)
    return lib.on("onResourceStart", function(startResource)
        if (self.name ~= startResource) then return end
        callback()
    end)
end

function AResource:onStop(callback)
    return lib.on("onResourceStop", function(stopResource)
        if (self.name ~= stopResource) then return end
        callback()
    end)
end

local instances = {}
local resourceName = GetCurrentResourceName()
instances[resourceName] = AResource.new(resourceName)

local currentResource = AResource.new(resourceName)

cslib_component = setmetatable({
    get = function(resource)
        return AResource.new(resource)
    end,
}, {
    __index = function(t, field)
        return instances[resourceName][field]
    end,
})
