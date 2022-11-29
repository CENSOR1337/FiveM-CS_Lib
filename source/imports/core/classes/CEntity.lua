CEntity = {}
CEntity.__index = CEntity

function CEntityValidate(self)

    if not (self.entity) then
        return true, "no entity id provided"
    end

    if not DoesEntityExist(self.entity) then
        return true, "entity does not exist"
    end

    return false
end

function CEntity.new(entity)
    local self = {}
    self.entity = entity

    local err, errMsg = CEntityValidate(self)
    if (err) then error(errMsg) end

    return setmetatable(self, CEntity)
end

function CEntity.create(model, coords, networked)
    model = type(model) == "number" and model or joaat(model)
    if not (HasModelLoaded(model)) then error(string.format("model %s has not been loaded", model)) end
    networked = networked == nil and true or networked
    local entity = CreateObject(model, coords.x, coords.y, coords.z, networked, false, true)
    return CEntity.new(entity)
end

function CEntity:isEntityValid()
    if not (DoesEntityExist(self.entity)) then
        return false
    end

    return true
end

function CEntity:getCoords()
    return GetEntityCoords(self.entity)
end

function CEntity:getHeading()
    return GetEntityHeading(self.entity)
end

function CEntity:getDistanceBetweenCoords(coords)
    return #(self:getCoords() - coords)
end

function CEntity:getDistanceBetweenEntity(targetEntity)
    local tCoords
    if (type(targetEntity) == "number") then
        tCoords = GetEntityCoords(targetEntity)
    else
        tCoords = targetEntity:getCoords()
    end

    return self:getDistanceBetweenCoords(tCoords)
end

function CEntity:delete()
    if not (self:isEntityValid()) then return end
    DeleteEntity(self.entity)
end

function CEntity:getModel()
    if not (self.modelHash) then
        self.modelHash = GetEntityModel(self.entity)
    end

    return self.modelHash
end

function CEntity.getSpeed()
    return GetEntitySpeed(self.entity)
end
