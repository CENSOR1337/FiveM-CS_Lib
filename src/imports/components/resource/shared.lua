local Resource = {}
Resource.__index = Resource

function Resource:prefix(...)
    local args = { ... }
    table.insert(args, 1, self.name)
    return table.concat(args, ":")
end

local ACallback = {}
ACallback.__index = ACallback
setmetatable(ACallback, Resource)

function ACallback.new(resource)
    local self = setmetatable({}, ACallback)
    self.name = resource

    return setmetatable(self, {
        __index = function(_, field)
            return setmetatable({}, {
                __call = function(_, arg1, ...)
                    if (arg1 == self) then
                        return ACallback[field](arg1, ...)
                    end

                    return ACallback[field](self, arg1, ...)
                end,
            })
        end,
    })
end

local AResource = {}
AResource.__index = AResource
setmetatable(AResource, Resource)

function AResource.new(resource)
    local self = setmetatable({}, AResource)
    self.name = resource
    self.callback = ACallback.new(resource)

    return setmetatable(self, {
        __index = function(_, field)
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

local currentResource = AResource.new(GetCurrentResourceName())

cslib_component = setmetatable({
    name = currentResource.name,
}, {
    __index = function(t, resource)
        return setmetatable({}, {
            __index = function(_, key)
                return AResource.new(resource)[key]
            end,
            __call = function(_, ...)
                return currentResource[resource](...)
            end,
        })
    end,
})
