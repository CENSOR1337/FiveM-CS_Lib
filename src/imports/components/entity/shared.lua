local _in = Citizen.InvokeNative
local Citizen = Citizen
local CitizenAwait = Citizen.Await
local CreateThreadNow = Citizen.CreateThreadNow

local createVehicle = function(model, position, rotation, isNetwork)
    local entity
    if (lib.isServer) then
        entity = _in(joaat("CREATE_AUTOMOBILE"), model, position.x, position.y, position.z, 0)
    else
        entity = CreateVehicle(model, position.x, position.y, position.z, 0.0, isNetwork, false)
    end

    SetEntityCoords(entity, position.x, position.y, position.z, false, false, false, false)
    SetEntityRotation(entity, rotation.x, rotation.y, rotation.z, 0, false)
    return entity
end

local typeEnum = {
    VEHICLE = "vehicle",
    PED = "ped",
    OBJECT = "object",
}

local Entity = {}
Entity.__index = Entity

local classWarp = function(class, ...)
    return setmetatable({
        new = class.new,
    }, {
        __call = function(t, ...)
            return t.new(...)
        end,
    })
end

function Entity.new(modelHash, position, rotation, entityType, isNetwork)
    lib.typeCheck(modelHash, "string", "number")
    lib.typeCheck(position, "vector3", "vector4", "table")
    lib.typeCheck(rotation, "vector3", "vector4", "table")
    lib.typeCheck(isNetwork, "boolean", "nil")

    if (lib.bIsServer) then
        isNetwork = true
    end

    local self = setmetatable({}, Entity)
    self.model = type(modelHash) == "number" and modelHash or joaat(modelHash)
    self.position = vec(position.x, position.y, position.z)
    self.rotation = vec(rotation.x, rotation.y, rotation.z)
    self.isNetwork = isNetwork and true or false
    self.handle = 0
    self.destroyed = false
    self.onCreatedDispatcher = lib.dispatcher()
    self.onDestroyedDispatcher = lib.dispatcher()

    -- Init
    CreateThreadNow(function()
        if not (lib.bIsServer) then
            lib.streaming.model.request.await(self.model)
        end
        if (self.destroyed) then return end
        if (entityType == typeEnum.VEHICLE) then
            self.handle = createVehicle(self.model, self.position, self.rotation, self.isNetwork)
        elseif (entityType == typeEnum.PED) then
            self.handle = CreatePed(4, self.model, self.position.x, self.position.y, self.position.z, self.rotation.z, self.isNetwork, false)
        elseif (entityType == typeEnum.OBJECT) then
            self.handle = CreateObjectNoOffset(self.model, self.position.x, self.position.y, self.position.z, self.isNetwork, false, false)
        end
        self:setPosition(self.position)
        self:setRotation(self.rotation)
        self.onCreatedDispatcher:broadcast()
    end)

    return self
end

function Entity:onCreated(callback)
    lib.typeCheck(callback, "function")

    -- Just call the callback if the entity is already created
    if (self:isValid()) then
        callback()
        return
    end

    -- Otherwise, listen for the entity to be created
    local dispatchId
    dispatchId = self.onCreatedDispatcher:add(function()
        callback()
        self.onCreatedDispatcher:remove(dispatchId)
    end)
end

function Entity:onDestroyed(callback)
    lib.typeCheck(callback, "function")

    -- Just call the callback if the entity is already destroyed
    if (self.destroyed) then
        callback()
        return
    end

    -- Otherwise, listen for the entity to be destroyed
    local dispatchId
    dispatchId = self.onDestroyedDispatcher:add(function()
        callback()
        self.onDestroyedDispatcher:remove(dispatchId)
    end)
end

function Entity:waitForCreation()
    local p = promise.new()
    self:onCreated(function()
        p:resolve(true)
    end)
    return CitizenAwait(p)
end

function Entity:setPosition(position)
    lib.typeCheck(position, "vector3", "vector4", "table")
    self.position = vec(position.x, position.y, position.z)
    if not (self:isValid()) then return end
    SetEntityCoords(self.handle, self.position.x, self.position.y, self.position.z, false, false, false, false)
end

function Entity:setRotation(rotation)
    lib.typeCheck(rotation, "vector3", "vector4", "table")
    self.rotation = vec(rotation.x, rotation.y, rotation.z)
    if not (self:isValid()) then return end
    SetEntityRotation(self.handle, self.rotation.x, self.rotation.y, self.rotation.z, 0, false)
end

function Entity:getEntity()
    return self.handle
end

function Entity:getHandle()
    return self.handle
end

function Entity:isValid()
    return DoesEntityExist(self.handle)
end

function Entity:destroy()
    self.destroyed = true
    self.onDestroyedDispatcher:broadcast()
    if not (self:isValid()) then return end
    DeleteEntity(self.handle)
end

-- @ class Object
local Object = {}
Object.__index = Object
setmetatable(Object, { __index = Entity })

function Object.new(model, position, rotation)
    local self = setmetatable(Entity.new(model, position, rotation, typeEnum.OBJECT), Object)
    return self
end

-- @ class Ped
local Ped = {}
Ped.__index = Ped
setmetatable(Ped, { __index = Entity })

function Ped.new(model, position, rotation)
    local self = setmetatable(Entity.new(model, position, rotation, typeEnum.PED), Ped)
    return self
end

-- @ class Vehicle
local Vehicle = {}
Vehicle.__index = Vehicle
setmetatable(Vehicle, { __index = Entity })

function Vehicle.new(model, position, rotation)
    local self = setmetatable(Entity.new(model, position, rotation, typeEnum.VEHICLE), Vehicle)
    return self
end

cslib_component.object = classWarp(Object)
cslib_component.ped = classWarp(Ped)
cslib_component.vehicle = classWarp(Vehicle)
