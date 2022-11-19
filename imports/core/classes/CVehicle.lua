CVehicle = {}
CVehicle.__index = CVehicle
setmetatable(CVehicle, CEntity)

function CVehicle.new(vehicle)
    local self = {}
    self.entity = vehicle

    local err, errMsg = CEntityValidate(self)
    if (err) then error(errMsg) end

    return setmetatable(self, CVehicle)
end

function CVehicle.create(model, coords, networked)
    model = type(model) == "number" and model or joaat(model)
    if not (HasModelLoaded(model)) then error(string.format("model %s has not been loaded", model)) end
    networked = networked == nil and true or networked
    local heading = 0.0
    if (coords.w) then
        heading = coords.w
    end
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, networked, false)
    return CVehicle.new(vehicle)
end
