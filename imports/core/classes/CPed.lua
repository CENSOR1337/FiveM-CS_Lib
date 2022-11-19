CPed = {}
CPed.__index = CPed
setmetatable(CPed, CEntity)

function CPed.new(pedId)
    local self = {}
    self.entity = pedId

    local err, errMsg = CEntityValidate(self)
    if (err) then error(errMsg) end

    return setmetatable(self, CPed)
end

function CPed.create(model, coords, networked)
    model = type(model) == "number" and model or joaat(model)
    if not (HasModelLoaded(model)) then error(string.format("model %s has not been loaded", model)) end
    networked = networked == nil and true or networked
    local heading = 0.0
    if (coords.w) then
        heading = coords.w
    end
    local ped = CreatePed(4, model, coords.x, coords.y, coords.z, heading, networked, false)
    return CPed.new(ped)
end
