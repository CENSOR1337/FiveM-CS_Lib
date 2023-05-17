local CSyncedObject = {}
CSyncedObject.__index = CSyncedObject

local table_unpack = table.unpack
local CreateThreadNow = Citizen.CreateThreadNow

function CSyncedObject:new(...)
    if not (self.__classname) then
        return error("CSyncedObject:new() - classname is nil")
    end

    if (type(self.__classname) ~= "string") then
        return error("CSyncedObject:new() - classname is not a string")
    end

    local args = { ... }
    local object = setmetatable({}, self)

    if (IsDuplicityVersion()) then
        self.__ids = self.__ids + 1
        self.__objects[self.__ids] = object
        self.__objectsArgs[self.__ids] = args
    end

    if (self.constructor) then
        CreateThreadNow(function()
            object:constructor(table_unpack(args))
        end)
    end

    if (IsDuplicityVersion()) then
        lib.resource.emitAllClients(("rep:%s:refresh"):format(self.__classname))
    end

    return object
end

function CSyncedObject:destroy()
    if (self.destructor) then
        CreateThreadNow(function()
            self:destructor()
        end)
    end

    if (IsDuplicityVersion()) then
        for id, object in pairs(self.__objects) do
            if (object == self) then
                self.__objects[id] = nil
                self.__objectsArgs[id] = nil
                break
            end
        end
        lib.resource.emitAllClients(("rep:%s:refresh"):format(self.__classname))
    end
end

function CSyncedObject:getObjects()
    return self.__objects
end

function CreateCSyncedObject(classname)
    if not (classname) then
        return error("CSyncedObject.inherit() - classname is nil")
    end

    if (type(classname) ~= "string") then
        return error("CSyncedObject.inherit() - classname is not a string")
    end

    local self = setmetatable({}, CSyncedObject)
    self.__index = self
    self.__classname = classname
    self.__objects = {}
    self.__objectsArgs = {}
    self.__ids = 10

    if (IsDuplicityVersion()) then
        lib.resource.callback.register(("rep:%s:getObjectIds"):format(self.__classname), function()
            local objectIds = {}
            for id, _ in pairs(self.__objects) do
                objectIds[#objectIds + 1] = id
            end
            return objectIds
        end)

        lib.resource.callback.register(("rep:%s:getObjectFromIds"):format(self.__classname), function(ids)
            if not (ids) then return {} end
            if (type(ids) ~= "table") then return {} end
            local objects = {}
            for _, id in pairs(ids) do
                objects[id] = self.__objectsArgs[id]
            end
            return objects
        end)
    else
        local refreshObject = function()
            local objectIds = lib.resource.callback.await(("rep:%s:getObjectIds"):format(self.__classname))
            local nonExistIds = {}
            local validIds = {}
            for _, id in pairs(objectIds) do
                if not (self.__objects[id]) then
                    nonExistIds[#nonExistIds + 1] = id
                end
                validIds[id] = true
            end

            local objects = lib.resource.callback.await(("rep:%s:getObjectFromIds"):format(self.__classname), nonExistIds)
            for id, arg in pairs(objects) do
                if not (self.__objects[id]) then
                    self.__objects[id] = self:new(table_unpack(arg))
                end
            end

            for id, object in pairs(self.__objects) do
                if not (validIds[id]) then
                    object:destroy()
                    self.__objects[id] = nil
                end
            end
        end
        lib.resource.onNet(("rep:%s:refresh"):format(self.__classname), refreshObject)
        CreateThread(refreshObject)
    end

    lib.resource.onStop(function()
        for _, object in pairs(self.__objects) do
            object:destroy()
        end
    end)

    return self
end

cslib_component = setmetatable({
    new = CreateCSyncedObject,
}, {
    __call = function(t, ...)
        return CreateCSyncedObject(...)
    end,
})
