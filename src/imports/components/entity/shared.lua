local _in = Citizen.InvokeNative
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

local Entity = {}
Entity.__index = Entity

local typeCheck = function(value, ...)
    local types = { ... }
    if (#types == 0) then return true end
    local mapType = {}
    for i = 1, #types, 1 do
        mapType[types[i]] = true
    end
    local valueType = type(value)
    local requireTypes = table.concat(types, " or ")
    local errorMessage = ("bad value (%s expected, got %s)"):format(requireTypes, valueType)
    local matches = mapType[valueType] ~= nil
    assert(matches, errorMessage)
    return matches
end

local classWarp = function(class, ...)
    return setmetatable({
        new = class.new,
    }, {
        __call = function(t, ...)
            return t.new(...)
        end,
    })
end

function Entity.new(modelHash, position, rotation, isNetwork)
    typeCheck(modelHash, "string", "number")
    typeCheck(position, "vector3", "vec4")
    typeCheck(rotation, "vector3", "vec4")
    typeCheck(isNetwork, "boolean", "nil")

    if (lib.bIsServer) then
        isNetwork = true
    end

    local self = setmetatable({}, Entity)
    self.model = type(modelHash) == "number" and modelHash or GetHashKey(modelHash)
    self.position = vec(position.x, position.y, position.z)
    self.rotation = vec(rotation.x, rotation.y, rotation.z)
    self.isNetwork = isNetwork and true or false
    self.entity = 0
    self.destroyed = false

    -- Init
    CreateThread(function()
        if not (lib.bIsServer) then
            lib.streaming.model.request.await(self.model)
        end
        if (self.destroyed) then return end
        self.entity = self:createEntity()
        self:setPosition(self.position)
        self:setRotation(self.rotation)
    end)

    return self
end

function Entity:setPosition(position)
    typeCheck(position, "vector3", "table", "vec")
    self.position = vec(position.x, position.y, position.z)
    if not (self:isValid()) then return end
    SetEntityCoords(self.entity, self.position.x, self.position.y, self.position.z, false, false, false, false)
end

function Entity:setRotation(rotation)
    typeCheck(rotation, "vector3", "table", "vec")
    self.rotation = vec(rotation.x, rotation.y, rotation.z)
    if not (self:isValid()) then return end
    SetEntityRotation(self.entity, self.rotation.x, self.rotation.y, self.rotation.z, 0, false)
end

function Entity:createEntity()
    return 0
end

function Entity:getEntity()
    return self.entity
end

function Entity:isValid()
    return DoesEntityExist(self.entity)
end

function Entity:destroy()
    self.destroyed = true
    if not (self:isValid()) then return end
    DeleteEntity(self.entity)
end

-- @ class Object
local Object = {}
Object.__index = Object
setmetatable(Object, { __index = Entity })

function Object.new(model, position, rotation)
    local self = setmetatable(Entity.new(model, position, rotation), Object)
    return self
end

function Object:createEntity()
    return CreateObjectNoOffset(self.model, self.position.x, self.position.y, self.position.z, self.isNetwork, false, false)
end

-- @ class Ped
local Ped = {}
Ped.__index = Ped
setmetatable(Ped, { __index = Entity })

function Ped.new(model, position, rotation)
    local self = setmetatable(Entity.new(model, position, rotation), Ped)
    return self
end

function Ped:createEntity()
    return CreatePed(4, self.model, self.position.x, self.position.y, self.position.z, self.rotation.z, self.isNetwork, false)
end

-- @ class Vehicle
local Vehicle = {}
Vehicle.__index = Vehicle
setmetatable(Vehicle, { __index = Entity })

function Vehicle.new(model, position, rotation)
    local self = setmetatable(Entity.new(model, position, rotation), Vehicle)
    return self
end

function Vehicle:createEntity()
    return createVehicle(self.model, self.position, self.rotation, self.isNetwork)
end

cslib_component.object = classWarp(Object)
cslib_component.ped = classWarp(Ped)
cslib_component.vehicle = classWarp(Vehicle)
